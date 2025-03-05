import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing up with email: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Start the Google sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in process
        return null;
      }

      // Get authentication details from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a credential from the Google tokens
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // If sign-in is successful, save additional user data to Firestore
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }
      
      return userCredential;
    } catch (error) {
      print('Error signing in with Google: $error');
      rethrow;
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserToFirestore(User user) async {
    try {
      // Reference to the user document in Firestore
      final userRef = _firestore.collection('users').doc(user.uid);
      
      // Check if user already exists in Firestore
      final userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        // User doesn't exist, create new document
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
          'lastSignIn': FieldValue.serverTimestamp(),
        });
      } else {
        // User exists, update their information
        await userRef.update({
          'email': user.email,
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'lastSignIn': FieldValue.serverTimestamp(),
        });
      }
    } catch (error) {
      print('Error saving user to Firestore: $error');
    }
  }

  // Update user account type
  Future<void> updateUserAccountType(String accountType) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'accountType': accountType,
        });
      }
    } catch (error) {
      print('Error updating account type: $error');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

