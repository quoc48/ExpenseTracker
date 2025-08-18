# ExpenseTracker Backend

This directory contains the Supabase backend configuration for the ExpenseTracker iOS app.

## Overview

The backend uses Supabase for:
- **Database**: PostgreSQL with real-time subscriptions
- **Authentication**: User management and session handling
- **Storage**: Receipt image storage (future feature)
- **Edge Functions**: Server-side logic if needed

## Setup Instructions

### Prerequisites
- [Supabase CLI](https://supabase.com/docs/guides/cli) installed
- Node.js 16+ (for local development)
- PostgreSQL knowledge for schema modifications

### Initial Setup

1. **Install Supabase CLI**
   ```bash
   npm install -g supabase
   ```

2. **Login to Supabase**
   ```bash
   supabase login
   ```

3. **Link to your project**
   ```bash
   cd backend
   supabase link --project-ref YOUR_PROJECT_REF
   ```

4. **Start local development**
   ```bash
   supabase start
   ```

### Environment Configuration

Create a `.env.local` file (not tracked in git) with:
```bash
# Supabase Configuration
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Local Development (when using supabase start)
SUPABASE_LOCAL_URL=http://localhost:54321
SUPABASE_LOCAL_ANON_KEY=your-local-anon-key
```

## Database Schema

### Tables Overview
- `profiles` - Extended user data
- `budgets` - Monthly budget management
- `categories` - Expense categorization
- `expenses` - Individual expense entries

### Schema Files
- `supabase/migrations/` - Database schema migrations
- `supabase/seed.sql` - Initial data seeding
- `supabase/config.toml` - Supabase project configuration

## Development Workflow

### Making Schema Changes
1. Create new migration:
   ```bash
   supabase migration new migration_name
   ```

2. Edit the migration file in `supabase/migrations/`

3. Apply migration locally:
   ```bash
   supabase db reset
   ```

4. Test changes with iOS app

5. Deploy to production:
   ```bash
   supabase db push
   ```

### Row Level Security (RLS)
All tables use RLS to ensure users can only access their own data:
- `profiles`: Users can read/update their own profile
- `budgets`: Users can CRUD their own budgets
- `categories`: Users can CRUD their own categories
- `expenses`: Users can CRUD their own expenses

## API Integration

### Swift Client Setup
The iOS app uses the Supabase Swift client library:
```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
    supabaseKey: "YOUR_SUPABASE_ANON_KEY"
)
```

### Authentication Flow
1. User signs up/in through Supabase Auth
2. JWT token automatically included in all requests
3. RLS policies enforce data access control
4. Real-time subscriptions for data synchronization

## Deployment

### Production Deployment
Migrations are automatically applied when pushed to the linked Supabase project:
```bash
supabase db push
```

### Backup Strategy
- Automatic daily backups by Supabase
- Manual backup before major schema changes
- Export/import utilities for data migration

## Monitoring

### Available Dashboards
- Supabase Dashboard: Database metrics and logs
- Authentication: User management and session tracking
- API: Request metrics and error rates
- Real-time: Subscription activity

### Troubleshooting
- Check Supabase logs for API errors
- Verify RLS policies for access issues
- Monitor database performance for slow queries
- Review migration history for schema issues

## Files Structure
```
backend/
├── README.md                 # This file
├── supabase/
│   ├── config.toml          # Supabase project configuration
│   ├── migrations/          # Database schema migrations
│   │   └── [timestamp]_initial_schema.sql
│   ├── functions/           # Edge functions (if needed)
│   └── seed.sql             # Initial data seeding
└── .env.local               # Local environment variables (not tracked)
```

## Next Steps (Session 2)
1. Design complete database schema
2. Create initial migration with all tables
3. Set up Row Level Security policies
4. Create seed data for development
5. Test Supabase Swift client integration