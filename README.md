# 📚 OngdiSphere

## Project Description

OngdiSphere is a dedicated mobile application designed to help students and users manage their academic and project workload efficiently while staying motivated. Built with a **clean, feature-first architecture**, the app ensures maintainability and scalability for future enhancements.

### Key Characteristics

**Storage & Authentication:**
- **Firebase Backend:** Both user authentication and application data (subjects, tasks, and exams) are securely managed via **Firebase Authentication** and **Firestore Database**, providing real-time synchronization and cloud-based reliability.

**State Management:**
- **Strict BLoC Pattern:** Uses BLoC (`BusinessLogicComponent`) and Cubit patterns for centralized, reactive state management, ensuring clear separation of concerns and reliable state transitions across the application.

**Architecture:**
- **Feature-First Module Structure:** Codebase organized into self-contained features (`auth`, `home`, `subject`, `task`, `exam`, `profile`, `done`), shared components, and core utilities. Each feature is independent with its own data, domain, and presentation layers.
 - **Calendar Planning Module:** Added a dedicated `calendar` feature with month-view scheduling and day-level deadline visibility for tasks and exams.
- **Barrel Exports:** Simplified import paths through barrel files (`*.dart` re-export files), reducing import verbosity by ~60% and making the codebase more maintainable.

**User Experience:**
- **Daily Motivation:** Rotating motivational quotes displayed on the home page, fetched from an external API with local caching for offline support.
- **Responsive Design:** Key pages use `MediaQuery`-based breakpoints and constrained layouts for better spacing on phones, tablets, and larger screens (Home, Subjects, Tasks, Exams, Login, Sign Up, Profile, Done).
- **Consistent Theming:** Custom `AppTheme` and `AppColors` extension for a unified visual identity.
- **Dark Mode:** App-wide dark mode with persisted preference via `ThemeCubit` and `SharedPreferences`, plus contrast updates across pages/dialogs.

---

## ✨ Implemented Features

## 🌐 External APIs Used

