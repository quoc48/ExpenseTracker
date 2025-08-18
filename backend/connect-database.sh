#!/bin/bash

# ExpenseTracker - Supabase Database Connection Setup
# This script helps connect your local project to your existing Supabase database

echo "🚀 ExpenseTracker - Supabase Database Connection"
echo "================================================"
echo ""

# Check if we're in the right directory
if [ ! -f "supabase/config.toml" ]; then
    echo "❌ Error: Please run this script from the backend/ directory"
    echo "Usage: cd backend && bash connect-database.sh"
    exit 1
fi

echo "Before proceeding, you'll need to gather the following information from your Supabase dashboard:"
echo ""
echo "1. 📍 Project URL (https://your-project.supabase.co)"
echo "2. 🔑 Project Reference ID (found in Project Settings)"
echo "3. 🗝️  Anon Key (found in Project Settings > API)"
echo "4. 🔐 Service Role Key (found in Project Settings > API - keep this secret!)"
echo ""

read -p "Do you have all this information ready? (y/n): " ready

if [ "$ready" != "y" ] && [ "$ready" != "Y" ]; then
    echo ""
    echo "Please gather the required information from your Supabase dashboard:"
    echo "👉 Go to: https://supabase.com/dashboard/project/[your-project]/settings/api"
    echo ""
    echo "Then run this script again: bash connect-database.sh"
    exit 0
fi

echo ""
echo "Step 1: Login to Supabase"
echo "========================"
supabase login

echo ""
echo "Step 2: Link to your existing project"
echo "===================================="
echo "You'll be prompted for your project reference ID..."
supabase link

echo ""
echo "Step 3: Create environment configuration"
echo "======================================"

if [ -f ".env.local" ]; then
    echo "⚠️  .env.local already exists. Creating backup..."
    cp .env.local .env.local.backup
fi

echo "Please enter your project details:"
echo ""

read -p "Project URL (https://your-project.supabase.co): " project_url
read -p "Anon Key: " anon_key
read -s -p "Service Role Key (hidden): " service_key
echo ""

# Create .env.local file
cat > .env.local << EOF
# Supabase Configuration for ExpenseTracker
# Generated on $(date)

# Production Supabase
SUPABASE_URL=$project_url
SUPABASE_ANON_KEY=$anon_key
SUPABASE_SERVICE_ROLE_KEY=$service_key

# Local Development (when using supabase start)
SUPABASE_LOCAL_URL=http://localhost:54321
SUPABASE_LOCAL_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0

# Development Mode
# Set to 'local' to use local Supabase instance
# Set to 'remote' to use production Supabase
SUPABASE_MODE=remote
EOF

echo ""
echo "✅ Environment configuration created!"
echo ""

echo "Step 4: Test connection"
echo "====================="
echo "Testing connection to your Supabase project..."

# Test the connection
if supabase projects list | grep -q "$(basename "$project_url")"; then
    echo "✅ Successfully connected to Supabase!"
    echo ""
    echo "Step 5: Pull existing schema (optional)"
    echo "====================================="
    read -p "Would you like to pull your existing database schema? (y/n): " pull_schema
    
    if [ "$pull_schema" = "y" ] || [ "$pull_schema" = "Y" ]; then
        echo "Pulling database schema..."
        supabase db pull
        echo "✅ Schema pulled successfully!"
    fi
else
    echo "❌ Connection test failed. Please check your configuration."
    echo "You may need to run 'supabase link' again with the correct project reference."
fi

echo ""
echo "🎉 Setup Complete!"
echo "================="
echo ""
echo "Next steps:"
echo "1. ✅ Database connection configured"
echo "2. 📁 Environment variables saved to .env.local"
echo "3. 🔄 Ready for iOS app integration"
echo ""
echo "For iOS app setup, you'll need to add these values to your app configuration:"
echo "- SUPABASE_URL: $project_url"
echo "- SUPABASE_ANON_KEY: $anon_key"
echo ""
echo "⚠️  Remember: Never commit .env.local to git (it's already in .gitignore)"
echo ""