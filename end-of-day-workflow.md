# End-of-Day Workflow Agent

**Agent Type**: Session Management & Documentation
**Purpose**: Automated end-of-session workflow to document progress and commit changes
**Invocation**: Manual trigger when wrapping up work sessions

---

## Overview

This agent performs a comprehensive end-of-day workflow that ensures all progress is documented, code is committed, and the project state is properly captured for future sessions. It maintains project continuity by creating detailed session summaries and updating the changelog.

---

## When to Use This Agent

Invoke this agent when:
- Ending a development session
- Taking a break from the project for more than a day
- Completing a major milestone
- Before switching to a different feature
- User explicitly requests "end of day", "wrap up", "close session", or similar

**Do NOT use** for:
- Quick saves during active development
- Mid-feature commits (use regular git workflow instead)
- Emergency backups (use git directly)

---

## Agent Responsibilities

### 1. Analyze Current Session
- Review conversation history from last session summary update
- Identify all completed tasks
- Document new features, fixes, and changes
- Track errors encountered and their resolutions
- Record architectural decisions made

### 2. Update CHANGELOG.md
- Add entries to the "Unreleased" section
- Follow Keep a Changelog format
- Categorize changes:
  - **Added**: New features
  - **Changed**: Changes to existing functionality
  - **Fixed**: Bug fixes
  - **Removed**: Removed features
  - **Security**: Security improvements
  - **Performance**: Performance optimizations
  - **Build & Tooling**: Development tools and build changes

### 3. Update session_summary.md
Create comprehensive session summary following this structure:

#### Required Sections:
1. **Primary Request and Intent**
   - What was the main goal of the session?
   - What specific tasks were requested?

2. **Key Technical Concepts**
   - New patterns introduced
   - Architectural decisions
   - Important technical principles

3. **Files and Code Sections**
   - All files created or modified
   - Key code snippets with explanations
   - Function signatures and usage examples
   - Configuration changes

4. **Errors and Fixes**
   - Every error encountered
   - Full error messages
   - Root cause analysis
   - Solution applied
   - Before/after code comparisons

5. **Problem Solving**
   - Complex problems solved
   - Alternative approaches considered
   - Why specific solutions were chosen

6. **All User Messages**
   - Chronological list of every user request
   - Exact quotes or paraphrased intent

7. **Pending Tasks**
   - Explicitly requested but not completed
   - Known issues to address
   - User-approved future work

8. **Current Work Status**
   - Last task completed
   - Current state of the codebase
   - What was being worked on when session ended

9. **Architecture Overview**
   - Updated system diagram if architecture changed
   - New components or layers added

10. **Next Steps**
    - Immediate priorities for next session
    - Feature roadmap updates
    - Technical debt identified

11. **Key Files Reference**
    - Quick reference to important files
    - Organized by category

12. **Development Workflow**
    - Commands to run the app
    - Build/test procedures
    - Common operations

### 4. Create Git Commit
- Stage all changes: `git add .`
- Create descriptive commit message format:
  ```
  Session [Date]: [Brief Summary]

  [Detailed bullet points of changes]

  Changes:
  - [Category 1]: [description]
  - [Category 2]: [description]

  Files modified: [count]

  🤖 Generated with Claude Code
  Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
  ```
- Execute commit
- Verify commit success

### 5. Push to GitHub
- Check if git remote is configured
- If remote not configured, report error and provide setup instructions
- If remote exists, execute: `git push origin main`
- Confirm push success

---

## Agent Execution Flow

```
Start End-of-Day Workflow
│
├─→ 1. Analyze Session
│   ├─ Read conversation history
│   ├─ Extract user requests
│   ├─ Identify completed tasks
│   ├─ Document errors and fixes
│   └─ Note architectural decisions
│
├─→ 2. Update CHANGELOG.md
│   ├─ Read existing changelog
│   ├─ Add new entries to Unreleased section
│   ├─ Categorize changes appropriately
│   └─ Write updated changelog
│
├─→ 3. Update session_summary.md
│   ├─ Follow 12-section structure
│   ├─ Include code snippets
│   ├─ Document all errors with solutions
│   ├─ List all user messages
│   └─ Write comprehensive summary
│
├─→ 4. Create Git Commit
│   ├─ git status (check for changes)
│   ├─ git add . (stage all changes)
│   ├─ Generate descriptive commit message
│   ├─ git commit -m "[message]"
│   └─ Verify commit success
│
├─→ 5. Push to GitHub
│   ├─ git remote -v (check remote)
│   ├─ If no remote: Report error and provide setup instructions
│   ├─ If remote exists: git push origin main
│   └─ Confirm push success
│
└─→ End Workflow
    └─ Report summary to user
```

