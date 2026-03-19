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
- **Barrel Exports:** Simplified import paths through barrel files (`*.dart` re-export files), reducing import verbosity by ~60% and making the codebase more maintainable.

**User Experience:**
- **Daily Motivation:** Rotating motivational quotes displayed on the home page, fetched from an external API with local caching for offline support.
- **Responsive Design:** Adaptive layouts that work seamlessly across all device sizes using `MediaQuery`.
- **Consistent Theming:** Custom `AppTheme` and `AppColors` extension for a unified visual identity.

---

## ✨ Implemented Features

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
* **Responsive Design:** Layouts adapt proportionally to various phone screen sizes using `MediaQuery`.
* **Theming:** Consistent visual identity achieved via custom `AppTheme` and `AppColors` extension.
* **Daily Motivation:** The home page displays rotating motivational quotes from an external API with local caching support.

---

## 🗂️ Current lib Architecture

```text
lib/
├── core/
│   └── theme/
│       ├── app_theme.dart
│       ├── color_palette.dart
│       └── theme.dart
│
├── data/
│   ├── local/
│   │   └── storage_service.dart
│   ├── models/
│   │   ├── exam.dart
│   │   ├── models.dart
│   │   ├── subject.dart
│   │   └── task.dart
│   └── repositories/
│       ├── exam_repository.dart
│       ├── repositories.dart
│       ├── subject_repository.dart
│       └── task_repository.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── firebase_auth_repo.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── app_user.dart
│   │   │   └── repos/
│   │   │       └── auth/
│   │   │           └── auth_repo.dart
│   │   ├── presentation/
│   │   │   ├── cubits/
│   │   │   │   ├── auth/
│   │   │   │   │   ├── auth_cubit.dart
│   │   │   │   │   └── auth_states.dart
│   │   │   ├── pages/
│   │   │   │   ├── auth_page.dart
│   │   │   │   ├── login_page.dart
│   │   │   │   └── signup_page.dart
│   │   └── auth.dart
│   │
│   ├── done/
│   │   ├── presentation/
│   │   │   └── pages/
│   │   │       └── done_page.dart
│   │   └── done.dart
│   │
│   ├── exam/
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   │   ├── exam_bloc.dart
│   │   │   │   ├── exam_event.dart
│   │   │   │   └── exam_state.dart
│   │   │   ├── pages/
│   │   │   │   └── exam_page.dart
│   │   └── exam.dart
│   │
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── home_page.dart
│   │   └── home.dart
│   │
│   ├── profile/
│   │   ├── presentation/
│   │   │   └── pages/
│   │   │       └── profile_page.dart
│   │   └── profile.dart
│   │
│   ├── subject/
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   │   ├── subject_bloc.dart
│   │   │   │   ├── subject_event.dart
│   │   │   │   └── subject_state.dart
│   │   │   ├── pages/
│   │   │   │   └── subject_page.dart
│   │   └── subject.dart
│   │
│   └── task/
│       ├── presentation/
│       │   ├── bloc/
│       │   │   ├── task_bloc.dart
│       │   │   ├── task_event.dart
│       │   │   └── task_state.dart
│       │   ├── pages/
│       │   │   └── task_page.dart
│       └── task.dart
│
├── shared/
│   ├── animations/
│   │   ├── animated_form_dialog.dart
│   │   ├── app_routes.dart
│   │   ├── delete_confirmation_dialog.dart
│   │   ├── press_animated_fab.dart
│   │   └── press_scale.dart
│   │
│   ├── motivational_quotes/
│   │   ├── motivational_quote_section.dart
│   │   └── motivational_quotes.dart
│   │
│   └── widgets/
│       ├── add_exam_dialog.dart
│       ├── add_subject_dialog.dart
│       ├── add_task_dialog.dart
│       ├── exam_card.dart
│       ├── home_sections.dart
│       ├── loading.dart
│       ├── my_app_drawer.dart
│       ├── my_button.dart
│       ├── my_textfield.dart
│       ├── subject_card.dart
│       ├── subject_filter_dropdown.dart
│       ├── summary_header_card.dart
│       ├── task_card.dart
│       └── widgets.dart
│
├── firebase_options.dart
└── main.dart
```

---


### Available Barrel Exports

| Module | Barrel File | Exports |
| :--- | :--- | :--- |
| Auth Feature | `features/auth/auth.dart` | Firebase repo, Auth repo, AuthCubit, auth states, auth pages |
| Subject Feature | `features/subject/subject.dart` | SubjectBloc, subject page, subject widgets |
| Task Feature | `features/task/task.dart` | TaskBloc, task page, task widgets |
| Exam Feature | `features/exam/exam.dart` | ExamBloc, exam page, exam widgets |
| Home Feature | `features/home/home.dart` | Home page, home widgets |
| Done Feature | `features/done/done.dart` | Done page |
| Profile Feature | `features/profile/profile.dart` | Profile page |
| Shared Widgets | `shared/widgets/widgets.dart` | All reusable UI components, dialog/widgets, and shared animation exports |
| Motivational Quotes | `shared/motivational_quotes/motivational_quotes.dart` | MotivationalQuoteSection widget |
| Data Models | `data/models/models.dart` | Exam, Subject, Task models |
| Repositories | `data/repositories/repositories.dart` | All CRUD repositories |
| Theme | `core/theme/theme.dart` | AppTheme configuration, AppColors |
| Shared Animations | `shared/animations/app_routes.dart` | Route transitions and animation helpers |

---

## 🚀 How to Run the Project

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
