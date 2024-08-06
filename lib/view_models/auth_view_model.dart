import 'package:event_app/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;

  AuthViewModel() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    return await _authService.signIn(email, password);
  }

  Future<bool> signUp(String email, String password) async {
    return await _authService.signUp(email, password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
