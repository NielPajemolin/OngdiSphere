# OngdiSphere Backend Setup and Firestore Export Guide

This guide explains how to:
- Configure Firebase backend for this Flutter project
- Deploy Firestore rules and indexes
- Understand the project database structure
- Export and import Firestore data for backup/migration

## 1. Prerequisites

Install these tools first:
- Flutter SDK (stable)
- Dart SDK (comes with Flutter)
- Firebase CLI
- FlutterFire CLI
- Google Cloud SDK (for managed Firestore exports)

Quick install references:
- Firebase CLI: https://firebase.google.com/docs/cli
- FlutterFire CLI: https://firebase.flutter.dev/docs/cli/
- Google Cloud SDK: https://cloud.google.com/sdk/docs/install

After installation, authenticate:

```bash
firebase login
gcloud auth login
gcloud auth application-default login
```

## 2. Connect This App to a Firebase Project

If you are using this repository as-is, the project is already linked to Firebase project id ongdisphere in firebase.json.

To connect your own Firebase project:

1. Create a Firebase project in Firebase Console.
2. From project root, run FlutterFire configure:

```bash
flutterfire configure
```

3. Select platforms you use (Android, iOS, macOS).
4. Commit generated config updates:
- lib/firebase_options.dart
- android/app/google-services.json
- ios/Runner/GoogleService-Info.plist
- macos/Runner/GoogleService-Info.plist
- firebase.json (if changed)

## 3. Install Dependencies and Verify App Startup

From project root:

```bash
flutter pub get
flutter run
```

If login and signup work, Firebase Auth and Firestore connectivity are healthy.

## 4. Firestore Security Rules and Indexes

This repository already contains:
- firestore.rules
- firestore.indexes.json

Deploy both with:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Current rules enforce:
- Only authenticated users can access data
- A user can only access documents under users/{theirUid}
- Nested collections are scoped per user:
  - users/{uid}/subjects
  - users/{uid}/tasks
  - users/{uid}/exams

## 5. Database Structure Used by the App

Top-level collection:
- users

Per-user document:
- users/{uid}

User document fields (created at signup):
- uid: string
- email: string
- name: string
- profilePictureUrl: string? (Base64 image data in current implementation)

Subcollections under each user:

1. users/{uid}/subjects/{subjectId}
- id: string
- name: string

2. users/{uid}/tasks/{taskId}
- id: string
- title: string
- subjectId: string
- subjectName: string
- dateTime: timestamp
- reminderMinutes: number
- done: boolean
- wasLate: boolean? (only present when done)

3. users/{uid}/exams/{examId}
- id: string
- title: string
- subjectId: string
- subjectName: string
- dateTime: timestamp
- reminderMinutes: number
- done: boolean
- wasLate: boolean? (only present when done)

## 6. Firestore Export (Managed Backup)

Managed export writes a full Firestore backup to a Google Cloud Storage bucket.

### 6.1 Create/choose a bucket

```bash
gsutil mb -l asia-southeast1 gs://YOUR_FIRESTORE_BACKUP_BUCKET
```

### 6.2 Grant Firestore service account write access

Replace PROJECT_ID and BUCKET:

```bash
PROJECT_ID="your-project-id"
BUCKET="gs://YOUR_FIRESTORE_BACKUP_BUCKET"
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')

gsutil iam ch \
  serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-firestore.iam.gserviceaccount.com:roles/storage.admin \
  "$BUCKET"
```

### 6.3 Export database

```bash
gcloud firestore export gs://YOUR_FIRESTORE_BACKUP_BUCKET/ongdisphere-$(date +%Y%m%d-%H%M%S) \
  --project=your-project-id
```

This creates metadata and sharded export files in your bucket.

## 7. Firestore Import (Restore)

Use a previous export folder path:

```bash
gcloud firestore import gs://YOUR_FIRESTORE_BACKUP_BUCKET/ongdisphere-YYYYMMDD-HHMMSS \
  --project=your-project-id
```

Important:
- Import is destructive for matching documents (it overwrites existing docs with imported values).
- Perform restore into a staging Firebase project first whenever possible.

## 8. Optional: Local Emulator Workflow

If you want offline/local backend testing:

1. Start Firestore emulator:

```bash
firebase emulators:start --only firestore
```

2. Connect app to emulator in debug builds (requires explicit code path in app initialization).

This project currently targets live Firebase by default.

## 9. Known Project Notes

- Current runtime repositories use Cloud Firestore (not Isar).
- Profile images are stored as Base64 in Firestore. Keep image size constrained to avoid Firestore document size limits.
- If iOS pod resolution fails for Firestore version constraints, align deployment targets and refresh pods.

## 10. Useful Backend Commands

```bash
# Validate Firebase project linkage
firebase projects:list

# Deploy only rules
firebase deploy --only firestore:rules

# Deploy only indexes
firebase deploy --only firestore:indexes

# Run Flutter app
flutter run

# Analyze code
flutter analyze
```
