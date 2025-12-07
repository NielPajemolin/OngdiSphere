import '../../enteties/app_user.dart';

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
}