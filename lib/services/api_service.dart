import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ApiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _baseUrl = 'https://fakestoreapi.com/products';
  Future<void> syncProducts() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      List apiData = json.decode(response.body);
      for (var item in apiData) {
        await _db.collection('products').doc(item['id'].toString()).set({
          'title': item['title'],
          'price': item['price'],
          'image': item['image'],
          'category': item['category'],
          'stock': 100, // Stok awal
        }, SetOptions(merge: true));
      }
    } else {
      throw Exception('Gagal mengambil data dari API (GET)');
    }
  }
  Future<void> addProductToApi(Map<String, dynamic> productData) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      body: json.encode(productData),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("POST Berhasil: Data ditambahkan ${response.body}");
    }
  }
  Future<void> updateProductInApi(String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      body: json.encode(updatedData),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      print("PUT Berhasil: Data ID $id terupdate ${response.body}");
    }
  }
  Future<void> deleteProductFromApi(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      print("DELETE Berhasil: Data ID $id terhapus");
    }
  }
  Stream<List<ProductModel>> getProductsFromFirestore() {
    return _db.collection('products').snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => ProductModel.fromFirestore(doc.data(), doc.id)).toList()
    );
  }
}
