class ProductModel {
  final String id;
  final String title;
  final double price;
  final String image;
  int stock;

  ProductModel({required this.id, required this.title, required this.price, required this.image, required this.stock});

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      id: documentId,
      title: data['title'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      stock: data['stock'] ?? 0,
    );
  }
}
