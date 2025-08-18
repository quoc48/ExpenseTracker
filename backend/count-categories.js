#!/usr/bin/env node

// Count categories in Supabase database
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

function countCategories(config) {
    return new Promise((resolve) => {
        // Get count and some sample data
        const url = new URL(config.SUPABASE_URL + '/rest/v1/categories?select=*');
        
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

        console.log('🔍 Querying categories table...');

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                console.log(`📊 Response Status: ${res.statusCode}`);
                
                if (res.statusCode === 200) {
                    try {
                        const categories = JSON.parse(data);
                        const count = categories.length;
                        
                        // Get exact count from header if available
                        let exactCount = count;
                        if (res.headers['content-range']) {
                            const range = res.headers['content-range'];
                            if (range.includes('/')) {
                                exactCount = parseInt(range.split('/')[1]) || count;
                            }
                        }
                        
                        console.log(`\n✅ SUCCESS: Found ${exactCount} categories in your database`);
                        
                        if (count > 0) {
                            console.log('\n📋 Sample categories:');
                            categories.slice(0, 5).forEach((cat, i) => {
                                console.log(`   ${i + 1}. ${cat.name} (${cat.icon}) - ${cat.color}`);
                            });
                            
                            if (count > 5) {
                                console.log(`   ... and ${count - 5} more`);
                            }
                            
                            // Show default vs custom categories
                            const defaultCategories = categories.filter(c => c.is_default);
                            const customCategories = categories.filter(c => !c.is_default);
                            
                            console.log(`\n📊 Category breakdown:`);
                            console.log(`   • Default categories: ${defaultCategories.length}`);
                            console.log(`   • Custom categories: ${customCategories.length}`);
                            console.log(`   • Total: ${count}`);
                        } else {
                            console.log('\n📋 No categories found (empty table)');
                        }
                        
                        resolve({ success: true, count: exactCount, categories });
                        
                    } catch (e) {
                        console.log(`❌ Error parsing response: ${e.message}`);
                        console.log(`Raw response: ${data.substring(0, 200)}...`);
                        resolve({ success: false, error: 'Parse error' });
                    }
                } else if (res.statusCode === 401) {
                    console.log('❌ Authentication error - check your anon key');
                    resolve({ success: false, error: 'Authentication failed' });
                } else if (res.statusCode === 404) {
                    console.log('❌ Categories table not found');
                    resolve({ success: false, error: 'Table not found' });
                } else {
                    console.log(`❌ Unexpected response: ${res.statusCode}`);
                    console.log(`Response: ${data.substring(0, 200)}...`);
                    resolve({ success: false, error: `HTTP ${res.statusCode}` });
                }
            });
        });

        req.on('error', (e) => {
            console.log(`❌ Connection error: ${e.message}`);
            resolve({ success: false, error: 'Connection failed' });
        });

        req.setTimeout(10000, () => {
            console.log('❌ Request timeout');
            req.destroy();
            resolve({ success: false, error: 'Timeout' });
        });

        req.end();
    });
}

async function main() {
    console.log('📊 ExpenseTracker - Category Count Check');
    console.log('========================================\n');

    const config = loadEnv();
    
    console.log(`🔗 Connecting to: ${config.SUPABASE_URL}`);
    console.log(`🔑 Using anon key: ${config.SUPABASE_ANON_KEY.substring(0, 20)}...`);
    console.log('');

    const result = await countCategories(config);
    
    console.log('\n🎯 Summary:');
    console.log('===========');
    if (result.success) {
        console.log(`✅ Successfully connected to your Supabase database`);
        console.log(`📊 Categories table contains: ${result.count} records`);
        console.log(`🚀 Ready for iOS integration!`);
    } else {
        console.log(`❌ Could not access categories table: ${result.error}`);
        console.log(`💡 This might be due to Row Level Security (RLS) policies`);
    }
}

main().catch(console.error);