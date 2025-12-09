# Visual Changes Guide - Navigation Refactor

## Calendar Screen Transformation

### BEFORE
```
┌─────────────────────────────────────┐
│ [☰] Calendar              [Today] ⚙ │  ← AppBar with actions
├─────────────────────────────────────┤
│                                     │
│    [<]  December 2024  [>]          │  ← Month navigation
│                                     │
├─────────────────────────────────────┤
│ Mon  Tue  Wed  Thu  Fri  Sat  Sun   │
│                                     │
│  Calendar grid content...           │
│                                     │
│                                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  [Month]   [Week]    [Day]          │  ← Bottom tabs
└─────────────────────────────────────┘
                                  [+]  ← FAB in bottom right
```

### AFTER
```
┌─────────────────────────────────────┐
│ [☰] Calendar                        │  ← Clean AppBar
├─────────────────────────────────────┤
│  [Month]  [Week]  [Day]             │  ← Tabs moved to header
│     [<]  December 2024  [>]         │  ← Month navigation
├─────────────────────────────────────┤
│ Mon  Tue  Wed  Thu  Fri  Sat  Sun   │
│                                     │
│  Calendar grid content...           │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
└─────────────────────────────────────┘
                   ┌──────────────┐
              [+] ─┤ Add Event    │  ← Expandable FAB
                   ├──────────────┤
                   │ Go to Today  │
                   ├──────────────┤
                   │ Quick Capture│
                   └──────────────┘
```

### Key Improvements
1. **Blue header consolidation**: View tabs and navigation in one unified section
2. **More vertical space**: Removed bottom tab bar, giving more room for calendar
3. **Contextual actions**: Expandable FAB shows all calendar-specific actions
4. **Cleaner AppBar**: Removed "Go to Today" button from AppBar

---

## Tasks Screen Transformation

### BEFORE
```
┌─────────────────────────────────────┐
│ [☰] Tasks                           │  ← AppBar
├─────────────────────────────────────┤
│ [All] [Today] [This Week] [By Cat.] │  ← Filter tabs
├─────────────────────────────────────┤
│                                     │
│  ▼ OVERDUE (2)                      │
│    □ Task 1                         │
│    □ Task 2                         │
│                                     │
│  ▼ TODAY (3)                        │
│    □ Task 3                         │
│    □ Task 4                         │
│    □ Task 5                         │
│                                     │
│  ▼ THIS WEEK (5)                    │
│    ...                              │
│                                     │
└─────────────────────────────────────┘
                                  [+]  ← Simple FAB
```

### AFTER
```
┌─────────────────────────────────────┐
│ [☰] Tasks                           │  ← AppBar
├─────────────────────────────────────┤
│ [All] [Today] [This Week] [By Cat.] │  ← Filter tabs
├─────────────────────────────────────┤
│                                     │
│  ▼ OVERDUE (2)                      │
│    □ Task 1                         │
│    □ Task 2                         │
│                                     │
│  ▼ TODAY (3)                        │
│    □ Task 3                         │
│    □ Task 4                         │
│    □ Task 5                         │
│                                     │
│  ▼ THIS WEEK (5)                    │
│    ...                              │
│                                     │
└─────────────────────────────────────┘
              ┌──────────────┐
         [+] ─┤ Add Task     │  ← Expandable FAB
              ├──────────────┤
              │ Quick Capture│
              └──────────────┘
```

### Key Improvements
1. **Contextual actions**: Expandable FAB distinguishes between "Add Task" and "Quick Capture"
2. **Consistent pattern**: Same expandable behavior as other pages
3. **Clear intent**: Users can see both options before choosing

---

## Expandable Action Button States

### State 1: Collapsed (Default)
```



                                  [+]  ← Main button
                                      (Blue circle, white +)
```

### State 2: Expanding (Animation)
```
                   ┌──────────────┐
              [+] ─┤ Add Event    │  ← Options appear
                   ├──────────────┤     staggered from
                   │ Go to Today  │     bottom to top
                   └──────────────┘
                                  [×]  ← Main button rotates
                                      (+ becomes ×)
```

