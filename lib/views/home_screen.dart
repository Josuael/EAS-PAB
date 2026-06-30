import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/wallet_provider.dart';
import '../widgets/product_card.dart';
import '../services/api_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digipedia", style: TextStyle(fontWeight: FontWeight.bold)),
        // Ikon navigasi dihapus karena sudah dipindah ke MainNavigation (Bottom Tab)
      ),
      body: Column(
        children: [
          _buildWalletCard(context), // WIDGET E-WALLET DENGAN INPUT TOP UP
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                
                // JIKA DATABASE KOSONG, TAMPILKAN TOMBOL TARIK API!
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_download_outlined, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text("Katalog Produk masih kosong.", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0052FF)),
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menarik data dari FakeStore API...')));
                            try {
                              await ApiService().syncProducts();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil disinkronisasi!'), backgroundColor: Colors.green));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                            }
                          },
                          icon: const Icon(Icons.sync, color: Colors.white),
                          label: const Text("Tarik Katalog dari Web API", style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  );
                }
                
                final products = snapshot.data!.docs;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index].data() as Map<String, dynamic>;
                    product['id'] = products[index].id; 
                    return ProductCard(product: product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5)],
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Color(0xFF0052FF)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("DigiPay", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Row(
                    children: [
                      Text(
                        wallet.isHidden ? "Rp •••••••" : "Rp ${wallet.balance}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => context.read<WalletProvider>().toggleVisibility(),
                        child: Icon(wallet.isHidden ? Icons.visibility_off : Icons.visibility, size: 16, color: Colors.grey),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _showTopUpDialog(context),
            child: const Text("Top Up", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // DIALOG KUSTOM UNTUK MEMILIH NOMINAL TOP UP
  void _showTopUpDialog(BuildContext context) {
    final nominalController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Top Up Saldo"),
        content: TextField(
          controller: nominalController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Masukkan Nominal (Rp)", prefixText: "Rp ", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0052FF)),
            onPressed: () {
              if(nominalController.text.isNotEmpty) {
                int amount = int.parse(nominalController.text);
                context.read<WalletProvider>().topUp(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Top Up Rp $amount Berhasil!'), backgroundColor: Colors.green));
              }
            },
            child: const Text("Top Up Sekarang", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}