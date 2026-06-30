import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Riwayat Transaksi")),
        body: const Center(child: Text("Silakan login terlebih dahulu.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Transaksi")),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil riwayat yang spesifik hanya untuk user yang sedang login, diurutkan dari yang terbaru
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('transactions')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada riwayat transaksi."));
          }

          final transactions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final trx = transactions[index].data() as Map<String, dynamic>;
              final trxId = transactions[index].id;
              
              // Mengonversi Timestamp Firebase menjadi format tanggal yang cantik
              DateTime date = (trx['date'] as Timestamp?)?.toDate() ?? DateTime.now();
              String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF0052FF),
                    child: Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  ),
                  title: Text("Pembelian $formattedDate", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order ID: ${trxId.substring(0, 8).toUpperCase()}", style: const TextStyle(fontSize: 12)),
                        Text("${trx['items']} Barang", style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Rp ${trx['total']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0052FF))),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: Text(trx['status'] ?? 'Berhasil', style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