### State 3: Expanded (Full)
```
                   ┌──────────────┐
              [+] ─┤ Add Event    │  ← All options visible
                   ├──────────────┤
                   │ Go to Today  │
                   ├──────────────┤
                   │ Quick Capture│
                   └──────────────┘
                                  [×]  ← Tappable to close
                                      (45° rotation)

     [Dark overlay fills entire screen - tap to close]
```

---

## Page-Specific Action Buttons

### Dashboard
```
Normal FAB - No expansion
           [+]  ← Opens Quick Capture sheet
```

### Calendar
```
Expandable FAB - 3 options
    [+] ─┤ Add Event
         ├ Go to Today
         └ Quick Capture
```

### Tasks
```
Expandable FAB - 2 options
    [+] ─┤ Add Task
         └ Quick Capture
```

### People
```
Expandable FAB - 2 options
    [+] ─┤ Add Person
         └ Quick Capture
```

### Sermons
```
Expandable FAB - 2 options
    [+] ─┤ Add Sermon
         └ Quick Capture
```

### Notes
```
Expandable FAB - 2 options
    [+] ─┤ Add Note
         └ Quick Capture
```

### Settings
```
No FAB
(Settings don't need quick actions)
```

---

## Animation Timeline

### Expand Animation (250ms total)
```
Time    Main Button         Option 1          Option 2          Option 3
────────────────────────────────────────────────────────────────────────
0ms     [+] (0°)            Hidden            Hidden            Hidden
        ▼

50ms    [+] (22.5°)         Appearing         Hidden            Hidden
        ▼                   (scale 0.5)

100ms   [+] (45°)           Visible           Appearing         Hidden
        ▼                   (scale 1.0)       (scale 0.5)

150ms   [×] (45°)           Visible           Visible           Appearing
                            (full)            (scale 1.0)       (scale 0.5)

250ms   [×] (45°)           Visible           Visible           Visible
        (done)              (full)            (full)            (full)
```

### Collapse Animation (250ms total)
```
Time    Main Button         Options           Backdrop
────────────────────────────────────────────────────────
0ms     [×] (45°)           All visible       Dark (40%)
        ▼                   ▼                 ▼

125ms   [+] (22.5°)         Fading out        Fading out
        ▼                   ▼                 ▼

250ms   [+] (0°)            Hidden            Transparent
        (done)              (scale 0)         (gone)
```

---

## Color Scheme

### Calendar Blue Header
```
┌─────────────────────────────────────┐
│  ████ SELECTED TAB ████             │  ← White background
│  ░░░░ Unselected ░░░░               │  ← 20% white opacity
│                                     │
│  ◄  December 2024  ►                │  ← White text & icons
└─────────────────────────────────────┘
  #2563EB (Primary Blue Background)
```

### Action Button Colors
```
Main FAB:           #2563EB (Primary Blue)
Backdrop:           #000000 at 40% opacity
Option Background:  #FFFFFF (White)
Option Text:        #374151 (Gray 800)
Option Icons:       #2563EB (Primary Blue) or custom
```

### Status Colors for Options
```
[+] Primary Action    #2563EB (Blue)
[⚠] Warning Action    #F59E0B (Orange)
[×] Danger Action     #EF4444 (Red)
[✓] Success Action    #10B981 (Green)
```

---

## Spacing and Sizing

### Calendar Blue Header
```
┌─────────────────────────────────────┐
│ ←16px→ [Tabs] ←16px→               │ ← 12px top padding
│                                     │   8px bottom padding
│ ←8px→ ◄ ←padding→ Month ←→ ► ←8px→ │ ← 12px bottom padding
└─────────────────────────────────────┘
```

### Expandable Action Button
```
Option spacing:  16px between each option
Label padding:   12px horizontal, 8px vertical
Button size:     56x56 (main), 56x56 (options)
Icon size:       24px (main), 24px (options)
Border radius:   28px (circular)
Elevation:       6 (main), 4 (options)
```

