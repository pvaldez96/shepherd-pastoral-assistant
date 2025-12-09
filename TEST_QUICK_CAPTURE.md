# Quick Capture Testing Guide

## Prerequisites
- Flutter app is running
- At least one person exists in the People database (for Contact Log testing)

## Test Script

### 1. Access Quick Capture
- [ ] Open the app
- [ ] Look at bottom navigation bar
- [ ] Verify 4th button (far right) shows "Quick Capture" with (+) icon
- [ ] Tap the Quick Capture button

**Expected:** Modal bottom sheet appears with type selection

### 2. Type Selection Screen
- [ ] Verify sheet has rounded top corners (16px radius)
- [ ] Verify handle bar is visible at top
- [ ] Verify close button (X) is visible in top-right
- [ ] Verify title says "Quick Capture"
- [ ] Verify subtitle says "What would you like to add?"
- [ ] Verify 4 large cards are visible:
  - Task (blue icon)
  - Event (green icon)
  - Note (orange icon)
  - Contact Log (purple icon)
- [ ] Verify each card has proper icon and label
- [ ] Verify cards are tappable (show ripple effect)

### 3. Quick Task Form
- [ ] Tap "Task" card

**Expected:** Task form appears

- [ ] Verify back arrow button is visible (top-left)
- [ ] Verify close button (X) is still visible (top-right)
- [ ] Verify title says "Quick Task"
- [ ] Verify cursor auto-focuses in Title field
- [ ] Enter task title: "Test Task from Quick Capture"
- [ ] Tap "Due Date" field
- [ ] Select tomorrow's date
- [ ] Verify date shows "Tomorrow"
- [ ] Tap "30m" duration chip
- [ ] Verify chip is selected (highlighted)
- [ ] Verify Category dropdown defaults to "Admin"
- [ ] Change category to "Sermon Prep"
- [ ] Tap "Save Task" button

**Expected:**
- [ ] Success snackbar appears (green): "Task created successfully!"
- [ ] Sheet closes automatically
- [ ] Task appears in Tasks list with correct details

**Test Back Button:**
- [ ] Open Quick Capture again
- [ ] Tap "Task" card
- [ ] Tap back arrow
- [ ] Verify returns to type selection

**Test Close Button:**
- [ ] Open Quick Capture again
- [ ] Tap "Task" card
- [ ] Tap close (X) button
- [ ] Verify sheet closes entirely

### 4. Quick Event Form
- [ ] Open Quick Capture
- [ ] Tap "Event" card

**Expected:** Event form appears

- [ ] Verify title says "Quick Event"
- [ ] Verify cursor auto-focuses in Title field
- [ ] Enter event title: "Test Meeting"
- [ ] Tap "Start Time" field
- [ ] Select date (tomorrow)
- [ ] Select time (10:00 AM)
- [ ] Verify "Start Time" shows "Tomorrow at 10:00 AM"
- [ ] Verify "End Time" automatically shows "Tomorrow at 11:00 AM" (1 hour later)
- [ ] Tap "End Time" field
- [ ] Change to 11:30 AM
- [ ] Verify Event Type defaults to "Meeting"
- [ ] Tap "Save Event" button

**Expected:**
- [ ] Success snackbar appears (green): "Event created successfully!"
- [ ] Sheet closes automatically
- [ ] Event appears in Calendar with correct details

**Test Validation:**
- [ ] Open Quick Capture → Event
- [ ] Try to save without entering title
- [ ] Verify error message: "Please enter an event title"

### 5. Quick Note Form
- [ ] Open Quick Capture
- [ ] Tap "Note" card

**Expected:** Note form appears

- [ ] Verify title says "Quick Note"
- [ ] Verify cursor auto-focuses in Content field
- [ ] Verify content field is multiline (4-6 lines visible)
- [ ] Enter note: "This is a test note from Quick Capture"
- [ ] Verify info box says "Person linking coming soon"
- [ ] Tap "Save Note" button

**Expected:**
- [ ] Success snackbar appears (orange): "Note saved! (Feature coming soon)"
- [ ] Sheet closes automatically
- [ ] Note: Since Notes module may not be fully implemented, this is expected behavior

**Test Validation:**
- [ ] Open Quick Capture → Note
- [ ] Try to save without entering content
- [ ] Verify error message: "Please enter note content"

### 6. Quick Contact Log Form
**Prerequisites:** At least one person must exist in database

- [ ] Open Quick Capture
- [ ] Tap "Contact Log" card

**Expected:** Contact Log form appears

- [ ] Verify title says "Quick Contact Log"
- [ ] Tap "Person" dropdown
- [ ] Verify list of people appears
- [ ] Select a person from the list
- [ ] Verify "Call" chip is selected by default
- [ ] Tap "Visit" chip
- [ ] Verify Visit chip becomes selected, Call is deselected
- [ ] Verify Contact Date shows "Today"
- [ ] Tap Contact Date field
- [ ] Select yesterday's date
- [ ] Verify shows "Yesterday"
- [ ] Enter notes: "Had a great conversation"
- [ ] Tap "Log Contact" button

