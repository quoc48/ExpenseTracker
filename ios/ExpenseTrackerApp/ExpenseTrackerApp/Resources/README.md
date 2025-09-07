# Resources Directory

This directory contains app resources including assets, configuration files, and data files.

## Planned Resources

### Asset Catalogs
- `Assets.xcassets` - App icons, images, and color sets
- `Colors.xcassets` - Color definitions for theming
- `Icons.xcassets` - Custom icons and symbols

### Configuration Files
- `Info.plist` - App configuration and permissions
- `Config.plist` - Environment-specific settings
- `Supabase.plist` - Supabase configuration (non-sensitive)

### Data Files
- `DefaultCategories.json` - Default expense categories
- `SampleData.json` - Sample data for development/testing
- `Localizable.strings` - String localization (future)

### Documentation
- `PrivacyInfo.xcprivacy` - Privacy manifest (iOS 17+)
- `README.md` - Resource documentation

## Implementation Notes
- Use Asset Catalogs for all images and colors
- Keep sensitive configuration out of repository
- Use environment variables for API keys and secrets
- Organize assets by feature area when applicable
- Include proper metadata for accessibility