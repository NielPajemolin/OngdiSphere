import 'package:ongdisphere/features/auth/domain/enteties/app_user.dart';

abstract class AuthStates {}

//initial
class AuthInitial extends AuthStates {}

//loading
class AuthLoading extends AuthStates {}

//authenticated
class Autheticated extends AuthStates {
  final AppUser user;
  Autheticated(this.user);
}

//unauntheticated
class Unauntenticated extends AuthStates {}

//errors..
class AuthError extends AuthStates {
  final String message;
  AuthError(this.message);
}