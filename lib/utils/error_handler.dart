import 'package:flutter/material.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    String errorString = error.toString();
    
    // Firebase Auth errors
    if (errorString.contains('user-not-found')) {
      return 'No account found with this email address';
    } else if (errorString.contains('wrong-password')) {
      return 'Incorrect password';
    } else if (errorString.contains('email-already-in-use')) {
      return 'An account with this email already exists';
    } else if (errorString.contains('weak-password')) {
      return 'Password is too weak (minimum 6 characters)';
    } else if (errorString.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (errorString.contains('network-request-failed')) {
      return 'Network error. Please check your connection';
    } else if (errorString.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later';
    }
    
    return 'An error occurred. Please try again';
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}