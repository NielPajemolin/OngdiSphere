import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ongdisphere/features/auth/domain/enteties/app_user.dart';
import 'package:ongdisphere/features/auth/domain/repos/auth/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // LOGIN: Email & Password
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Fetch user data from Firestore
      DocumentSnapshot doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) throw Exception('User data not found');

      // Convert to AppUser
      AppUser user = AppUser.fromJson(doc.data() as Map<String, dynamic>);
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // REGISTER: Email & Password
  @override
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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
    } catch (e) {
      throw Exception('Register failed: $e');
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
    } catch (e) {
      return "An error occurred: $e";
    }
  }

  // DELETE ACCOUNT
  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in.');

      // Delete Firestore document
      await firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();

      await lopgout();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
