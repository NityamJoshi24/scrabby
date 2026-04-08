import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrabble/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authInitProvider = FutureProvider<User>((ref)  async {
  final auth = ref.read(authServiceProvider);
  return auth.signInAnonymously();
});

final currentUserProvider = Provider<User?>((ref) {
  final auth = ref.read(authServiceProvider);
  return auth.currentUser;
});