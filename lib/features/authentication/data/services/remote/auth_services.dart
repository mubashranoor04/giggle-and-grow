import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleError(e);
    }
  }

  Future<String?> signUpWithEmail(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleError(e);
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleError(e);
    }
  }

  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No account found with this Gmail.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'This Gmail is already registered.';
      case 'invalid-email': return 'The email format is invalid.';
      case 'network-request-failed': return 'Check your internet connection.';
      default: return e.message ?? "An error occurred. Please try again.";
    }
  }
}