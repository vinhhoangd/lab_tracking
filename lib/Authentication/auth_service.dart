import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('Sign in failed: $e');
      return null;
    }
  }

  Future<UserCredential?> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('Account creation failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Sign out failed: $e');
    }
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Password reset failed: $e');
    }
  }

  Future<void> updateUsername({
    required String username,
  }) async {
    try {
      if (currentUser != null) {
        await currentUser!.updateDisplayName(username);
      } else {
        debugPrint('No user is currently signed in.');
      }
    } catch (e) {
      debugPrint('Update username failed: $e');
    }
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    try {
      if (currentUser != null) {
        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);
        await currentUser!.reauthenticateWithCredential(credential);
        await currentUser!.delete();
        await firebaseAuth.signOut();
      } else {
        debugPrint('No user is currently signed in.');
      }
    } catch (e) {
      debugPrint('Delete account failed: $e');
    }
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    try {
      if (currentUser != null) {
        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: currentPassword);
        await currentUser!.reauthenticateWithCredential(credential);
        await currentUser!.updatePassword(newPassword);
      } else {
        debugPrint('No user is currently signed in.');
      }
    } catch (e) {
      debugPrint('Reset password failed: $e');
    }
  }
}