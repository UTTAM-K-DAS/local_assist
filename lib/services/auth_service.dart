import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Make sure this is imported
import '../models/service_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Correct constructor call

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Error signing in: $e');
      throw e;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password, String name, String phone, String userType) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _createUserDocument(result.user!, name, email, phone, userType);
      return result;
    } catch (e) {
      print('Error registering: $e');
      throw e;
    }
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn(); // Correct method call

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth == null) {
        return null; // User cancelled the sign-in
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, // Correct property access
        idToken: googleAuth.idToken,       // Correct property access
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore, if not, create a new document
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        // You might want to get more details from Google profile for userType etc.
        // For now, setting default values.
        await _createUserDocument(userCredential.user!, googleUser!.displayName ?? '', googleUser.email, '', 'customer');
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      throw e;
    }
  }


  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String name, String email, String phone, String userType) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType,
      'profileImageUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      // Add other fields as necessary, e.g., address, bio, ratings for providers
    });
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Sign out from Google
      await _auth.signOut(); // Sign out from Firebase
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      throw e;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete user account
        await user.delete();
      }
    } catch (e) {
      print('Error deleting account: $e');
      throw e;
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } catch (e) {
      print('Error updating email: $e');
      throw e;
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      print('Error updating password: $e');
      throw e;
    }
  }

  // Check if email is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print('Error sending email verification: $e');
      throw e;
    }
  }
}