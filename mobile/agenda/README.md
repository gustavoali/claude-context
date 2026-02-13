# Agenda - Task Management App

## Overview
A Flutter-based mobile application for personal task and reminder management.

## Getting Started

### Prerequisites
- Flutter SDK 3.38.5 or higher
- Dart SDK 3.10.4 or higher
- Android Studio / VS Code with Flutter extension

### Installation
```bash
# Clone the project
cd C:\mobile\agenda

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Running Tests
```bash
flutter test
```

## Architecture

The app follows **Clean Architecture** principles with three main layers:

### Domain Layer
Contains business logic and entities. Independent of any framework.
- `TaskEntity` - Core task model
- `TaskRepository` - Repository interface

### Data Layer
Implements data sources and repository.
- `TaskModel` - Hive-compatible data model
- `TaskLocalDatasource` - Local storage with Hive
- `TaskRepositoryImpl` - Repository implementation

### Presentation Layer
UI components and state management.
- `TaskBloc` - BLoC for task state management
- `TaskListPage` - Main task list screen
- `AddTaskPage` - Create/Edit task form

## Key Features

### Task Management
- Create, read, update, delete tasks
- Set priority levels (Low, Medium, High)
- Set due dates
- Mark tasks as completed

### Filtering
- All tasks
- Pending tasks
- Completed tasks
- Today's tasks
- Overdue tasks

### Persistence
- Local storage using Hive
- No internet required
- Fast and reliable

## Dependencies

| Package | Purpose |
|---------|---------|
| flutter_bloc | State management |
| hive_flutter | Local storage |
| get_it | Dependency injection |
| equatable | Value equality |
| uuid | Unique ID generation |
| intl | Date formatting |
| flutter_local_notifications | Local notifications |

## Project Status
- **Version:** 1.0.0
- **Status:** In Development
- **Last Updated:** 2025-01-09
