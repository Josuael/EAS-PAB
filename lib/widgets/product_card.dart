import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    int priceRp = (product['price'] * 15000).toInt(); // Konversi dollar ke rupiah
    
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Center(child: Image.network(product['image'], fit: BoxFit.contain))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title'], 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(fontSize: 13)
                ),
                const SizedBox(height: 4),
                Text(
                  "Rp $priceRp", 
                  style: const TextStyle(color: Color(0xFF0052FF), fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))
                    ),
                    onPressed: () {
                      // Masukkan ke State Keranjang
                      context.read<CartProvider>().addToCart({...product, 'price': priceRp});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Berhasil dimasukkan ke Keranjang!"),
                          duration: Duration(seconds: 1),
                        )
                      );
                    },
                    child: const Text("Beli", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
