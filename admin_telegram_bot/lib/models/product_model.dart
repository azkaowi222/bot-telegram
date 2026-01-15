class ProductModel {
  final String? id;
  final String name;
  final num balance;
  final num price;
  final num? stock;
  final String category;
  final bool isActive;
  final String imgPath;
  final String? createAt;
  final String? description;

  const ProductModel({
    this.id,
    required this.name,
    required this.balance,
    required this.price,
    required this.category,
    required this.isActive,
    required this.imgPath,
    this.stock,
    this.createAt,
    this.description,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // debugPrint(json.toString());
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'],
      balance: json['balance'],
      price: json['price'],
      stock: json['stock'] ?? 0,
      category: json['category'],
      isActive: json['isActive'],
      description: json['description'] ?? 'no description',
      imgPath: json['image_path'],
      createAt: json['createAt'].toString(),
    );
  }

}
