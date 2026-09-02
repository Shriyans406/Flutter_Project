/// Product model class
/// Represents a single product from the backend API
class Product {
  final int id;
  final String name;
  final double price;
  final String category;

  /// Constructor
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  /// Factory constructor to create Product from JSON
  /// Used when parsing API responses
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
    );
  }

  /// Convert Product to JSON (for sending to backend if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
    };
  }

  /// Copy constructor with optional overrides
  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price, category: $category)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price &&
          category == other.category;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ price.hashCode ^ category.hashCode;
}
