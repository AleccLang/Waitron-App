import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waitron_app/screens/Staff.dart';

// Provides authentication functions for staff
class AuthenticateService {
  final FirebaseAuth fbAuth = FirebaseAuth.instance;

  // Signs user in and if successful, routes user to staff page
  Future signIn(String email, String password, BuildContext context) async {
    try {
      await fbAuth.signInWithEmailAndPassword(email: email, password: password);
      if(fbAuth.currentUser != null){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Staff()),
        );
      }
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in error'))
      );
      return null;
    }
  }

  // Signs user out
  Future<void> signOut() async {
    await fbAuth.signOut();
  }
}
