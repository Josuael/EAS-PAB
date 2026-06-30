class CartModel {
  final String id;
  final String title;
  final int price;
  final String image;
  int quantity;

  CartModel({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['id'],
      title: map['title'],
      price: map['price'],
      image: map['image'],
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'image': image,
      'quantity': quantity,
    };
  }
}
