/*
  cubits are responsible for state management 
*/

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/features/auth/domain/enteties/app_user.dart';
import 'package:ongdisphere/features/auth/domain/repos/auth/auth_repo.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_states.dart';

class AuthCubit extends Cubit<AuthStates> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  //get current user
  AppUser? get currenUser => _currentUser;

  //check if user is authenticated
  void checkAuth() async {
    //loading..
    emit (AuthLoading());

    //get current user
    final AppUser? user = await authRepo.getCurrentUser();

    if (user != null) {

      _currentUser = user;
      emit(Autheticated(user));
    } 
    else {
      emit(Unauntenticated());
    }
  }

  //login with email and password
  Future<void> login(String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, pw);

      if (user != null) {
        _currentUser = user;
        emit(Autheticated(user));
      }
      else {
        emit(Unauntenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauntenticated());
    }
  }

  //register with email and password
  Future<void> register(String name, String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(name, email, pw);

      if (user != null) {
        _currentUser = user;
        emit(Autheticated(user));
      }
      else {
        emit(Unauntenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauntenticated());
    }
  }

  //logout
  Future<void> logout() async {
    emit (AuthLoading());
    await authRepo.lopgout();
    emit(Unauntenticated());
  }

  //forgot password
  Future<String> forgotPassword (String email) async {
    try {
      final message = await authRepo.sendPasswordResetEmail(email);
      return message;
    } catch (e) {
      return e.toString();
    }
  }

  //delete account 
  Future<void>  deleteAccount() async {
    try {
      emit(AuthLoading());
      await authRepo.deleteAccount();
      emit(Unauntenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauntenticated());
    }
  }
}