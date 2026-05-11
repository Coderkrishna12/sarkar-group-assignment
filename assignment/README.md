# Flutter Task Manager App — TaskMaster

A production-quality Flutter Task Manager application featuring Firebase Authentication, Cloud Firestore CRUD operations, and REST API integration. Built with clean architecture, reusable widgets, proper error handling, and a polished Material 3 UI.

---

## Features

- **Firebase Authentication** — Email/password Sign Up, Login, and Logout with full form validation and error handling
- **Task CRUD with Cloud Firestore** — Add, edit, delete, and toggle task completion, all scoped per authenticated user
- **Real-time Updates** — Live task list powered by Firestore Streams via `StreamBuilder`
- **Motivational Quote** — Random quote fetched from a REST API displayed on the Home Screen, with elegant error handling and fallback UI if the API is unreachable
- **Clean UI** — Custom Material 3 theme with Google Fonts, gradient cards, filter chips, and smooth animations
- **Proper Error Handling** — All async operations wrapped in try-catch, with loading indicators and SnackBar feedback

---

## Folder Structure

```
lib/
├── main.dart                         # App entry point, Firebase init, AuthGate, ThemeData
├── screens/
│   ├── splash_screen.dart            # Animated splash with auto-navigate
│   ├── login_screen.dart             # Email/password login with validation
│   ├── signup_screen.dart            # Full sign-up form with confirm password
│   ├── home_screen.dart              # Quote card, filter chips, task list, FAB
│   └── add_edit_task_screen.dart     # Shared add/edit task form with date picker
├── services/
│   ├── auth_service.dart             # FirebaseAuth wrapper service
│   ├── firestore_service.dart        # Firestore CRUD operations
│   └── quote_service.dart            # REST API quote fetcher
├── models/
│   └── task_model.dart               # Task data model with Firestore serialization
└── widgets/
    ├── task_card.dart                 # Reusable task display card with actions
    ├── quote_widget.dart             # Styled quote card with loading/error states
    └── custom_button.dart            # Reusable button with loading spinner
```

---

## Setup Steps

1. **Clone the repo**
   ```bash
   git clone <repo-url>
   cd assignment
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

---



## Dependencies

| Package            | Purpose                     |
| ------------------ | --------------------------- |
| `firebase_core`    | Firebase initialization     |
| `firebase_auth`    | Email/password auth         |
| `cloud_firestore`  | Firestore CRUD & streams    |
| `http`             | REST API calls              |
| `intl`             | Date formatting             |
| `google_fonts`     | Typography (Inter font)     |

---

## Firestore Data Structure

```
users/{userId}/tasks/{taskId}
  ├── title: String
  ├── description: String
  ├── date: Timestamp
  ├── isCompleted: bool
  └── userId: String
```

---
