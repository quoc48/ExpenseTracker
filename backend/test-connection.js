#!/usr/bin/env node

// Simple test to verify Supabase connection
// Run with: node test-connection.js

const https = require('https');
const fs = require('fs');

// Load environment variables
function loadEnv() {
    try {
        const env = fs.readFileSync('.env.local', 'utf8');
        const config = {};
        env.split('\n').forEach(line => {
            if (line.includes('=') && !line.startsWith('#')) {
                const [key, value] = line.split('=');
                config[key.trim()] = value.trim();
            }
        });
        return config;
    } catch (error) {
        console.error('❌ Error reading .env.local:', error.message);
        process.exit(1);
    }
}

// Test Supabase connection
function testConnection(config) {
    const url = new URL(config.SUPABASE_URL + '/rest/v1/');
    
    console.log('🧪 Testing Supabase Connection...');
    console.log('📍 URL:', config.SUPABASE_URL);
    console.log('🔑 Using anon key (first 20 chars):', config.SUPABASE_ANON_KEY.substring(0, 20) + '...');
    
    const options = {
        hostname: url.hostname,
        port: 443,
        path: '/rest/v1/',
        method: 'GET',
        headers: {
            'apikey': config.SUPABASE_ANON_KEY,
            'Authorization': `Bearer ${config.SUPABASE_ANON_KEY}`,
            'Content-Type': 'application/json'
        }
    };

    const req = https.request(options, (res) => {
        console.log(`\n✅ Connection Status: ${res.statusCode}`);
        
        if (res.statusCode === 200) {
            console.log('🎉 SUCCESS: Supabase connection is working!');
            console.log('✅ Your configuration is correct');
        } else if (res.statusCode === 401) {
            console.log('❌ AUTHENTICATION ERROR: Check your anon key');
        } else {
            console.log('⚠️  Unexpected response code:', res.statusCode);
        }

        res.on('data', (d) => {
            // Don't log response data for security
        });
    });

    req.on('error', (e) => {
        console.error('❌ CONNECTION ERROR:', e.message);
        console.log('💡 Make sure your SUPABASE_URL is correct');
    });

    req.setTimeout(5000, () => {
        console.log('❌ TIMEOUT: Connection took too long');
        req.destroy();
    });

    req.end();
}

// Main execution
console.log('ExpenseTracker - Supabase Connection Test');
console.log('==========================================\n');

const config = loadEnv();

if (!config.SUPABASE_URL || !config.SUPABASE_ANON_KEY) {
    console.error('❌ Missing required configuration:');
    console.error('   - SUPABASE_URL:', config.SUPABASE_URL ? '✅' : '❌');
    console.error('   - SUPABASE_ANON_KEY:', config.SUPABASE_ANON_KEY ? '✅' : '❌');
    process.exit(1);
}

testConnection(config);