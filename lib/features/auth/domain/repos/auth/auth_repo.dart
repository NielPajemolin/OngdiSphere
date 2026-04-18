import '../../entities/app_user.dart';
import 'dart:io';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailPassword(
    String email, 
    String password
  );
  Future<AppUser?> registerWithEmailPassword(
    String name, 
    String email, 
    String password
  );
  Future<void> lopgout();
  Future<AppUser?> getCurrentUser();
  Future<String> sendPasswordResetEmail(
    String email
  );
  Future<void> deleteAccount();
  Future<AppUser?> updateProfile({
    required String uid,
    String? name,
    String? profilePictureUrl,
  });
  Future<String> uploadProfilePicture(String uid, File imageFile);
}