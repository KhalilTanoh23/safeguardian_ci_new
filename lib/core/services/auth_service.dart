import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  AuthService();

  Future<bool> isLoggedIn() async => false;
  Future<void> signOut() async {}
}
