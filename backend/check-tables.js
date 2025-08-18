#!/usr/bin/env node

// Check existing tables in Supabase database
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

function checkTable(config, tableName) {
    return new Promise((resolve) => {
        const url = new URL(config.SUPABASE_URL + `/rest/v1/${tableName}?limit=1`);
        
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
                    exists: res.statusCode === 200,
                    status: res.statusCode,
                    headers: res.headers
                };

                if (res.statusCode === 200) {
                    try {
                        const jsonData = JSON.parse(data);
                        result.recordCount = Array.isArray(jsonData) ? jsonData.length : 0;
                        result.totalCount = res.headers['content-range'] ? 
                            res.headers['content-range'].split('/')[1] : 'unknown';
                    } catch (e) {
                        result.recordCount = 'error parsing';
                    }
                } else if (res.statusCode === 401) {
                    result.error = 'Authentication error';
                } else if (res.statusCode === 404) {
                    result.error = 'Table does not exist';
                } else {
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

async function checkAllTables() {
    console.log('📊 ExpenseTracker - Database Table Analysis');
    console.log('===========================================\n');

    const config = loadEnv();
    
    // Common table names to check
    const tablesToCheck = [
        'users', 'profiles', 'budgets', 'expenses', 'categories',
        'receipts', 'transactions', 'accounts', 'settings'
    ];
    
    console.log('🔍 Checking for existing tables...\n');
    
    const results = [];
    for (const table of tablesToCheck) {
        const result = await checkTable(config, table);
        results.push(result);
        
        if (result.exists) {
            console.log(`✅ ${table}`);
            console.log(`   Status: ${result.status} OK`);
            if (result.totalCount && result.totalCount !== 'unknown') {
                console.log(`   Records: ${result.totalCount}`);
            }
        } else if (result.status === 404) {
            console.log(`⚪ ${table} - does not exist`);
        } else {
            console.log(`❌ ${table} - ${result.error}`);
        }
        console.log('');
    }
    
    // Summary
    const existingTables = results.filter(r => r.exists);
    const missingTables = results.filter(r => !r.exists && r.status === 404);
    const errorTables = results.filter(r => !r.exists && r.status !== 404);
    
    console.log('📋 Summary:');
    console.log('===========');
    console.log(`✅ Existing tables: ${existingTables.length}`);
    console.log(`⚪ Missing tables: ${missingTables.length}`);
    console.log(`❌ Error accessing: ${errorTables.length}`);
    console.log('');
    
    if (existingTables.length > 0) {
        console.log('🎯 Your existing tables:');
        existingTables.forEach(table => {
            console.log(`   - ${table.name}`);
        });
        console.log('');
    }
    
    if (existingTables.length === 0) {
        console.log('💡 No tables found. This is normal for a new Supabase project.');
        console.log('   Next step: Create your database schema!');
    } else {
        console.log('🚀 Great! You have existing tables to work with.');
        console.log('   Next step: Review schema and integrate with iOS app.');
    }
}

checkAllTables().catch(console.error);