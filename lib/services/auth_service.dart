import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;

  Future<User> signInAnonymously() async {
    if(_auth.currentUser != null) return _auth.currentUser!;
    final result = await _auth.signInAnonymously();
    return result.user!;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}