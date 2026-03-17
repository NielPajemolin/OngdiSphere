import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ongdisphere/features/auth/domain/enteties/app_user.dart';
import 'package:ongdisphere/features/auth/domain/repos/auth/auth_repo.dart';

class AppAuthException implements Exception {
  final String message;
  const AppAuthException(this.message);

  @override
  String toString() => message;
}

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String _mapLoginErrorCode(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
      case 'user-not-found':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Unable to log in right now. Please try again.';
    }
  }

  String _mapRegisterErrorCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      default:
        return 'Unable to create account right now. Please try again.';
    }
  }

  // LOGIN: Email & Password
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      // Fetch user data from Firestore
      DocumentSnapshot doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw const AppAuthException('User data not found for this account.');
      }

      // Convert to AppUser
      AppUser user = AppUser.fromJson(doc.data() as Map<String, dynamic>);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AppAuthException(_mapLoginErrorCode(e.code));
    } on FirebaseException {
      throw const AppAuthException(
        'Unable to fetch account data. Please try again.',
      );
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw const AppAuthException('Login failed. Please try again.');
    }
  }

  // REGISTER: Email & Password
  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      // Create AppUser object
      AppUser user = AppUser(
        uid: uid,
        email: email,
        name: name, // store name
      );

      // Save user in Firestore
      await firestore.collection('users').doc(uid).set(user.toJson());

      return user;
    } on FirebaseAuthException catch (e) {
      throw AppAuthException(_mapRegisterErrorCode(e.code));
    } on FirebaseException {
      throw const AppAuthException(
        'Unable to save user profile. Please try again.',
      );
    } catch (e) {
      throw const AppAuthException('Register failed. Please try again.');
    }
  }

  // LOGOUT
  @override
  Future<void> lopgout() async {
    await firebaseAuth.signOut();
  }

  // GET CURRENT USER
  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    // Fetch user data from Firestore
    final doc = await firestore.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists) return null;

    return AppUser.fromJson(doc.data() as Map<String, dynamic>);
  }

  // RESET PASSWORD
  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email sent! Check your email.";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-not-found':
          return 'No account found for this email.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
        default:
          return 'Unable to send reset email right now. Please try again.';
      }
    } catch (e) {
      return 'Unable to send reset email right now. Please try again.';
    }
  }

  // DELETE ACCOUNT
  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AppAuthException('No user logged in.');
      }

      // Delete Firestore document
      await firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();

      await lopgout();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AppAuthException(
          'Please log in again before deleting your account.',
        );
      }
      throw const AppAuthException(
        'Unable to delete account right now. Please try again.',
      );
    } on FirebaseException {
      throw const AppAuthException('Unable to delete account data right now.');
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw const AppAuthException(
        'Failed to delete account. Please try again.',
      );
    }
  }
}
