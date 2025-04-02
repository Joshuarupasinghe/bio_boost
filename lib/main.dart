import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import './screens/home.dart';
import './screens/profile_company.dart';
import './screens/sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bio Boost',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.grey[850],
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[850],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[500],
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(), // Automatically decide where to navigate

      // Named Routes
      routes: {
        '/home': (context) => const HomePage(),
        '/profile_company': (context) => const CompanyProfilePage(),
      },
    );
  }
}

// 🔹 Automatically checks if the user is signed in
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // Show loading
          );
        }

        if (snapshot.hasData) {
          return const HomePage(); // User is logged in
        }

        return const SignInPage(); // No user found, go to SignIn
      },
    );
  }
}
