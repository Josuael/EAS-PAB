import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/wallet_provider.dart';
import 'providers/cart_provider.dart';
import 'views/login_screen.dart';
import 'views/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const DigipediaApp(),
    ),
  );
}

class DigipediaApp extends StatelessWidget {
  const DigipediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digipedia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF0052FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0052FF),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const MainNavigation(); // Jika login, masuk ke Tab Navigation
          }
          return const LoginScreen(); // Jika belum, arahkan ke Login
        },
      ),
    );
  }
}