# TaskManager - Design Specification

## Overview

TaskManager is a modern, intuitive task management application for macOS built with Flutter. The app follows Apple's Human Interface Guidelines and provides a seamless, native-feeling experience while leveraging Flutter's cross-platform capabilities.

## Design Philosophy

### Core Principles
- **Simplicity First**: Clean, uncluttered interface that focuses on tasks
- **Native Feel**: Follows macOS design patterns and conventions
- **Efficiency**: Optimized for power users with keyboard shortcuts and quick actions
- **Accessibility**: Full VoiceOver support and keyboard navigation
- **Consistency**: Uniform design language throughout the application

### Visual Design Language
- **Typography**: SF Pro Display font family for consistency with macOS
- **Color Palette**: System colors that adapt to light/dark mode
- **Spacing**: 8pt grid system for consistent layout
- **Animation**: Subtle, purposeful animations using macOS timing curves

## UI Component Specifications

### 1. Main Window Layout

#### Structure
```
┌─────────────────────────────────────────────────────────────┐
│ Toolbar (52px height)                                      │
├─────────────┬───────────────────────┬─────────────────────┤
│             │ Quick Entry Bar       │                     │
│ Sidebar     │ (expandable)          │ Task Detail View    │
│ (280px)     ├───────────────────────┤ (optional)          │
│             │ Task List View        │                     │
│             │                       │                     │
└─────────────┴───────────────────────┴─────────────────────┘
```

#### Dimensions
- **Minimum Window Size**: 800x600px
- **Default Window Size**: 1200x800px
- **Sidebar Width**: 280px (resizable 200-300px)
- **Detail View Width**: 400px (when visible)

### 2. Toolbar

#### Components
- **Title**: "TaskManager" (left-aligned)
- **New Task Button**: Plus icon (leading action)
- **Search Field**: 200px width, rounded corners
- **View Mode Selector**: Segmented control (List/Kanban/Calendar)
- **Filter Menu**: Dropdown with priority and status filters
- **More Actions**: Overflow menu with preferences, export, etc.

#### Styling
- **Background**: System background color
- **Height**: 52px
- **Border**: 1px bottom border with separator color
- **Typography**: System font, 13pt for labels

### 3. Sidebar

#### Smart Lists
- **Inbox**: All unorganized tasks
- **Today**: Tasks due today
- **Upcoming**: Tasks due in the next 7 days
- **Overdue**: Past due tasks (red badge)
- **Completed**: Completed tasks

#### Projects Section
- **Header**: "Projects" with add button
- **Project Items**: Color-coded with custom icons
- **Task Count**: Badge showing active task count

#### Tags Section
- **Header**: "Tags"
- **Tag Items**: Hashtag prefix with task count

#### Styling
- **Background**: Sidebar background color
- **Selection**: Blue highlight with rounded corners
- **Typography**: 13pt for items, 11pt for counts
- **Icons**: 16x16px SF Symbols

### 4. Quick Entry Bar

#### Default State
- **Icon**: Plus circle outline (blue)
- **Placeholder**: "Quick add: 'Buy groceries today #shopping @home urgent'"
- **Add Button**: Primary button (disabled when empty)

#### Expanded State
- **Suggestions**: Contextual chips for common patterns
- **Help Text**: Natural language examples
- **Close Button**: X icon to collapse

#### Natural Language Processing
- **Time Keywords**: today, tomorrow, next week, Monday, etc.
- **Priority Keywords**: urgent, high priority, low priority
- **Project References**: @work, @home, @personal
- **Tags**: #important, #quick, #shopping

### 5. Task List View

#### Header
- **Task Count**: "X tasks" with completed count
- **Filter Indicator**: Blue chip when filters active
- **Sort Menu**: Dropdown for sort options

#### Task Items
- **Checkbox**: 20x20px with completion animation
- **Priority Indicator**: 4px colored bar (left edge)
- **Content Area**: Title, description, tags, subtask progress
- **Due Date**: Contextual formatting (Today, Tomorrow, Overdue)
- **Actions**: Edit/Delete buttons on hover

#### Styling
- **Item Height**: Variable based on content
- **Padding**: 12px all around
- **Background**: White/dark with hover states
- **Border Radius**: 8px
- **Selection**: Blue border (2px)

### 6. Task Detail View

#### Header
- **Completion Toggle**: Large checkbox (24x24px)
- **Priority Bar**: 6px colored indicator
- **Title**: Large, editable text
- **Actions**: Edit toggle, close button

#### Content Sections
- **Description**: Multiline text, editable
- **Properties**: Priority, due date, effort estimates
- **Subtasks**: Nested checklist with progress
- **Tags**: Colored chips
- **Activity**: Timeline of changes

#### Styling
- **Width**: 400px fixed
- **Background**: System background
- **Border**: 1px left separator
- **Padding**: 20px

