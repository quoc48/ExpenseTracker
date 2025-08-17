# CLAUDE.md

This file provides guidance to Claude Code when working with the Expense Tracker iOS app project.

## Project Overview

Simple Expense Tracker is an iOS app built with SwiftUI that helps users manage their daily expenses and monthly budgets. The app focuses on ease of use and clear financial insights.

Key features:
- **Monthly Budget Goals**: Set default monthly budget with per-month override capability
- **Manual Expense Entry**: Quick daily expense input with category selection
- **Receipt Scanning**: AI-powered receipt image processing to auto-generate expense entries
- **Comprehensive Reports**: Daily, weekly, monthly, and yearly expense analysis with drill-down details
- **Data Persistence**: Core Data for local storage and data management

## Architecture

### Technology Stack
- **Platform**: iOS (SwiftUI)
- **Data Layer**: Supabase (PostgreSQL) for cloud storage and real-time sync
- **Pattern**: MVVM (Model-View-ViewModel)
- **AI Integration**: Receipt scanning using Vision/ML frameworks
- **Backend**: Supabase for authentication, database, and real-time subscriptions

### Project Structure
```
ExpenseTracker/
├── docs/                    # Project management and planning files
│   ├── CLAUDE.md           # This file - Claude Code guidelines
│   ├── PROJECT_PLAN.md     # Master roadmap and session breakdown
│   ├── CURRENT_STATE.md    # Current progress and next priorities
│   └── SESSION_NOTES.md    # Development session logs
├── ios/                     # iOS SwiftUI application
│   ├── ExpenseTracker/
│   │   ├── Models/         # Data models and business logic
│   │   ├── Views/          # SwiftUI views organized by feature
│   │   ├── ViewModels/     # MVVM view models
│   │   ├── Services/       # Supabase services and API clients
│   │   ├── Utilities/      # Helper functions and extensions
│   │   └── Resources/      # Assets and configuration files
│   └── ExpenseTracker.xcodeproj
├── backend/                 # Supabase setup and configuration
│   ├── supabase/
│   │   ├── migrations/     # Database schema migrations
│   │   ├── functions/      # Edge functions (if needed)
│   │   └── config.toml     # Supabase configuration
│   └── README.md           # Backend setup instructions
└── README.md               # Main project overview and setup guide
```

## Development Rules

### Claude Code Compact Mode Management
- **Session Length Limit**: End sessions before hitting compact mode (typically after 15-20 exchanges)
- **Auto-Monitor**: Claude Code should track conversation length and proactively suggest ending sessions
- **Fresh Session Protocol**: When approaching limits, Claude Code must:
  1. Complete current small task
  2. Update all planning files
  3. Commit working code
  4. Instruct user to start a NEW Claude Code session
- **Context Preservation**: Always update markdown files before ending sessions to preserve context
- **Clean Session Starts**: Begin new sessions by reading all planning files first
- **Token Awareness**: Keep responses focused and avoid unnecessary verbosity

### Auto-Session Management for Claude Code
**When Claude Code detects we're approaching conversation limits (15+ exchanges), it should automatically say:**

```
⚠️ APPROACHING SESSION LIMIT ⚠️

We're nearing the conversation limit. Let me complete the current task and prepare for a fresh session:

1. [Complete current task]
2. [Update docs/CURRENT_STATE.md]
3. [Update docs/SESSION_NOTES.md]
4. [Commit changes]

NEXT STEPS FOR YOU:
1. Close this Claude Code session
2. Open a NEW Claude Code window
3. Navigate to project: cd ExpenseTracker
4. Run: claude-code
5. Start with: "New session starting. Please read docs/CLAUDE.md, docs/PROJECT_PLAN.md, docs/CURRENT_STATE.md, and latest docs/SESSION_NOTES.md. Today's goal: [specific next task]"

This ensures we maintain full context and quality in the next session.
```

### Session Management
- **Always start each session** by reading:
  1. `docs/PROJECT_PLAN.md` - Master roadmap
  2. `docs/CURRENT_STATE.md` - Current progress and issues
  3. `docs/SESSION_NOTES.md` - Previous session logs

- **Monitor conversation length** and proactively end sessions with this protocol:
  ```
  We're approaching the conversation limit. Please:
  1. Complete the current task you're working on
  2. Update docs/CURRENT_STATE.md with today's progress
  3. Update docs/SESSION_NOTES.md with session summary
  4. List exactly what needs to be done in the next session
  ```

- **Start new sessions immediately** with:
  ```
  New session starting. Please read:
  - docs/CLAUDE.md (this file)
  - docs/PROJECT_PLAN.md 
  - docs/CURRENT_STATE.md
  - Latest entry in docs/SESSION_NOTES.md
  
  Today's specific goal: [from CURRENT_STATE.md next priorities]
  ```

### Compact Mode Prevention Strategies
- **Incremental Development**: Complete one small feature per session rather than large features
- **Frequent Commits**: Commit working code after each small completion
- **Clear Handoffs**: Document exactly where you left off and what's next
- **File-Focused Work**: Work on 1-2 files per session to maintain focus

