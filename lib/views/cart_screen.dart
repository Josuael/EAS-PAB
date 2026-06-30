import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/payment_simulator.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang Belanja")),
      body: cart.items.isEmpty
          ? const Center(child: Text("Keranjang Anda masih kosong."))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: Colors.white,
                        child: ListTile(
                          leading: Image.network(item['image'], width: 50, height: 50, fit: BoxFit.contain),
                          title: Text(item['title'], maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text("Rp ${item['price']}  x${item['quantity']}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              context.read<CartProvider>().removeFromCart(item['id']);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Pembayaran", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            "Rp ${cart.totalPrice}", 
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0052FF))
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052FF),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          PaymentGatewaySimulator.processPayment(context, cart.totalPrice);
                        },
                        child: const Text("Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
