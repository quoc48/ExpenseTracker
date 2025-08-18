#!/usr/bin/env node

// Analyze existing table structure with better error handling
const https = require('https');
const fs = require('fs');

function loadEnv() {
    const env = fs.readFileSync('.env.local', 'utf8');
    const config = {};
    env.split('\n').forEach(line => {
        if (line.includes('=') && !line.startsWith('#')) {
            const [key, value] = line.split('=');
            config[key.trim()] = value.trim();
        }
    });
    return config;
}

function analyzeTable(config, tableName) {
    return new Promise((resolve) => {
        const url = new URL(config.SUPABASE_URL + `/rest/v1/${tableName}?limit=5`);
        
        const options = {
            hostname: url.hostname,
            port: 443,
            path: url.pathname + url.search,
            method: 'GET',
            headers: {
                'apikey': config.SUPABASE_ANON_KEY,
                'Authorization': `Bearer ${config.SUPABASE_ANON_KEY}`,
                'Content-Type': 'application/json',
                'Prefer': 'count=exact'
            }
        };

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                const result = {
                    name: tableName,
                    status: res.statusCode,
                    headers: res.headers
                };

                // Handle different response types
                if (res.statusCode === 200) {
                    try {
                        const jsonData = JSON.parse(data);
                        result.exists = true;
                        result.records = jsonData;
                        result.recordCount = jsonData.length;
                        
                        // Get total count from content-range header
                        if (res.headers['content-range']) {
                            const range = res.headers['content-range'];
                            if (range.includes('/')) {
                                result.totalCount = parseInt(range.split('/')[1]) || 0;
                            }
                        }
                        
                        // Extract columns from sample data or empty structure
                        if (jsonData.length > 0) {
                            result.columns = Object.keys(jsonData[0]);
                            result.sampleData = jsonData.slice(0, 2);
                        } else {
                            result.columns = [];
                            result.empty = true;
                        }
                        
                    } catch (e) {
                        result.exists = true;
                        result.parseError = e.message;
                        result.rawData = data.substring(0, 100);
                    }
                } else if (res.statusCode === 206) {
                    // Partial content - table exists but may have restrictions
                    result.exists = true;
                    result.partialContent = true;
                    try {
                        const jsonData = JSON.parse(data);
                        result.records = jsonData;
                        if (jsonData.length > 0) {
                            result.columns = Object.keys(jsonData[0]);
                        }
                    } catch (e) {
                        result.parseError = e.message;
                    }
                } else if (res.statusCode === 401) {
                    result.exists = true;
                    result.authError = true;
                } else if (res.statusCode === 404) {
                    result.exists = false;
                } else {
                    result.exists = 'unknown';
                    result.error = `HTTP ${res.statusCode}`;
                    result.responseData = data.substring(0, 200);
                }

                resolve(result);
            });
        });

        req.on('error', (e) => {
            resolve({
                name: tableName,
                exists: false,
                connectionError: e.message
            });
        });

        req.setTimeout(8000, () => {
            req.destroy();
            resolve({
                name: tableName,
                exists: false,
                timeout: true
            });
        });

        req.end();
    });
}

async function analyzeExistingSchema() {
    console.log('🔍 ExpenseTracker - Existing Schema Analysis');
    console.log('============================================\n');

    const config = loadEnv();
    
    // Tables we know exist from the screenshot
    const knownTables = ['categories', 'expenses', 'user_settings'];
    
    console.log('📊 Analyzing your 3 existing tables...\n');
    
    const results = [];
    
    for (const tableName of knownTables) {
        console.log(`🔍 Table: ${tableName}`);
        console.log('─'.repeat(40));
        
        const result = await analyzeTable(config, tableName);
        results.push(result);
        
        if (result.exists === true) {
            console.log('✅ Status: EXISTS');
            console.log(`📊 Total records: ${result.totalCount || result.recordCount || 'Unknown'}`);
            
            if (result.columns && result.columns.length > 0) {
                console.log(`🗂️  Columns (${result.columns.length}): ${result.columns.join(', ')}`);
                
                if (result.sampleData && result.sampleData.length > 0) {
                    console.log('📋 Sample data:');
                    result.sampleData.forEach((record, i) => {
                        console.log(`   ${i + 1}. ${JSON.stringify(record).substring(0, 150)}...`);
                    });
                } else if (result.empty) {
                    console.log('📋 Sample data: (table is empty)');
                }
            } else if (result.partialContent) {
                console.log('⚠️  Partial access - may have RLS restrictions');
            } else if (result.authError) {
                console.log('🔒 Authentication restricted access');
            }
            
            if (result.parseError) {
                console.log(`⚠️  Parse error: ${result.parseError}`);
            }
            
        } else if (result.exists === false) {
            console.log('❌ Status: NOT FOUND');
        } else {
            console.log(`⚠️  Status: ${result.error || 'Unknown'}`);
        }
        
        console.log('');
    }
    
    console.log('🎯 Schema Summary:');
    console.log('==================');
    
    const confirmed = results.filter(r => r.exists === true);
    const withColumns = results.filter(r => r.columns && r.columns.length > 0);
    
    console.log(`✅ Confirmed tables: ${confirmed.length}/3`);
    console.log(`📊 Tables with accessible data: ${withColumns.length}/3`);
    
    if (withColumns.length > 0) {
        console.log('\n📋 Your database structure:');
        withColumns.forEach(table => {
            console.log(`   ${table.name}: [${table.columns.join(', ')}]`);
        });
    }
    
    console.log('\n🚀 Next Steps:');
    if (withColumns.length === 3) {
        console.log('✅ Perfect! All tables are accessible. Ready to build iOS models.');
    } else {
        console.log('⚠️  Some tables may need RLS policy adjustments for full access.');
        console.log('   This is normal - we can work with what we have and adjust as needed.');
    }
}

analyzeExistingSchema().catch(console.error);