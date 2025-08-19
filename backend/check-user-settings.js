#!/usr/bin/env node

// Check user_settings table structure
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

function checkUserSettings(config) {
    return new Promise((resolve) => {
        const url = new URL(config.SUPABASE_URL + '/rest/v1/user_settings?limit=1');
        
        const options = {
            hostname: url.hostname,
            port: 443,
            path: url.pathname + url.search,
            method: 'GET',
            headers: {
                'apikey': config.SUPABASE_ANON_KEY,
                'Authorization': `Bearer ${config.SUPABASE_ANON_KEY}`,
                'Content-Type': 'application/json'
            }
        };

        console.log('🔍 Checking user_settings table structure...');

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                console.log(`📊 Response Status: ${res.statusCode}`);
                
                if (res.statusCode === 200) {
                    try {
                        const settings = JSON.parse(data);
                        console.log('✅ SUCCESS: user_settings table accessible');
                        console.log(`📋 Sample data count: ${settings.length}`);
                        
                        if (settings.length > 0) {
                            console.log('🗂️  Columns found:');
                            const columns = Object.keys(settings[0]);
                            columns.forEach(col => console.log(`   - ${col}`));
                            
                            console.log('\n📋 Sample record:');
                            console.log(JSON.stringify(settings[0], null, 2));
                        } else {
                            console.log('📋 Table is empty - cannot determine structure');
                        }
                        
                        resolve({ success: true, data: settings });
                    } catch (e) {
                        console.log(`❌ Error parsing response: ${e.message}`);
                        resolve({ success: false, error: 'Parse error' });
                    }
                } else if (res.statusCode === 401) {
                    console.log('❌ Authentication error');
                    resolve({ success: false, error: 'Auth error' });
                } else if (res.statusCode === 404) {
                    console.log('❌ Table not found or no access');
                    resolve({ success: false, error: 'Not found' });
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

        req.setTimeout(5000, () => {
            console.log('❌ Request timeout');
            req.destroy();
            resolve({ success: false, error: 'Timeout' });
        });

        req.end();
    });
}

async function main() {
    console.log('🔍 ExpenseTracker - User Settings Table Analysis');
    console.log('================================================\n');

    try {
        const config = loadEnv();
        const result = await checkUserSettings(config);
        
        console.log('\n🎯 Summary:');
        console.log('===========');
        if (result.success) {
            console.log('✅ user_settings table is accessible');
            console.log('📊 We can determine its structure for iOS models');
        } else {
            console.log(`❌ Cannot access user_settings: ${result.error}`);
            console.log('💡 This table might have Row Level Security restrictions');
            console.log('🔧 We can create a model based on common user settings patterns');
        }
    } catch (error) {
        console.log(`❌ Script error: ${error.message}`);
    }
}

main();