## Color Specifications

### Light Mode
- **Primary Blue**: #007AFF
- **Primary Green**: #34C759
- **Primary Red**: #FF3B30
- **Primary Orange**: #FF9500
- **Background**: #FFFFFF
- **Secondary Background**: #F2F2F7
- **Text Primary**: #000000
- **Text Secondary**: #8E8E93

### Dark Mode
- **Primary Blue**: #0A84FF
- **Primary Green**: #30D158
- **Primary Red**: #FF453A
- **Primary Orange**: #FF9F0A
- **Background**: #000000
- **Secondary Background**: #1C1C1E
- **Text Primary**: #FFFFFF
- **Text Secondary**: #8E8E93

### Priority Colors
- **Urgent**: #FF3B30 (Red)
- **High**: #FF9500 (Orange)
- **Medium**: #FFCC00 (Yellow)
- **Low**: #34C759 (Green)

## Typography Scale

### Font Family
- **Primary**: SF Pro Display
- **Fallback**: -apple-system, BlinkMacSystemFont, sans-serif

### Type Scale
- **Large Title**: 26pt, Bold (700)
- **Title 1**: 22pt, Semibold (600)
- **Title 2**: 17pt, Semibold (600)
- **Title 3**: 15pt, Semibold (600)
- **Headline**: 13pt, Semibold (600)
- **Body**: 13pt, Regular (400)
- **Callout**: 12pt, Regular (400)
- **Subheadline**: 11pt, Regular (400)
- **Footnote**: 10pt, Regular (400)
- **Caption**: 10pt, Medium (500)

## Spacing System

### Base Unit: 4px

- **4px**: Micro spacing (icon padding)
- **8px**: Small spacing (between related elements)
- **12px**: Medium spacing (component padding)
- **16px**: Large spacing (section padding)
- **20px**: XL spacing (major sections)
- **24px**: XXL spacing (page margins)
- **32px**: XXXL spacing (major layout gaps)

## Animation Specifications

### Timing Functions
- **Standard**: cubic-bezier(0.4, 0.0, 0.2, 1)
- **Decelerate**: cubic-bezier(0.0, 0.0, 0.2, 1)
- **Accelerate**: cubic-bezier(0.4, 0.0, 1, 1)

### Durations
- **Short**: 150ms (micro-interactions)
- **Medium**: 300ms (state changes)
- **Long**: 500ms (major transitions)

### Common Animations
- **Hover States**: 150ms opacity/scale changes
- **Button Press**: 100ms scale down to 0.98
- **Checkbox Toggle**: 200ms with spring curve
- **List Reordering**: 300ms position changes
- **View Transitions**: 400ms slide animations

## Accessibility Features

### Keyboard Navigation
- **Tab Order**: Logical flow through interface
- **Focus Indicators**: Clear visual focus states
- **Shortcuts**: Comprehensive keyboard shortcuts

### VoiceOver Support
- **Labels**: Descriptive labels for all interactive elements
- **Hints**: Action hints for complex interactions
- **Announcements**: Status changes and confirmations

### Visual Accessibility
- **Contrast**: WCAG AA compliance
- **Text Scaling**: Support for Dynamic Type
- **Reduced Motion**: Respect system motion preferences

## Responsive Behavior

### Window Resizing
- **Minimum Width**: 800px
- **Sidebar**: Collapsible below 1000px width
- **Detail View**: Overlay mode on narrow windows
- **Content**: Fluid layout with max-width constraints

### Content Adaptation
- **Long Text**: Ellipsis with tooltip on hover
- **Many Items**: Virtual scrolling for performance
- **Empty States**: Contextual illustrations and actions

## User Flow Diagrams

### Task Creation Flow
```
Start → Quick Entry OR New Button → 
Natural Language Processing → 
Task Created → 
Notification Feedback → 
Return to List
```

### Task Management Flow
```
Task List → 
Select Task → 
Detail View → 
Edit Properties → 
Save Changes → 
Update List View
```

### Search and Filter Flow
```
Search Input → 
Real-time Filtering → 
Results Display → 
Clear Filters → 
Full List View
```

## Implementation Notes

### Performance Considerations
- **Virtual Scrolling**: For large task lists
- **Debounced Search**: 300ms delay for search input
- **Lazy Loading**: Load task details on demand
- **Efficient Reordering**: Optimistic UI updates

### Data Persistence
- **Local Storage**: Hive database for offline capability
- **Auto-save**: Immediate persistence of changes
- **Backup**: Export/import functionality
- **Sync**: Optional iCloud integration

### Platform Integration
- **Notifications**: Native macOS notifications
- **Spotlight**: System-wide search integration
- **Menu Bar**: Optional quick access
- **Dock Badge**: Overdue task count

This design specification ensures a cohesive, professional, and user-friendly task management application that feels native to macOS while providing powerful productivity features.