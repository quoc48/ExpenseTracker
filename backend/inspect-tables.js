#!/usr/bin/env node

// Detailed inspection of existing tables
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

function inspectTable(config, tableName) {
    return new Promise((resolve) => {
        // Try to get some sample data and headers
        const url = new URL(config.SUPABASE_URL + `/rest/v1/${tableName}?limit=3`);
        
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

                if (res.statusCode === 200) {
                    try {
                        const jsonData = JSON.parse(data);
                        result.exists = true;
                        result.records = jsonData;
                        result.recordCount = jsonData.length;
                        
                        // Extract total count from headers
                        if (res.headers['content-range']) {
                            const range = res.headers['content-range'];
                            result.totalCount = range.includes('/') ? range.split('/')[1] : '?';
                        }
                        
                        // Extract column names from first record
                        if (jsonData.length > 0) {
                            result.columns = Object.keys(jsonData[0]);
                        } else {
                            result.columns = [];
                        }
                        
                    } catch (e) {
                        result.exists = true;
                        result.error = 'Could not parse JSON response';
                        result.rawData = data.substring(0, 200);
                    }
                } else {
                    result.exists = false;
                    result.error = `HTTP ${res.statusCode}`;
                }

                resolve(result);
            });
        });

        req.on('error', (e) => {
            resolve({
                name: tableName,
                exists: false,
                error: `Connection error: ${e.message}`
            });
        });

        req.setTimeout(5000, () => {
            req.destroy();
            resolve({
                name: tableName,
                exists: false,
                error: 'Timeout'
            });
        });

        req.end();
    });
}

async function inspectDatabase() {
    console.log('🔍 ExpenseTracker - Database Table Inspection');
    console.log('=============================================\n');

    const config = loadEnv();
    
    const tablesToInspect = ['expenses', 'categories'];
    
    console.log('📊 Inspecting your existing tables...\n');
    
    for (const tableName of tablesToInspect) {
        console.log(`🏷️  Table: ${tableName}`);
        console.log('─'.repeat(30));
        
        const result = await inspectTable(config, tableName);
        
        if (result.exists) {
            console.log(`✅ Status: EXISTS`);
            console.log(`📏 Total records: ${result.totalCount || result.recordCount || 'Unknown'}`);
            
            if (result.columns && result.columns.length > 0) {
                console.log(`🗂️  Columns: ${result.columns.join(', ')}`);
            } else {
                console.log(`🗂️  Columns: Unable to determine (empty table)`);
            }
            
            if (result.records && result.records.length > 0) {
                console.log(`📋 Sample data:`);
                result.records.slice(0, 2).forEach((record, index) => {
                    console.log(`   Record ${index + 1}:`, JSON.stringify(record, null, 2).substring(0, 200));
                });
            } else {
                console.log(`📋 Sample data: (empty table)`);
            }
        } else {
            console.log(`❌ Status: DOES NOT EXIST`);
            console.log(`❌ Error: ${result.error}`);
        }
        
        console.log('');
    }
    
    console.log('🎯 Summary:');
    console.log('===========');
    console.log('Based on the inspection above, you have:');
    
    const existingTables = [];
    for (const tableName of tablesToInspect) {
        const result = await inspectTable(config, tableName);
        if (result.exists) {
            existingTables.push({
                name: tableName,
                count: result.totalCount || result.recordCount || '0'
            });
        }
    }
    
    if (existingTables.length > 0) {
        console.log(`✅ ${existingTables.length} existing table(s):`);
        existingTables.forEach(table => {
            console.log(`   - ${table.name} (${table.count} records)`);
        });
        console.log('');
        console.log('🚀 Ready to integrate with iOS app!');
    } else {
        console.log('⚪ No tables found. Ready to create database schema.');
    }
}

inspectDatabase().catch(console.error);