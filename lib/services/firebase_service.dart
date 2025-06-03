import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication methods
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // User data methods
  Future<void> createUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('users').doc(userId).set(data);
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // Health data methods
  Future<void> saveHealthData(String userId, Map<String, dynamic> data) async {
    final userRef = _firestore.collection('users').doc(userId);
    final healthRef = userRef.collection('health_data');

    await healthRef.add({...data, 'timestamp': FieldValue.serverTimestamp()});
  }

  Future<List<Map<String, dynamic>>> getHealthData(String userId) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('health_data')
            .orderBy('timestamp', descending: true)
            .limit(7)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Storage methods
  Future<String> uploadProfileImage(String userId, String filePath) async {
    final ref = _storage.ref().child('profile_images/$userId.jpg');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  // Error handling
  Exception _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return Exception('No user found with this email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'email-already-in-use':
          return Exception('Email is already registered.');
        case 'invalid-email':
          return Exception('Invalid email address.');
        case 'weak-password':
          return Exception('Password is too weak.');
        default:
          return Exception('Authentication failed: ${error.message}');
      }
    }
    return Exception('An unexpected error occurred.');
  }

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  Future<void> resetUserData(String userId) async {
    try {
      // Get today's date in YYYY-MM-DD format
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Reset daily stats
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_stats')
          .doc(dateStr)
          .set({
            'energy': 0,
            'energyLevel': 0,
            'sleep': 0,
            'water': 0,
            'work': 0,
            'reading': 0,
            'meditation': 0,
            'exercise': 0,
            'social': 0,
            'creativity': 0,
            'intentions': [],
            'gratitude': [],
            'date': dateStr,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      // Reset metrics
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('metrics')
          .doc(dateStr)
          .set({
            'sleep': 0,
            'water': 0,
            'work': 0,
            'reading': 0,
            'meditation': 0,
            'exercise': 0,
            'social': 0,
            'creativity': 0,
            'date': dateStr,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to reset user data: $e');
    }
  }
}
