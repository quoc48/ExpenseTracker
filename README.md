# ExpenseTracker

A simple and intuitive iOS expense tracking app built with SwiftUI and Supabase.

## Features

### Core Functionality
- **Monthly Budget Goals**: Set default monthly budgets with per-month override capability
- **Manual Expense Entry**: Quick daily expense input with category selection
- **Receipt Scanning**: AI-powered receipt image processing to auto-generate expense entries
- **Comprehensive Reports**: Daily, weekly, monthly, and yearly expense analysis with drill-down details
- **Real-time Sync**: Cloud synchronization across devices using Supabase

### User Experience
- Clean, intuitive SwiftUI interface
- Offline support with automatic sync when connected
- Quick expense entry with smart categorization
- Visual spending insights with charts and graphs
- Secure authentication and data protection

## Technology Stack

- **Frontend**: iOS app built with SwiftUI (iOS 16+)
- **Backend**: Supabase (PostgreSQL + Auth + Real-time)
- **Architecture**: MVVM (Model-View-ViewModel)
- **AI Integration**: Vision framework for receipt scanning
- **Data Storage**: Cloud-first with local caching

## Project Structure

```
ExpenseTracker/
├── docs/                    # Project management and planning
│   ├── CLAUDE.md           # Development guidelines for Claude Code
│   ├── PROJECT_PLAN.md     # Master roadmap and session breakdown
│   ├── CURRENT_STATE.md    # Current progress and next priorities
│   └── SESSION_NOTES.md    # Development session logs
├── ios/                     # iOS SwiftUI application
│   └── ExpenseTracker/
│       ├── Models/         # Data models and business logic
│       ├── Views/          # SwiftUI views organized by feature
│       ├── ViewModels/     # MVVM view models
│       ├── Services/       # Supabase services and API clients
│       ├── Utilities/      # Helper functions and extensions
│       └── Resources/      # Assets and configuration files
├── backend/                 # Supabase setup and configuration
│   ├── supabase/
│   │   ├── migrations/     # Database schema migrations
│   │   ├── functions/      # Edge functions (if needed)
│   │   └── config.toml     # Supabase configuration
│   └── README.md           # Backend setup instructions
└── README.md               # This file
```

## Getting Started

### Prerequisites

- Xcode 15.0+ (for iOS development)
- iOS 16.0+ (minimum deployment target)
- [Supabase CLI](https://supabase.com/docs/guides/cli) (for backend)
- A Supabase account and project

### Backend Setup

1. **Set up Supabase project**
   ```bash
   cd backend
   supabase login
   supabase link --project-ref YOUR_PROJECT_REF
   ```

2. **Start local development**
   ```bash
   supabase start
   ```

3. **Apply database migrations** (when available)
   ```bash
   supabase db push
   ```

4. **Configure environment variables**
   - Create `.env.local` in the backend directory
   - Add your Supabase URL and keys (see `backend/README.md`)

### iOS App Setup

1. **Open the iOS project**
   ```bash
   cd ios
   open ExpenseTracker.xcodeproj
   ```

2. **Configure Supabase credentials**
   - Add your Supabase URL and anon key to the app configuration
   - Update `Resources/Config.plist` with your project details

3. **Build and run**
   - Select a simulator or device in Xcode
   - Press ⌘+R to build and run the app

## Development Workflow

This project follows a structured development approach optimized for Claude Code sessions:

### Session Management
- Development is organized into focused sessions (15-20 exchanges each)
- Each session completes one cohesive feature
- Progress is tracked in `docs/CURRENT_STATE.md`
- Session notes are logged in `docs/SESSION_NOTES.md`

### Starting Development
1. Read the planning files:
   - `docs/PROJECT_PLAN.md` - Overall roadmap
   - `docs/CURRENT_STATE.md` - Current progress
   - `docs/SESSION_NOTES.md` - Recent session summaries

2. Follow the session goals outlined in the project plan
3. Update documentation before ending each session

### Code Quality Standards
- SwiftUI best practices with MVVM architecture
- Comprehensive error handling for all network operations
- Real-time data synchronization using Supabase subscriptions
- Accessibility support and proper iOS conventions

## Current Status

**Phase:** Foundation Setup (Complete)  
**Next Phase:** Core Data Models & Supabase Integration  
**Overall Progress:** ~15%

See `docs/CURRENT_STATE.md` for detailed progress tracking and next steps.

## Contributing

This project is designed for development with Claude Code. Key guidelines:

- Follow the development rules in `docs/CLAUDE.md`
- Maintain session-based development workflow
- Update planning documentation with each session
- Test incrementally and commit working code frequently

## Database Schema

The app uses the following core data models:

- **Profiles**: Extended user data and preferences
- **Budgets**: Monthly budget goals and overrides  
- **Categories**: Expense categorization with colors and icons
- **Expenses**: Individual expense entries with receipt support

Full schema details and migration files are in `backend/supabase/migrations/`.

## Security & Privacy

- All user data is secured with Supabase Row Level Security (RLS)
- Authentication handled through Supabase Auth
- Receipt images stored securely in Supabase Storage
- No sensitive data stored locally on device

## Roadmap

### Phase 1: Foundation ✅
- [x] Project structure and documentation
- [x] iOS app scaffold
- [x] Supabase backend configuration

### Phase 2: Core Features (Next)
- [ ] Database schema and data models
- [ ] User authentication
- [ ] Budget management
- [ ] Manual expense entry
- [ ] Basic reporting

### Phase 3: Enhanced Features
- [ ] Receipt scanning with Vision framework
- [ ] Advanced reporting and analytics
- [ ] Export functionality
- [ ] Performance optimizations

### Phase 4: Polish
- [ ] UI/UX improvements
- [ ] Accessibility features
- [ ] Comprehensive testing
- [ ] App Store preparation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For development questions or issues, refer to:
- `docs/CLAUDE.md` for development guidelines
- `backend/README.md` for Supabase setup help
- Project planning files in `docs/` for context