---

## Touch Targets

All interactive elements meet minimum touch target requirements:

```
Component               Size        Status
────────────────────────────────────────────
Main FAB               56x56       ✓ Exceeds 44x44
Option Button          56x56       ✓ Exceeds 44x44
Month Arrow            48x48       ✓ Exceeds 44x44
Tab Button             ~120x48     ✓ Exceeds 44x44
Filter Chip            varies      ✓ Meets minimum
```

---

## Accessibility Labels

### Calendar Screen
```
Element                 Label                    Hint
──────────────────────────────────────────────────────────────
Month Tab              "Month view"             "Double tap to switch to month view"
Week Tab               "Week view"              "Double tap to switch to week view"
Day Tab                "Day view"               "Double tap to switch to day view"
Previous Month         "Previous month"         "Double tap to go to previous month"
Next Month             "Next month"             "Double tap to go to next month"
```

### Expandable Action Button
```
Element                 Label                    Hint
──────────────────────────────────────────────────────────────
Main FAB (closed)      "Open action menu"       "Double tap to open action menu..."
Main FAB (open)        "Close menu"             "Double tap to close action menu"
Add Event Option       "Add Event"              "Double tap to add event"
Go to Today Option     "Go to Today"            "Double tap to go to today"
Quick Capture Option   "Quick Capture"          "Double tap to quick capture"
```

---

## Responsive Behavior

### Small Phones (< 360dp width)
- Button maintains 56x56 size
- Labels stay visible but may wrap
- Options stack properly with 16px spacing
- No horizontal scrolling

### Tablets (> 600dp width)
- Same layout and sizing (doesn't scale up)
- Better spacing around buttons
- More breathing room for options

### Landscape Orientation
- Button stays in bottom-right
- Options expand upward (not horizontally)
- Calendar header stays at top
- All content remains accessible

---

## Dark Mode Considerations (Future)

When implementing dark mode:

### Calendar Header
```
LIGHT MODE:                      DARK MODE:
┌──────────────────────┐        ┌──────────────────────┐
│ #2563EB (Blue)       │        │ #1E40AF (Darker Blue)│
│ White text/icons     │        │ White text/icons     │
└──────────────────────┘        └──────────────────────┘
```

### Action Button
```
LIGHT MODE:                      DARK MODE:
Main: #2563EB on white bg       Main: #3B82F6 on dark bg
Options: White cards            Options: #1F2937 cards
Labels: #374151                 Labels: #E5E7EB
```

---

## Browser/Platform Differences

### Web
- Hover states on options (subtle scale)
- Cursor changes to pointer
- Keyboard shortcuts work

### iOS
- Follows iOS design conventions
- Haptic feedback on taps
- Smooth 60fps animations

### Android
- Material Design 3 ripples
- Proper back button handling
- TalkBack support

---

## Testing Scenarios

### Visual Regression Tests
1. Calendar header with each tab selected
2. Expandable button in collapsed state
3. Expandable button during expansion
4. Expandable button fully expanded
5. All page-specific button variations

### Interaction Tests
1. Tap main button → expands
2. Tap backdrop → collapses
3. Tap option → executes action + collapses
4. Swipe calendar → month changes
5. Switch tabs → view changes

### Accessibility Tests
1. Screen reader announces all elements
2. Touch targets are adequate
3. Focus order is logical
4. High contrast mode works
5. Font scaling works (up to 200%)

---

**Legend:**
- `[+]` = Main FAB button
- `[×]` = Main FAB (rotated/close state)
- `┌─┐` = Card/container borders
- `▼` = Expanded section indicator
- `□` = Checkbox (task)
- `◄►` = Navigation arrows
- `[Tab]` = Tab button
- `░` = Semi-transparent element
- `█` = Solid element

---

**Document Version:** 1.0
**Last Updated:** December 9, 2024
**Related Files:**
- NAVIGATION_REFACTOR_SUMMARY.md
- EXPANDABLE_ACTION_BUTTON_GUIDE.md
