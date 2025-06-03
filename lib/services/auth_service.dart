import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseService _firebaseService = FirebaseService();

  Future<UserCredential> login(String email, String password) async {
    try {
      final userCredential = await _firebaseService.signInWithEmail(
        email,
        password,
      );

      // Update last login time
      await _firebaseService.updateUserProfile(userCredential.user!.uid, {
        'lastLogin': DateTime.now().toIso8601String(),
      });

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signup({
    required String email,
    required String password,
    required String name,
    required DateTime birthDate,
    required String gender,
  }) async {
    try {
      final userCredential = await _firebaseService.signUpWithEmail(
        email,
        password,
      );
      final userId = userCredential.user!.uid;

      // Calculate age
      final now = DateTime.now();
      final age =
          now.year -
          birthDate.year -
          (now.month < birthDate.month ||
                  (now.month == birthDate.month && now.day < birthDate.day)
              ? 1
              : 0);

      // Create user profile in Firestore with userId included
      await _firebaseService.createUserProfile(userId, {
        'userId': userId,
        'name': name,
        'email': email,
        'birthDate': birthDate.toIso8601String(),
        'gender': gender,
        'age': age,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
        'profileComplete': true,
        'accountType': 'user',
        'status': 'active',
      });

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _firebaseService.signOut();
  }

  Stream<User?> get authStateChanges => _firebaseService.authStateChanges;

  User? get currentUser => _firebaseService.currentUser;
}
