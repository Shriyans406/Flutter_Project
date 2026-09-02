import 'product.dart';

/// API Response model for paginated product results
/// Handles the structured response from /api/products endpoint
class ApiResponse {
  final List<Product> products;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  /// Constructor
  ApiResponse({
    required this.products,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  /// Factory constructor to create ApiResponse from JSON
  /// Parses backend response into Dart objects
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    final productsList = json['products'] as List<dynamic>;
    
    return ApiResponse(
      products: productsList
          .map((product) => Product.fromJson(product as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      limit: json['limit'] as int,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPrevPage: json['hasPrevPage'] as bool? ?? false,
    );
  }

  /// Get empty response (for error states)
  static ApiResponse empty() {
    return ApiResponse(
      products: [],
      totalCount: 0,
      currentPage: 1,
      totalPages: 0,
      limit: 20,
      hasNextPage: false,
      hasPrevPage: false,
    );
  }

  /// Check if response has any products
  bool get isEmpty => products.isEmpty;

  /// Check if response has products
  bool get isNotEmpty => products.isNotEmpty;

  /// Copy constructor with optional overrides
  ApiResponse copyWith({
    List<Product>? products,
    int? totalCount,
    int? currentPage,
    int? totalPages,
    int? limit,
    bool? hasNextPage,
    bool? hasPrevPage,
  }) {
    return ApiResponse(
      products: products ?? this.products,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      limit: limit ?? this.limit,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPrevPage: hasPrevPage ?? this.hasPrevPage,
    );
  }

  @override
  String toString() =>
      'ApiResponse(products: ${products.length}, totalCount: $totalCount, page: $currentPage/$totalPages)';
}