**Motivational Quotes API:**
- The app fetches daily motivational quotes from the [Motivational Spark API](https://motivational-spark-api.vercel.app/api/quotes/random/10) to power the rotating quote feature on the Home page.
- Quotes are cached locally for offline support and to reduce API calls.

The application provides a full suite of tools for academic management:

### Core Functionality
* **Secure Authentication:** User registration, login, logout, and session management via **Firebase Authentication**.
* **Cloud Database:** All data (subjects, tasks, exams) is stored in **Firestore Database** with real-time synchronization across devices.
* **Reactive State Management:** Uses **BLoC pattern** across all features (`AuthCubit`, `SubjectBloc`, `TaskBloc`, `ExamBloc`) for centralized, reactive state management.

### Data Management
* **Subject Management:** Create, list, and delete main subject containers. Deleting a subject **cascades** to remove all associated tasks and exams.
* **Task Management:** Add tasks associated with a subject, mark tasks as done, and track deadlines.
* **Exam Scheduling:** Add critical exam/assessment records with specific dates, and filter upcoming exams by subject.
* **Central Archive:** The dedicated **Done Page** lists all completed tasks and exams, allowing users to permanently clear archived records.

### UI & UX
* **Responsive Design:** MediaQuery breakpoints are implemented on key pages (Home, Subjects, Tasks, Exams, Login, Sign Up, Profile, Done), with centered max-width content on wider displays.
* **Adaptive Home Widgets:** Home banner and overview cards switch to stacked layouts on narrower screens for better readability.
* **Theming:** Consistent visual identity achieved via custom `AppTheme` and `AppColors` extension.
* **Daily Motivation:** The home page displays rotating motivational quotes from an external API with local caching support.
* **Profile Editing Flow:** Users can edit profile info, update/remove profile photos, and capture a photo via the in-app camera page.
* **Calendar Scheduler:** Dedicated calendar page in the app drawer with monthly grid view, day tile deadline labels, selected-day agenda, quick add flow (task/exam), and edit-on-tap interactions.

### Notifications & Alerts
* **Configurable Notifications:** Users can toggle app notifications, reminder alerts, deadline alerts, and lead-time compensation in Notification Settings.
* **Task/Exam Scheduling:** Task and exam reminders are scheduled through `LocalNotificationService` with deadline and reminder behavior controls.
* **Diagnostics Support:** Notification diagnostics expose timezone, permission, and pending notification status for troubleshooting.

---

## 🗂️ Current lib Architecture

### Folder Structure & Descriptions

```text
lib/
├── core/                           # Core application configuration and utilities
│   ├── services/                   # Core services (e.g., local notifications)
│   │   └── local_notification_service.dart # App notification scheduling, settings, and diagnostics
│   └── theme/                      # Application-wide theming
│       ├── app_theme.dart          # Main theme configuration
│       ├── color_palette.dart      # Color constants and theme colors
│       ├── theme_cubit.dart        # Persisted light/dark ThemeMode state management
│       └── theme.dart              # Barrel export for theme module
│
├── data/                           # Data layer - repositories and models
│   ├── local/                      # Local storage services
│   │   └── storage_service.dart    # Local persistence (SharedPreferences, etc.)
│   ├── models/                     # Data transfer objects (DTOs)
│   │   ├── exam.dart               # Exam data model
│   │   ├── subject.dart            # Subject data model
│   │   ├── task.dart               # Task data model
│   │   └── models.dart             # Barrel export for all models
│   ├── repositories/               # Repository implementations (data access layer)
│   │   ├── exam_repository.dart    # Exam CRUD operations
│   │   ├── subject_repository.dart # Subject CRUD operations
│   │   ├── task_repository.dart    # Task CRUD operations
│   │   └── repositories.dart       # Barrel export for repositories
│   └── services/                   # Data services (API calls, Firebase)
│       └── local_notification_service.dart
│
├── features/                       # Feature-first modular architecture
│   │                              # Each feature is independent with its own layers
│   ├── auth/                       # Authentication feature
│   │   ├── data/                   # Data layer specific to auth
│   │   │   └── firebase_auth_repo.dart  # Firebase authentication implementation
│   │   ├── domain/                 # Business logic (entities and abstractions)
│   │   │   ├── entities/
│   │   │   │   └── app_user.dart   # User model entity
│   │   │   └── repos/
│   │   │       └── auth/
│   │   │           └── auth_repo.dart    # Auth repository interface
│   │   ├── presentation/           # UI layer (pages, cubits, widgets)
│   │   │   ├── cubits/
│   │   │   │   ├── auth/
│   │   │   │   │   ├── auth_cubit.dart  # Authentication state management
│   │   │   │   │   └── auth_states.dart # Auth states (authenticated, unauthenticated, loading, error)
│   │   │   ├── pages/
│   │   │   │   ├── auth_page.dart  # Authentication page
│   │   │   │   ├── login_page.dart # Login UI
│   │   │   │   └── signup_page.dart# Sign-up UI
│   │   └── auth.dart               # Barrel export for auth feature
│   │
│   ├── done/                       # Archive/Done feature
│   │   ├── presentation/           # UI layer
│   │   │   └── pages/
│   │   │       └── done_page.dart  # View all completed tasks and exams
│   │   └── done.dart               # Barrel export
│   │
│   ├── calendar/                   # Calendar scheduling feature
│   │   ├── presentation/           # UI layer
│   │   │   └── pages/
│   │   │       └── calendar_page.dart # Month calendar with day agenda and deadline actions
│   │   └── calendar.dart           # Barrel export
│   │
│   ├── exam/                       # Exam management feature
│   │   ├── presentation/           # UI layer (no separate data/domain for this feature)
│   │   │   ├── bloc/
│   │   │   │   ├── exam_bloc.dart  # Exam state management
│   │   │   │   ├── exam_event.dart # Exam events (add, edit, delete, load)
│   │   │   │   └── exam_state.dart # Exam states (loading, success, error)
│   │   │   ├── pages/
│   │   │   │   └── exam_page.dart  # Exam list, filter, and management UI
│   │   └── exam.dart               # Barrel export
│   │
│   ├── home/                       # Home dashboard feature
│   │   ├── presentation/           # UI layer
│   │   │   ├── pages/
│   │   │   │   ├── home_page.dart  # Main dashboard with overview cards
│   │   │   │   └── notification_settings_page.dart # Notification settings
│   │   └── home.dart               # Barrel export
│   │
│   ├── profile/                    # User profile feature
│   │   ├── presentation/           # UI layer
│   │   │   ├── pages/
│   │   │   │   └── profile_page.dart    # User profile display and editing
│   │   │   └── widgets/
│   │   │       ├── edit_profile_dialog.dart # Profile edit dialog with image upload
│   │   │       └── profile_camera_capture_page.dart # In-app camera capture flow for profile photo updates
│   │   └── profile.dart            # Barrel export
│   │
│   ├── subject/                    # Subject management feature
│   │   ├── presentation/           # UI layer
│   │   │   ├── bloc/
│   │   │   │   ├── subject_bloc.dart    # Subject state management
│   │   │   │   ├── subject_event.dart   # Subject events
│   │   │   │   └── subject_state.dart   # Subject states
│   │   │   ├── pages/
│   │   │   │   └── subject_page.dart    # Subject list and management UI
│   │   └── subject.dart            # Barrel export
│   │
│   └── task/                       # Task management feature
│       ├── presentation/           # UI layer
│       │   ├── bloc/
│       │   │   ├── task_bloc.dart  # Task state management
│       │   │   ├── task_event.dart # Task events (add, edit, delete, toggle done)
│       │   │   └── task_state.dart # Task states
│       │   ├── pages/
│       │   │   └── task_page.dart  # Task list, filter, and management UI
│       └── task.dart               # Barrel export
│
├── shared/                         # Shared components and utilities (used across features)
│   ├── animations/                 # Reusable animation components
│   │   ├── animated_form_dialog.dart    # Dialog with entry animation
│   │   ├── app_routes.dart              # Route navigation and slide transitions
│   │   ├── delete_confirmation_dialog.dart # Reusable delete confirmation dialog
│   │   ├── press_animated_fab.dart      # FAB press animation
│   │   ├── press_scale.dart             # Scale/press animation for buttons
│   │   └── animations.dart              # Barrel export
│   │
│   ├── motivational_quotes/        # Motivational quote feature
│   │   ├── motivational_quote_section.dart # Quote widget
│   │   ├── motivational_quotes.dart        # Quote service/logic
│   │   └── motivational_quotes.dart        # Barrel export
│   │
│   └── widgets/                    # Reusable UI widgets
│       ├── add_exam_dialog.dart    # Dialog for adding/editing exams
│       ├── add_subject_dialog.dart # Dialog for adding subjects
│       ├── add_task_dialog.dart    # Dialog for adding/editing tasks
│       ├── app_section_card.dart   # Reusable section card container
│       ├── card_action_buttons.dart# Shared edit/delete buttons
│       ├── dialog_action_buttons.dart # Shared cancel/confirm buttons
│       ├── empty_state_widget.dart # Reusable empty state UI
│       ├── exam_card.dart          # Exam item card
│       ├── home_sections.dart      # Home page section components
│       ├── kuromi_accents.dart     # Kuromi theme accent elements
│       ├── kuromi_page_background.dart # Page background styling
│       ├── loading.dart            # Loading indicator
│       ├── my_app_drawer.dart      # Main app navigation drawer
│       ├── my_button.dart          # Custom button styling
│       ├── my_textfield.dart       # Custom text input field
│       ├── status_badge.dart       # Reusable completed/pending badge
│       ├── subject_card.dart       # Subject item card
│       ├── subject_filter_dropdown.dart # Filter dropdown for subjects
│       ├── summary_header_card.dart    # Section header card
│       ├── task_card.dart          # Task item card
│       └── widgets.dart            # Barrel export for all widgets
│
├── firebase_options.dart           # Firebase configuration (auto-generated)
└── main.dart                       # Application entry point
```

### Architecture Layers Explained

| Layer | Purpose | Location |
| :--- | :--- | :--- |
| **Presentation** | UI components, state management (BLoC/Cubit), pages, dialogs | `features/*/presentation/` |
| **Domain** | Business logic, entities, repository interfaces | `features/*/domain/` |
| **Data** | Repository implementations, models, local/remote data sources | `features/*/data/` or `data/` |
| **Shared** | Reusable animations, widgets, and utilities | `shared/` |
| **Core** | App-wide configuration (theme, services) | `core/` |


### Available Barrel Exports

| Module | Barrel File | Exports |
| :--- | :--- | :--- |
| Auth Feature | `features/auth/auth.dart` | Firebase repo, Auth repo, AuthCubit, auth states, auth pages |
| Subject Feature | `features/subject/subject.dart` | SubjectBloc, subject page, subject widgets |
| Task Feature | `features/task/task.dart` | TaskBloc, task page, task widgets |
| Exam Feature | `features/exam/exam.dart` | ExamBloc, exam page, exam widgets |
| Home Feature | `features/home/home.dart` | Home page, home widgets |
| Calendar Feature | `features/calendar/calendar.dart` | Calendar page |
| Done Feature | `features/done/done.dart` | Done page |
| Profile Feature | `features/profile/profile.dart` | Profile page |
| Shared Widgets | `shared/widgets/widgets.dart` | All reusable UI components, dialog/widgets, and shared animation exports |
| Motivational Quotes | `shared/motivational_quotes/motivational_quotes.dart` | MotivationalQuoteSection widget |
| Data Models | `data/models/models.dart` | Exam, Subject, Task models |
| Repositories | `data/repositories/repositories.dart` | All CRUD repositories |
| Theme | `core/theme/theme.dart` | AppTheme configuration, AppColors, ThemeCubit |
| Shared Animations | `shared/animations/app_routes.dart` | Route transitions and animation helpers |

---

## Packages & Plugins Used

### Core & State Management
| Package | Version | Purpose |
| :--- | :--- | :--- |
| **flutter_bloc** | ^9.1.1 | State management using BLoC pattern for centralized, reactive state |
| **equatable** | ^2.0.5 | Value equality for BLoC states and events comparison |

### Firebase & Backend
| Package | Version | Purpose |
| :--- | :--- | :--- |
| **firebase_core** | ^4.2.1 | Firebase initialization and core functionality |
| **firebase_auth** | ^6.1.2 | User authentication (login, signup, password reset) |
| **cloud_firestore** | ^6.1.0 | Real-time cloud database for storing subjects, tasks, exams, and user data |

### Local Storage & Preferences
| Package | Version | Purpose |
| :--- | :--- | :--- |
| **shared_preferences** | ^2.1.1 | Local persistent storage for app preferences and settings |

### Utilities & Helpers
| Package | Version | Purpose |
| :--- | :--- | :--- |
| **uuid** | ^3.0.7 | Generate unique IDs for subjects, tasks, and exams |
| **intl** | ^0.19.0 | Internationalization and date/time formatting |
| **http** | ^1.6.0 | HTTP requests for fetching motivational quotes from Motivational Spark API |

### UI & Notifications
| Package | Version | Purpose |
| :--- | :--- | :--- |
| **cupertino_icons** | ^1.0.8 | iOS-style icons for iOS platform |
| **flutter_native_splash** | ^2.4.7 | Native splash screens on app launch |
| **flutter_launcher_icons** | ^0.14.4 | App icon generation for Android and iOS |
| **flutter_local_notifications** | ^19.4.1 | Local push notifications for task and exam reminders |
| **camera** | ^0.10.5 | In-app camera preview and image capture for profile photo updates |
| **camera_android_camerax** | ^0.7.1+2 | CameraX implementation for Android camera integration |
| **table_calendar** | ^3.1.2 | Interactive monthly calendar grid for task and exam deadline planning |

### Date/Time & Timezone
| Package | Version | Purpose |
| :--- | :--- | :--- |
| **timezone** | ^0.10.1 | Timezone utilities for handling different time zones |
| **flutter_timezone** | ^4.1.1 | Get device timezone information |

### Media & Image Handling
| Package | Version | Purpose |
| :--- | :--- | :--- |
| **image_picker** | ^1.1.2 | Pick images from camera or gallery for profile pictures |
| **image** | ^4.5.4 | Post-processing of captured images (e.g., front-camera normalization) |

### Development Tools
| Package | Version | Purpose |
| :--- | :--- | :--- |
| **flutter_lints** | ^6.0.0 | Linting rules for code quality and style consistency |
| **build_runner** | ^2.4.6 | Code generation and build automation |

---

Follow these steps to set up and launch the application on your local machine:

### Step 1: Clone the Repository

You'll need a command-line interface (CLI) to download the code.

1. Open your **Terminal** (macOS/Linux) or **Command Prompt/PowerShell** (Windows).
2. Navigate to the folder where you want to save the project (e.g., your desktop or a `Projects` folder) using the `cd` command.
3. Execute the `git clone` command:

   ```bash
   git clone https://github.com/NielPajemolin/OngdiSphere.git
   ```

4. Change into the newly created project directory:

   ```bash
   cd OngdiSphere
   ```

### Step 2: Install Dependencies and Launch

1. **Install Dependencies:** Run the following command inside the project directory to download all necessary packages:

   ```bash
   flutter pub get
   ```

2. **Launch the App:** Connect a physical device or start an emulator, then run the application:

   ```bash
   flutter run
   ```

The application will launch on an available emulator or connected device.

---

## 📱 Technology Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **State Management** | BLoC / Cubit | Reactive, centralized state management |
| **Authentication** | Firebase Authentication | Secure user login and registration |
| **Database** | Firestore | Cloud-based real-time data storage and synchronization |
| **UI Framework** | Flutter | Cross-platform mobile UI |
| **Routing** | Navigator 2.0 | Named route navigation |
| **HTTP** | http package | API calls for motivational quotes |

---

## 🧑‍💻 Student Information

| Name | Student ID |
| :--- | :--- |
| Pajemolin, Niel Xavier D. | 423000020 |
| Timbal, Kein Rhodman V. | 422004947 |
