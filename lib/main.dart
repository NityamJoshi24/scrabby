import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrabble/providers/auth_provider.dart';
import 'package:scrabble/screens/home_screen.dart';
import 'package:scrabble/services/dictionary_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final dictionary = DictionaryService();
  await dictionary.load();
  runApp(const ProviderScope(child: ScrabbleApp()));
}

class ScrabbleApp extends ConsumerWidget {
  const ScrabbleApp({super.key});

  static const Color _seedColor = Color(0xFFB9824F);
  static const Color _scaffoldColor = Color(0xFFF6E7D0);
  static const Color _appBarColor = Color(0xFFE7C69B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authInitProvider);
    return MaterialApp(
      title: 'Scrabble Online',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: _scaffoldColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: _appBarColor,
          foregroundColor: Color(0xFF3E2818),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: auth.when(
          data: (_) => const HomeScreen(),
          error: (e, _) => Scaffold(
        body: Center(child: Text('Auth Error: $e'),),
      ), loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator(),),
      ))
    );
  }
}
