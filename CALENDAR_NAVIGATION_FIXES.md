# Calendar Screen and Navigation Fixes

## Changes Implemented

### 1. Fixed Calendar Screen Header (calendar_screen.dart)

**Problem:** Duplicate "Calendar" header - one in MainScaffold AppBar and another in CalendarScreen's own AppBar.

**Solution:** Removed the CalendarScreen's own Scaffold and AppBar. The screen now only returns the Column widget with the blue header (containing view tabs and month navigation) and calendar content. The AppBar is provided by MainScaffold.

**File:** `lib/presentation/calendar/calendar_screen.dart`

**Changes:**
- Removed `Scaffold` wrapper from CalendarScreen's build method
- Removed `AppBar` from CalendarScreen
- Screen now returns just the Column with blue header and calendar grid

**Result:**
```
┌─────────────────────────────────────┐
│ [☰] Calendar                        │  ← AppBar (only place with "Calendar")
├─────────────────────────────────────┤
│  [Month]  [Week]  [Day]             │  ← Blue header (NO duplicate "Calendar" text)
│     [<]  December 2024  [>]         │
├─────────────────────────────────────┤
│ Mon  Tue  Wed  Thu  Fri  Sat  Sun   │
│  Calendar grid...                   │
└─────────────────────────────────────┘
```

### 2. Moved Expandable Action Button to Bottom Navigation (main_scaffold.dart)

**Problem:**
- Floating action button (FAB) was shown as a separate floating element
- Bottom navigation had a separate "Quick Capture" button
- This created confusion and redundant UI elements

**Solution:**
- Removed the floating action button entirely
- Made the bottom navigation's [+] button (Quick Capture) expandable on component pages
- When tapped on Calendar, Tasks, People, etc., it shows contextual actions
- On Dashboard and Settings, it still shows the normal Quick Capture bottom sheet

**File:** `lib/presentation/main/main_scaffold.dart`

**Key Changes:**

1. **Added state management:**
   - Added `_isActionMenuOpen` boolean to track menu state

2. **Modified bottom navigation tap handler:**
   - Updated `_onBottomNavTap(int index, String location)` to accept location parameter
   - When [+] is tapped on component pages (Calendar, Tasks, etc.), it toggles the expandable menu
   - When [+] is tapped on Dashboard/Settings, it shows Quick Capture bottom sheet

3. **Wrapped Scaffold in Stack:**
   - Main Scaffold is now wrapped in a Stack
   - When `_isActionMenuOpen` is true, an overlay is shown with action options

4. **Removed floating action button:**
   - Deleted `floatingActionButton` property from Scaffold
   - Deleted `_buildActionButton()` method

5. **Added new methods:**
   - `_buildActionMenuOverlay()` - Shows semi-transparent backdrop with action options
   - `_getActionOptions()` - Returns appropriate options based on current page
   - `_buildActionOption()` - Builds individual action option buttons
   - `_handleQuickCaptureAndClose()` - Shows quick capture and closes menu

6. **Added route change listener:**
   - Menu automatically closes when user navigates to a different route
   - Uses `addPostFrameCallback` to avoid setState during build

### 3. Action Button Behavior by Page

**Dashboard:**
- [+] button shows Quick Capture bottom sheet (normal behavior)
- No expandable menu

**Settings:**
- [+] button shows Quick Capture bottom sheet (normal behavior)
- No expandable menu

**Calendar:**
- [+] button expands to show:
  - Add Event
  - Go to Today
  - Quick Capture

**Tasks:**
- [+] button expands to show:
  - Add Task
  - Quick Capture

**People:**
- [+] button expands to show:
  - Add Person
  - Quick Capture

**Sermons:**
- [+] button expands to show:
  - Add Sermon
  - Quick Capture

**Notes:**
- [+] button expands to show:
  - Add Note
  - Quick Capture

### 4. Design Details

**Action Option Buttons:**
- White background with shadow for elevation
- 8px border radius
- Icon (20px) + label layout
- Row layout with icon on left, text on right
- Minimum padding: 16px horizontal, 12px vertical
- 12px spacing between buttons

**Overlay:**
- Semi-transparent black backdrop (50% opacity)
- Positioned above bottom navigation (80px from bottom)
- Aligned to right side with 16px padding
- Tapping backdrop closes the menu

**Interaction:**
- Tapping [+] toggles menu open/closed
- Tapping an option closes menu and executes action
- Tapping backdrop closes menu
- Navigating to different route closes menu

## Files Modified

1. `lib/presentation/calendar/calendar_screen.dart`
   - Removed Scaffold wrapper
   - Removed AppBar

2. `lib/presentation/main/main_scaffold.dart`
   - Added expandable menu state management
   - Removed floating action button
   - Added overlay-based action menu
   - Modified bottom navigation tap behavior

## Testing

Build completed successfully with no errors:
```
flutter build web --no-pub
√ Built build\web
```

Static analysis passed with no issues:
```
flutter analyze lib/presentation/main/main_scaffold.dart lib/presentation/calendar/calendar_screen.dart
No issues found!
```

## Visual Result

### Before:
- Two "Calendar" headers (duplicate)
- Floating FAB on screen
- Separate Quick Capture button in bottom nav

### After:
- Single "Calendar" header in AppBar
- No floating FAB
- [+] button in bottom nav expands to show contextual actions
- Clean, integrated UI with no redundant elements

## User Experience Improvements

1. **Cleaner UI:** No duplicate headers or redundant buttons
2. **Contextual Actions:** The [+] button shows relevant actions based on the current page
3. **Consistent Navigation:** Action button is always in the same place (bottom nav)
4. **Better Discoverability:** Users can easily find page-specific actions
5. **Mobile-First Design:** Bottom navigation is easier to reach than floating FAB on larger screens