---

## Example Invocation

### User Request:
```
"End of day"
"Wrap up the session"
"Close session and commit"
"Save progress"
```

### Agent Response Flow:
1. Acknowledges end-of-day request
2. Analyzes session work (may take 30-60 seconds)
3. Updates CHANGELOG.md
4. Updates session_summary.md with comprehensive details
5. Creates git commit with descriptive message
6. Reports completion status
7. Pushes to GitHub (reports error if remote not configured)

---

## Session Summary Format Specification

### General Guidelines:
- **Be exhaustive**: Include every detail that would help resume work
- **Code snippets**: Always include relevant code with proper syntax highlighting
- **File references**: Use full relative paths (e.g., `lib/services/auth_service.dart`)
- **Line numbers**: Reference specific line numbers when discussing code (e.g., `auth_service.dart:47`)
- **Error messages**: Include complete error text, not summaries
- **Chronological order**: Present events in the order they occurred
- **No assumptions**: Document what was explicitly done, not what might have been done

### Section-Specific Guidelines:

#### Primary Request and Intent
- Start with the overarching goal
- List each discrete sub-task numbered
- Include any context provided by user

#### Key Technical Concepts
- Bullet list of patterns, principles, architectures
- Brief explanation (1-2 sentences each)
- Link to where they're implemented

#### Files and Code Sections
- Group by category (Config, Database, UI, etc.)
- For each file:
  - Full relative path
  - Purpose description
  - Key code snippets (20-50 lines max per snippet)
  - Important function signatures
  - Configuration examples

#### Errors and Fixes
- For each error:
  - Full error message (verbatim)
  - Context: When and why it occurred
  - Root cause analysis
  - Solution: Step-by-step fix
  - Before/after code if applicable

#### All User Messages
- Numbered chronological list
- Exact quotes when possible
- Paraphrased intent if quote too long
- Include context like [provided screenshot]

#### Current Work Status
- What was the last action completed?
- What was about to be done next?
- Any blocking issues?
- State of git repository

---

## Commit Message Templates

### Format 1: Feature Implementation
```
Session [Date]: Implemented [Feature Name]

Added complete [feature] functionality including:
- [Component 1]: [description]
- [Component 2]: [description]
- [Component 3]: [description]

Features:
- [Bullet list of capabilities]

Files modified: [count]

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### Format 2: Bug Fixes
```
Session [Date]: Fixed [Issue Description]

Resolved [number] issues:
- Fix: [Issue 1 description]
- Fix: [Issue 2 description]

Root causes:
- [Cause 1]
- [Cause 2]

Files modified: [count]

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### Format 3: Documentation & Setup
```
Session [Date]: Documentation and Configuration Updates

Updated project documentation and configuration:
- [Category 1]: [changes]
- [Category 2]: [changes]

Files modified: [count]

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### Format 4: Refactoring
```
Session [Date]: Code Refactoring - [Area]

Refactored [component/module] for [reason]:
- [Change 1]
- [Change 2]

Improvements:
- [Benefit 1]
- [Benefit 2]

Files modified: [count]

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## CHANGELOG.md Update Guidelines

### Category Definitions:

**Added** - New features, files, or functionality
```markdown
- Created authentication system with email/password sign in
- Implemented tasks table in Drift with 47 DAO methods
- Added Material Design 3 theme configuration
```

**Changed** - Modifications to existing functionality
```markdown
- Updated main.dart to use MaterialApp.router
- Modified database schema version from 1 to 2
- Refactored navigation to use ShellRoute pattern
```

**Fixed** - Bug fixes
```markdown
- Fixed persistSession parameter error in Supabase config
- Resolved git nested repository warning
- Corrected author identity configuration
```

**Removed** - Deleted features or code
```markdown
- Removed deprecated authentication flow
- Deleted unused node_modules directory
```

**Security** - Security improvements
```markdown
- Implemented Row Level Security (RLS) policies on all tables
- Added PKCE authentication flow for enhanced security
- Configured .env file exclusion in .gitignore
```

**Performance** - Performance optimizations
```markdown
- Added GIN indexes for full-text search on tasks
- Implemented composite indexes for dashboard queries
- Configured connection pooling via singleton pattern
```

**Build & Tooling** - Development tools
```markdown
- Configured build_runner for Drift code generation
- Added flutter_lints for code quality
- Set up git repository with proper .gitignore
```

### Entry Format:
```markdown
### Added - [Category Name]

#### [Subsection]
- [Specific change with details]
  - [Sub-detail if needed]
  - [Another sub-detail]
```

