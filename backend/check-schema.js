#!/usr/bin/env node

// Check database schema using PostgREST introspection
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

function makeRequest(config, path, description) {
    return new Promise((resolve) => {
        const url = new URL(config.SUPABASE_URL + path);
        
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

        console.log(`🔍 ${description}...`);

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                console.log(`   Status: ${res.statusCode} ${getStatusMessage(res.statusCode)}`);
                
                if (res.statusCode === 200) {
                    try {
                        const jsonData = JSON.parse(data);
                        console.log(`   ✅ Success - ${Array.isArray(jsonData) ? jsonData.length : 'Got'} items`);
                        resolve({ success: true, data: jsonData, status: res.statusCode });
                    } catch (e) {
                        console.log(`   ✅ Success - Raw response received`);
                        resolve({ success: true, data: data, status: res.statusCode });
                    }
                } else {
                    console.log(`   ❌ ${getStatusMessage(res.statusCode)}`);
                    resolve({ success: false, status: res.statusCode, error: data });
                }
                console.log('');
            });
        });

        req.on('error', (e) => {
            console.log(`   ❌ Connection error: ${e.message}`);
            console.log('');
            resolve({ success: false, error: e.message });
        });

        req.setTimeout(10000, () => {
            console.log(`   ❌ Timeout`);
            console.log('');
            req.destroy();
            resolve({ success: false, error: 'timeout' });
        });

        req.end();
    });
}

function getStatusMessage(code) {
    const messages = {
        200: 'OK',
        206: 'Partial Content',
        401: 'Unauthorized', 
        403: 'Forbidden',
        404: 'Not Found',
        500: 'Internal Server Error'
    };
    return messages[code] || `Unknown (${code})`;
}

async function checkSchema() {
    console.log('🗄️  ExpenseTracker - Database Schema Check');
    console.log('==========================================\n');

    const config = loadEnv();
    
    // Try to get schema information
    const tests = [
        { path: '/rest/v1/', desc: 'OpenAPI Schema' },
        { path: '/rest/v1/expenses?limit=0', desc: 'Expenses table structure' },
        { path: '/rest/v1/categories?limit=0', desc: 'Categories table structure' }
    ];

    for (const test of tests) {
        await makeRequest(config, test.path, test.desc);
    }

    console.log('🔍 Manual Table Check:');
    console.log('======================');
    
    // Try to access tables with different approaches
    const tableTests = ['expenses', 'categories'];
    
    for (const table of tableTests) {
        console.log(`\nTesting ${table} table:`);
        
        // Test 1: Basic access
        const basic = await makeRequest(config, `/rest/v1/${table}?limit=1`, `  Basic access`);
        
        // Test 2: Count only
        const count = await makeRequest(config, `/rest/v1/${table}?select=count`, `  Count query`);
        
        // Test 3: Schema info
        const schema = await makeRequest(config, `/rest/v1/${table}?limit=0`, `  Schema info`);
        
        if (basic.success || count.success || schema.success) {
            console.log(`   🎯 ${table} table EXISTS!`);
        } else {
            console.log(`   ⚪ ${table} table does not exist`);
        }
    }

    console.log('\n📋 Conclusion:');
    console.log('==============');
    console.log('If you see any successful responses above, those tables exist in your database.');
    console.log('HTTP 206 typically means partial content or RLS (Row Level Security) restrictions.');
}

checkSchema().catch(console.error);