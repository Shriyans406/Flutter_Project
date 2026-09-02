import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../models/api_response.dart';

/// API Service class
/// Handles all communication with the Node.js backend
class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal();

  /// Fetch all unique product categories
  /// Returns: List of category names (e.g., ["Electronics", "Fashion", ...])
  Future<List<String>> fetchCategories() async {
    try {
      print('🔍 Fetching categories from $baseUrl/categories');
      
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final categories = List<String>.from(json['categories'] as List);
        print('✅ Fetched ${categories.length} categories');
        return categories;
      } else {
        throw Exception('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
      rethrow;
    }
  }

  /// Fetch products with filtering, sorting, and pagination
  /// 
  /// Parameters:
  /// - search: Optional search term for product name
  /// - category: Optional category filter
  /// - sort: Optional sort order ('asc' or 'desc') for price
  /// - page: Page number (default 1)
  /// - limit: Items per page (default 20, max 100)
  /// 
  /// Returns: ApiResponse with products and pagination info
  Future<ApiResponse> fetchProducts({
    String? search,
    String? category,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🔍 Fetching products: search=$search, category=$category, sort=$sort, page=$page');
      
      // Build query parameters
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }
      if (category != null && category.isNotEmpty && category != 'all') {
        params['category'] = category;
      }
      if (sort != null && sort.isNotEmpty) {
        params['sort'] = sort;
      }

      // Build URI
      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: params);
      print('   URL: $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(json);
        print('✅ Fetched ${apiResponse.products.length} products (Page ${apiResponse.currentPage}/${apiResponse.totalPages})');
        return apiResponse;
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching products: $e');
      rethrow;
    }
  }

  /// Fetch a single product by ID
  /// 
  /// Parameters:
  /// - id: Product ID
  /// 
  /// Returns: Product object
  Future<Product> fetchProductById(int id) async {
    try {
      print('🔍 Fetching product ID: $id');
      
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final product = Product.fromJson(json);
        print('✅ Fetched product: ${product.name}');
        return product;
      } else if (response.statusCode == 404) {
        throw Exception('Product not found');
      } else {
        throw Exception('Failed to fetch product: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching product: $e');
      rethrow;
    }
  }

  /// Check server health
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('⚠️  Health check failed: $e');
      return false;
    }
  }
}
