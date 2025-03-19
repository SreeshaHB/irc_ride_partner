import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  //Service to create new user
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final _authStatus = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return _authStatus.user;
    } on FirebaseAuthException catch (e) {
      print(e);
      String message;
      if (e.code == 'email-already-in-use') {
        message = "The email is already in use by another account.";
      } else if (e.code == 'weak-password') {
        message = "The password is too weak.";
      } else {
        message = "Registration failed. Please try again.";
      }
      // TODO
    }
    return null;
  }

  //Service to login existing users
  Future<User?> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      final _authStatus = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _authStatus.user;
    } on Exception catch (e) {
      print(e);
      // TODO
    }
    return null;
  }

  //Service to signout users

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on Exception catch(e) {
      print("Something went wrong");
    }
  }
}