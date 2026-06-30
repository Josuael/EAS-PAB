import 'dart:convert'; // Import penting untuk konversi Base64
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _imageBytes; 
  final ImagePicker _picker = ImagePicker();
  
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData(); 
  }

  // Memuat data dari Local Storage
  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Tarik Base64 dari local, kalau ada di-decode lagi jadi gambar
    String? base64Image = prefs.getString('userImage');
    
    setState(() {
      _nameController.text = prefs.getString('userName') ?? "User Digipedia";
      _ageController.text = prefs.getString('userAge') ?? "21";
      if (base64Image != null) {
        _imageBytes = base64Decode(base64Image);
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes(); 
      setState(() { 
        _imageBytes = bytes; 
      });
    }
  }

  void _removePhoto() {
    setState(() { _imageBytes = null; });
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // 1. SIMPAN KE LOCAL STORAGE
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userAge', _ageController.text);
      
      String? base64Image;
      if (_imageBytes != null) {
        // Encode foto jadi text Base64
        base64Image = base64Encode(_imageBytes!);
        await prefs.setString('userImage', base64Image);
      } else {
        await prefs.remove('userImage');
      }

      // 2. SIMPAN KE FIRESTORE DATABASE
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
          'name': _nameController.text,
          'age': _ageController.text,
          'photoBase64': base64Image, // Foto disimpan dalam bentuk teks panjang di Database
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil & Foto berhasil disimpan ke Database!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                  child: _imageBytes == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF0052FF),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(leading: const Icon(Icons.camera), title: const Text('Ambil Foto Kamera'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
                              ListTile(leading: const Icon(Icons.image), title: const Text('Pilih dari Galeri'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
                              ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('Hapus Foto', style: TextStyle(color: Colors.red)), onTap: () { Navigator.pop(context); _removePhoto(); }),
                            ],
                          )
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Umur', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password Baru (Opsional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 30),
          _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                onPressed: _saveProfile,
                child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Keluar (Log Out)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.popUntil(context, (route) => route.isFirst); 
            },
          )
        ],
      ),
    );
  }
}
