import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/wallet_provider.dart';
import '../providers/cart_provider.dart';

class PaymentGatewaySimulator {
  static void processPayment(BuildContext context, int totalAmount) {
    final wallet = context.read<WalletProvider>();
    final cart = context.read<CartProvider>();

    if (wallet.balance < totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saldo DigiPay tidak cukup! Silakan Top Up.'), backgroundColor: Colors.red));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF0052FF)),
            SizedBox(height: 16),
            Text("Memproses Pembayaran DigiPay..."),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () async {
      Navigator.pop(context); 

      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && cart.items.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('transactions')
              .add({
            'date': FieldValue.serverTimestamp(), 
            'total': totalAmount,
            'items': cart.items.length,
            'status': 'Berhasil',
          });
        }

        wallet.pay(totalAmount);
        cart.clearCart();

        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                const Text("Pembayaran Berhasil!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0052FF)),
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), 
                    child: const Text("Kembali ke Beranda", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    });
  }
}
