<img width="283" height="584" alt="Screenshot 2025-12-07 at 4 43 24 PM" src="https://github.com/user-attachments/assets/0bfb3f1f-a9df-492d-a01f-6dc7319d3f50" /># 📚 OngdiSphere

## Project Description

Ontrack Sphere is a dedicated mobile application designed to help students and users manage their academic and project workload efficiently. It uses a **Hybrid Storage Model** where user authentication is managed securely via **Firebase**, while core application data (subjects, tasks, and exams) is stored locally using **`shared_preferences`** for lightning-fast performance and full offline availability.

The app uses a strict **BLoC pattern** for state management, ensuring a clear separation of concerns, maintainability, and reliable state transitions across the application.

---

## 📸 FlutterFlow vs. NativeFlutter

The final application was built from scratch in native Flutter, mirroring the UI/UX design and navigation flows established in the initial prototype.

| FlutterFlow Prototype | Final Native Flutter Application |
| :---: | :---: |
| [<img width="286" height="587" alt="Screenshot 2025-12-07 at 4 38 32 PM" src="https://github.com/user-attachments/assets/04b57889-c8ae-425c-a225-765fdfa753f2" />
] | [![photo_6174639323869809548_y](https://github.com/user-attachments/assets/39228156-fbc7-40db-82a1-083a9f62e4ce)
] |
| [<img width="283" height="584" alt="Screenshot 2025-12-07 at 4 43 24 PM" src="https://github.com/user-attachments/assets/4e4faed8-2b2d-4ffa-a75d-aad7f21e46e1" />
] | [Placeholder for Final App Screenshot 2] |
| [<img width="290" height="588" alt="Screenshot 2025-12-07 at 4 45 24 PM" src="https://github.com/user-attachments/assets/ac8cc1e6-c873-4a21-835f-ec1a8d382636" />
] | [![photo_6174639323869809550_y](https://github.com/user-attachments/assets/eed04068-0545-405d-9636-a40f5b63399f)
] |


---

## ✨ Implemented Features

The application provides a full suite of tools for academic management:

### Core Functionality
* **Secure Authentication:** User registration, login, logout, and session management via **Firebase Authentication**.
* **Modular Architecture:** Uses the **BLoC pattern (`AuthCubit`)** for centralized, reactive state management.
* **Local Persistence:** Uses **`StorageService`** with `shared_preferences` for quick, offline CRUD operations on all core data.

### Data Management
* **Subject Management:** Create, list, and delete main subject containers. Deleting a subject **cascades** to remove all associated tasks and exams.
* **Task Management:** Add tasks associated with a subject, mark tasks as done, and track deadlines.
* **Exam Scheduling:** Add critical exam/assessment records with specific dates, and filter upcoming exams by subject.
* **Central Archive:** The dedicated **Done Page** lists all completed tasks and exams, allowing users to permanently clear archived records.

### UI & UX
* **Responsive Design:** Layouts adapt proportionally to various phone screen sizes using `MediaQuery`.
* **Theming:** Consistent visual identity achieved via custom `AppTheme` and `AppColors` extension.

---

## 🏃‍♀️ How to Run the Project

Follow these steps to set up and launch the application on your local machine:

### Step 1: Clone the Repository

You'll need a command-line interface (CLI) to download the code.

1.  Open your **Terminal** (macOS/Linux) or **Command Prompt/PowerShell** (Windows).
2.  Navigate to the folder where you want to save the project (e.g., your desktop or a `Projects` folder) using the `cd` command.
3.  Execute the `git clone` command, replacing the placeholder with the **Repository URL**:

    ```bash
    git clone [YOUR REPOSITORY URL HERE]
    ```

4.  Change into the newly created project directory:

    ```bash
    cd [YOUR PROJECT DIRECTORY NAME]
    ```

### Step 2: Install Dependencies and Launch

1.  **Install Dependencies:** Run the following command inside the project directory to download all necessary packages:

    ```bash
    flutter pub get
    ```

2.  **Launch the App:** Connect a physical device or start an emulator, then run the application:

    ```bash
    flutter run
    ```
The application will launch on an available emulator or connected device.

---

## 🧑‍💻 Student Information

| Name | Student ID |
| :--- | :--- |
| Pajemolin, Niel Xavier D. | 42300020 |
| Timbal, Kein Rhodman V. | 422004947 |
