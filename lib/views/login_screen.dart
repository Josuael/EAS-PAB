import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoginMode = true; // Toggle antara Login & Sign Up

  Future<void> _submitAuth() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        if (_isLoginMode) {
          // Proses Login
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        } else {
          // Proses Sign Up
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi Berhasil!'), backgroundColor: Colors.green));
        }
        // Catatan: Navigasi tidak diperlukan di sini karena main.dart (StreamBuilder) akan otomatis merespon perubahan status login!
      } on FirebaseAuthException catch (e) {
        String errMsg = "Terjadi kesalahan.";
        if (e.code == 'user-not-found') errMsg = "Email tidak terdaftar.";
        else if (e.code == 'wrong-password') errMsg = "Password salah.";
        else if (e.code == 'email-already-in-use') errMsg = "Email sudah digunakan.";
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errMsg), backgroundColor: Colors.red));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // AREA LOGO DARI DIGIPEDIA (Bisa ganti Image.asset nanti jika pakai file lokal)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_bag, size: 80, color: Color(0xFF0052FF)),
                ),
                const SizedBox(height: 16),
                const Text("Welcome to Digipedia!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0052FF))),
                const Text("Belanja mudah, cepat, dan terpercaya", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 40),
                
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email', 
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  validator: (value) => value!.contains('@') ? null : 'Format email salah',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  validator: (value) => value!.length < 6 ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 24),
                
                _isLoading 
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052FF), 
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      onPressed: _submitAuth,
                      child: Text(_isLoginMode ? 'Login' : 'Daftar Sekarang', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() { _isLoginMode = !_isLoginMode; });
                  },
                  child: Text(
                    _isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Login",
                    style: const TextStyle(color: Color(0xFF0052FF)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}