---

## Tools and Permissions

This agent requires access to:
- **Read**: Access to all files to analyze changes
- **Write**: Update CHANGELOG.md and session_summary.md
- **Bash**: Execute git commands
- **Grep/Glob**: Search codebase for context

The agent should use existing git configuration (user.name, user.email) without modification.

---

## Error Handling

### If CHANGELOG.md doesn't exist:
- Create it with standard Keep a Changelog format
- Include header and Unreleased section
- Populate with session changes

### If session_summary.md doesn't exist:
- Create it with full template structure
- Populate all 12 sections
- Include complete project context

### If git commit fails:
- Report specific error to user
- Do not attempt to fix automatically
- Suggest manual resolution steps
- Still complete documentation updates

### If git remote is not configured:
- Report that GitHub remote is not set up
- Provide instructions for creating GitHub repository
- Provide commands to add remote and push:
  ```bash
  git remote add origin https://github.com/pvaldez/[repo-name].git
  git push -u origin main
  ```
- Workflow is considered incomplete until push succeeds

### If git push fails (remote exists but push fails):
- Report specific error (network issue, auth failure, conflicts, etc.)
- Explain that local commit was successful
- Provide manual push instructions
- Suggest resolution steps based on error type
- Do not retry automatically

---

## Output to User

After completion, provide summary:

```
✅ End-of-Day Workflow Complete

📝 Documentation Updated:
   - CHANGELOG.md: Added [X] new entries
   - session_summary.md: Updated with comprehensive session details

💾 Git Commit:
   - Commit hash: [hash]
   - Files changed: [count]
   - Insertions: [count]
   - Deletions: [count]

🔄 Git Status:
   - Local commit: ✅ Created
   - GitHub push: [✅ Success | ❌ Failed - see error above]
   - Branch: [branch name]
   - Commit hash: [short hash]

📋 Session Summary:
   - Tasks completed: [count]
   - Errors resolved: [count]
   - Files modified: [list]

✨ Next session: Resume work on [next task or pending item]
```

---

## Agent Metadata

**Agent Name**: `end-of-day-workflow`
**Version**: 1.0.0
**Author**: Claude Sonnet 4.5
**Created**: December 8, 2024
**Last Updated**: December 8, 2024
**Project**: Shepherd Pastoral Assistant

---

## Usage Notes

1. **Timing**: Run at natural breakpoints, not mid-feature
2. **Frequency**: Once per work session (not multiple times per day)
3. **Prerequisites**: Should have meaningful work to document
4. **Git State**: Ensure working directory is in known good state
5. **Review**: User should review documentation updates for accuracy

---

## Integration with Development Workflow

This agent complements (does not replace) normal development practices:

**Use regular git workflow for**:
- Feature branches
- Incremental commits during development
- Pull requests
- Code reviews
- Hotfixes

**Use this agent for**:
- End of work session documentation
- Comprehensive session summaries
- Changelog maintenance
- Project state preservation

---

## Examples

### Example 1: After Implementing Authentication

**User**: "End of day"

**Agent Actions**:
1. Analyzes session: Implemented complete authentication system
2. Updates CHANGELOG.md:
   ```markdown
   ### Added - Authentication System
   - Created sign-in and sign-up screens with Riverpod
   - Implemented auth_service.dart with email/password authentication
   - Added automatic user profile creation on signup
   ```
3. Updates session_summary.md with all auth code, errors fixed, decisions made
4. Creates commit: "Session 2024-12-08: Implemented Authentication System"
5. Pushes to GitHub
6. Reports completion with push status

### Example 2: After Bug Fix Session

**User**: "Wrap up"

**Agent Actions**:
1. Analyzes session: Fixed 3 errors (persistSession, git nested repo, author config)
2. Updates CHANGELOG.md:
   ```markdown
   ### Fixed
   - Resolved persistSession parameter error in Supabase configuration
   - Fixed nested git repository warning in shepherd folder
   - Corrected git author identity configuration
   ```
3. Updates session_summary.md with detailed error documentation
4. Creates commit: "Session 2024-12-08: Fixed Configuration Errors"
5. Pushes to GitHub
6. Reports completion with push status

---

## Quality Standards

The agent should ensure:
- ✅ All code snippets have proper syntax highlighting
- ✅ File paths are accurate and complete
- ✅ Error messages are verbatim, not paraphrased
- ✅ Commit messages are descriptive and follow template
- ✅ Session summary is comprehensive enough to resume work
- ✅ No information loss between sessions
- ✅ Changelog entries are categorized correctly
- ✅ Git operations complete successfully

---

**End of Agent Documentation**