**Expected:**
- [ ] Success snackbar appears (purple): "Contact logged successfully!"
- [ ] Sheet closes automatically
- [ ] Contact log appears in person's contact history
- [ ] Person's "Last Contact" date is updated

**Test Validation:**
- [ ] Open Quick Capture → Contact Log
- [ ] Try to save without selecting a person
- [ ] Verify error message: "Please select a person"

**Test Empty People:**
If no people exist:
- [ ] Verify message appears: "No people found. Add people first before logging contacts."

### 7. Keyboard Behavior
- [ ] Open Quick Capture → Task
- [ ] Verify keyboard appears automatically (auto-focus)
- [ ] Verify Title field is focused
- [ ] Enter text
- [ ] Tap "Next" on keyboard (or Enter)
- [ ] Verify moves to next appropriate action
- [ ] Verify keyboard doesn't cover Save button
- [ ] Scroll if needed to see Save button
- [ ] Tap outside fields
- [ ] Verify keyboard dismisses

### 8. Loading States
- [ ] Open Quick Capture → Task
- [ ] Enter title: "Loading Test"
- [ ] Tap "Save Task" button quickly
- [ ] Observe button during save:
  - [ ] Button becomes disabled (grayed out)
  - [ ] Loading spinner appears in button
  - [ ] Cannot tap button again while saving

### 9. Error Handling
This test requires temporarily breaking something (optional):
- [ ] Disconnect from internet (if using real backend)
- [ ] Try to save a task
- [ ] Verify error snackbar appears (red)
- [ ] Verify sheet stays open (doesn't close)
- [ ] Verify can try saving again

### 10. Multiple Entries
- [ ] Create 3 tasks in a row:
  - Open Quick Capture → Task → Create → Sheet closes
  - Open Quick Capture → Task → Create → Sheet closes
  - Open Quick Capture → Task → Create → Sheet closes
- [ ] Verify all 3 tasks appear in Tasks list
- [ ] Verify each save was independent and successful

### 11. Navigation Context
Test from different pages:

**From Dashboard:**
- [ ] Go to Dashboard
- [ ] Tap Quick Capture (+)
- [ ] Create a task
- [ ] Verify returns to Dashboard after save

**From Tasks Page:**
- [ ] Go to Tasks page
- [ ] Tap Quick Capture (+)
- [ ] Create a task
- [ ] Verify returns to Tasks page after save

**From Calendar Page:**
- [ ] Go to Calendar page
- [ ] Tap Quick Capture (+)
- [ ] Create an event
- [ ] Verify returns to Calendar page after save

### 12. Accessibility
- [ ] Test with screen reader enabled (if possible)
- [ ] Verify all buttons have proper labels
- [ ] Verify type selection cards have "Add [Type]" labels
- [ ] Verify form fields have proper labels
- [ ] Test with large font size setting
- [ ] Verify all text is readable and doesn't overflow

### 13. Visual Polish
- [ ] Verify colors match design system:
  - Task: Blue (#2563EB)
  - Event: Green (#10B981)
  - Note: Orange (#F59E0B)
  - Contact Log: Purple (#8B5CF6)
- [ ] Verify border radius on all elements
- [ ] Verify spacing looks consistent
- [ ] Verify no visual glitches when sheet appears/disappears
- [ ] Verify smooth animations

## Issue Reporting

If you find any issues, report them with:
1. What you did (steps to reproduce)
2. What you expected to happen
3. What actually happened
4. Screenshots if applicable
5. Device/OS information

## Common Issues and Solutions

**Issue:** Sheet doesn't open
- **Solution:** Check console for errors, verify import is correct

**Issue:** Keyboard covers Save button
- **Solution:** This is by design - scroll down to see button, or keyboard should have "Done" button

**Issue:** No people in Contact Log dropdown
- **Solution:** Go to People page and add at least one person first

**Issue:** Tasks/Events don't appear after creating
- **Solution:** Check if you're looking in the right view (filter settings, date range, etc.)

**Issue:** "Feature coming soon" for Notes
- **Solution:** This is expected - Notes module is not fully implemented yet

## Success Criteria

✅ All forms can be accessed from type selection
✅ All forms validate required fields
✅ Task form saves tasks successfully
✅ Event form saves events successfully
✅ Contact Log form saves logs successfully
✅ Note form shows appropriate "coming soon" message
✅ Success messages appear after save
✅ Sheet closes automatically after successful save
✅ Back button returns to type selection
✅ Close button dismisses sheet entirely
✅ Loading states work correctly
✅ Error handling works correctly
✅ Keyboard behavior is correct
✅ Navigation context is preserved

## Performance Check

- [ ] Sheet opens quickly (< 500ms)
- [ ] Sheet closes smoothly
- [ ] Form input is responsive
- [ ] No lag when typing
- [ ] Save operation completes in reasonable time (< 2 seconds)
- [ ] No memory leaks (test creating 20+ items)

## Final Verification

After all tests pass:
- [ ] Check Tasks list - verify test tasks exist
- [ ] Check Calendar - verify test events exist
- [ ] Check People - verify contact logs exist
- [ ] Delete test data if needed
- [ ] Verify app still runs smoothly

## Done!

If all tests pass, Quick Capture is working correctly! 🎉
