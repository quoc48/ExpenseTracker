#!/usr/bin/env node

// Detailed Supabase connection test
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

function testEndpoint(config, endpoint, description) {
    return new Promise((resolve) => {
        const url = new URL(config.SUPABASE_URL + endpoint);
        
        const options = {
            hostname: url.hostname,
            port: 443,
            path: url.pathname,
            method: 'GET',
            headers: {
                'apikey': config.SUPABASE_ANON_KEY,
                'Authorization': `Bearer ${config.SUPABASE_ANON_KEY}`,
                'Content-Type': 'application/json'
            }
        };

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                console.log(`${description}:`);
                console.log(`  Status: ${res.statusCode} ${getStatusMessage(res.statusCode)}`);
                
                if (res.statusCode === 200) {
                    console.log(`  ✅ SUCCESS`);
                } else if (res.statusCode === 401) {
                    console.log(`  ❌ AUTHENTICATION ERROR`);
                } else if (res.statusCode === 404) {
                    console.log(`  ⚠️  ENDPOINT NOT FOUND (may be normal)`);
                } else {
                    console.log(`  ⚠️  UNEXPECTED RESPONSE`);
                }
                console.log('');
                resolve(res.statusCode);
            });
        });

        req.on('error', (e) => {
            console.log(`${description}:`);
            console.log(`  ❌ CONNECTION ERROR: ${e.message}`);
            console.log('');
            resolve(0);
        });

        req.setTimeout(5000, () => {
            console.log(`${description}:`);
            console.log(`  ❌ TIMEOUT`);
            console.log('');
            req.destroy();
            resolve(0);
        });

        req.end();
    });
}

function getStatusMessage(code) {
    const messages = {
        200: 'OK',
        401: 'Unauthorized',
        403: 'Forbidden',
        404: 'Not Found',
        500: 'Internal Server Error'
    };
    return messages[code] || 'Unknown';
}

async function runTests() {
    console.log('🧪 ExpenseTracker - Detailed Supabase Tests');
    console.log('=============================================\n');

    const config = loadEnv();
    
    console.log('📋 Configuration Check:');
    console.log(`  Project URL: ${config.SUPABASE_URL}`);
    console.log(`  Anon Key: ${config.SUPABASE_ANON_KEY.substring(0, 20)}...`);
    console.log(`  Service Key: ${config.SUPABASE_SERVICE_ROLE_KEY ? 'Present' : 'Missing'}`);
    console.log('');

    // Test different endpoints
    await testEndpoint(config, '/rest/v1/', '1. REST API Base');
    await testEndpoint(config, '/auth/v1/settings', '2. Auth Service');
    await testEndpoint(config, '/rest/v1/users', '3. Users Table (may not exist yet)');
    await testEndpoint(config, '/rest/v1/budgets', '4. Budgets Table (may not exist yet)');
    await testEndpoint(config, '/rest/v1/expenses', '5. Expenses Table (may not exist yet)');

    console.log('📊 Test Summary:');
    console.log('===============');
    console.log('✅ If tests 1-2 show SUCCESS: Your basic connection works');
    console.log('⚠️  Tests 3-5 may show "NOT FOUND" - this is normal if tables don\'t exist yet');
    console.log('❌ If tests 1-2 fail: Check your URL and anon key');
    console.log('');
    console.log('🎯 Ready for next steps: Creating database tables and iOS integration!');
}

runTests().catch(console.error);