### Feature Development Approach
- **One feature per session**: Don't try to build multiple features at once
- **Build incrementally**: Start with basic functionality, then enhance
- **Test as you go**: Verify each piece works before moving to the next
- **Session breakdown**:
  1. Project setup + data models
  2. Budget management UI and logic
  3. Manual expense entry
  4. Basic reporting views
  5. Receipt scanning integration

### Code Quality Guidelines

#### SwiftUI Best Practices
- Use `@StateObject` for view model initialization
- Prefer `@ObservedObject` for passed view models
- Keep views small and focused on single responsibilities
- Use view modifiers for reusable styling
- Extract complex views into separate components

#### Data Management
- Use Supabase Swift client for all database operations
- Implement proper error handling for network requests
- Use meaningful table and column names following PostgreSQL conventions
- Create service layers for Supabase API interactions
- Handle offline scenarios gracefully with local caching
- Use Supabase real-time subscriptions for data synchronization

#### Code Organization
- **Naming**: Use clear, descriptive names (e.g., `monthlyBudgetAmount`, `addExpenseToCategory`)
- **Functions**: Keep functions focused and under 20 lines when possible
- **Comments**: Document business logic and complex calculations
- **File structure**: Group related functionality together

### Error Handling
- Always handle Supabase API call failures
- Implement network connectivity checks
- Provide user-friendly error messages for server issues
- Handle authentication errors gracefully
- Log errors for debugging without exposing sensitive data
- Implement retry logic for failed requests

## Implementation Guidelines

### Budget Management
- Store budget data in Supabase `budgets` table
- Support user-specific budget settings with authentication
- Handle budget period calculations on client side
- Validate budget amounts before API calls
- Sync budget changes across devices in real-time

### Expense Entry
- Store expenses in Supabase `expenses` table with user association
- Require amount, category, and user_id as minimum fields
- Handle timezone considerations for date storage
- Validate expense data before API submission
- Implement optimistic updates for better UX

### Receipt Scanning
- Use Vision framework for text recognition
- Parse common receipt patterns (items, prices, totals)
- Present extracted data for user review before saving
- Handle scanning failures gracefully

### Reporting
- Use Supabase RPC functions for complex aggregations
- Implement efficient filtering with PostgreSQL queries
- Cache report data locally for better performance
- Support date range selections with proper timezone handling
- Enable drill-down from summaries to detail records

## Testing Approach

### Manual Testing Priorities
- User authentication and session management
- Data synchronization across devices
- Network connectivity edge cases
- Expense entry with network interruptions
- Report accuracy with server-side calculations
- Receipt scanning and data submission to Supabase

### Key Test Scenarios
- Offline/online state transitions
- Authentication token expiration
- Network timeouts and retries
- Concurrent data modifications from multiple devices
- Large expense histories and pagination

## Development Workflow

### Starting a New Session
1. Read the three markdown planning files
2. Review the specific feature planned for this session
3. Identify the files that need modification
4. Start with the simplest working version

### During Development
- **Monitor conversation length** and **auto-trigger session end protocol** when approaching limits
- **Proactively suggest fresh sessions** rather than waiting for compact mode
- **Commit frequently** with descriptive messages after each working feature
- **Test incrementally**: Verify each component works before moving forward
- **Stay focused**: Work on one specific task per session
- **Update documentation** for significant changes as you go
- **Prepare for handoffs**: Always assume the next session will be with a "fresh" Claude Code

### Ending a Session
- **Proactive ending**: End before compact mode, not after it starts
- **Complete current task**: Finish the specific feature being worked on
- **Test functionality**: Ensure what was built actually works
- **Update all planning files**:
  - `docs/CURRENT_STATE.md` with progress and specific next steps
  - `docs/SESSION_NOTES.md` with detailed session summary
- **Commit everything**: Clean commit with descriptive message
- **Clear next session goals**: Be very specific about what the next session should accomplish

## Code Style Preferences

- **Formatting**: Use Xcode's default Swift formatting
- **Line length**: Aim for under 120 characters
- **Indentation**: Use Xcode defaults (spaces)
- **Comments**: Write comments that explain "why" not "what"
- **TODO markers**: Use `// TODO:` for planned improvements
- **FIXME markers**: Use `// FIXME:` for known issues that need addressing

## Common Patterns

### View Models
```swift
class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var isLoading = false
    
    private let supabaseService: SupabaseService
    
    // Handle async operations and error states
}
```

### Supabase Operations
```swift
// Always handle API call errors and loading states
do {
    isLoading = true
    let result = try await supabaseService.insertExpense(expense)
    // Update UI with success
} catch {
    // Handle error and provide user feedback
} finally {
    isLoading = false
}
```

### SwiftUI Navigation
- Use NavigationStack for iOS 16+ compatibility
- Handle navigation state properly
- Test navigation flows thoroughly