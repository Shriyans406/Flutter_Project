import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';

/// Product Provider
/// Manages all product-related state using Provider pattern
class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  List<String> categories = [];
  List<Product> products = [];
  int totalCount = 0;
  int currentPage = 1;
  int totalPages = 0;
  int itemsPerPage = 20;

  // Filter state
  String searchQuery = '';
  String selectedCategory = 'all';
  String selectedSort = 'asc';

  // Loading and error states
  bool isLoading = false;
  bool isFetching = false;
  String? errorMessage;

  // Pagination state
  bool hasNextPage = false;
  bool hasPrevPage = false;

  // For infinite scroll
  List<Product> allLoadedProducts = [];
  bool isLoadingMore = false;

  /// Initialize provider and fetch categories
  Future<void> initialize() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      categories = await _apiService.fetchCategories();
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to initialize: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery = query;
    currentPage = 1;
    allLoadedProducts.clear();
    notifyListeners();
  }

  /// Update selected category
  void updateCategory(String category) {
    selectedCategory = category;
    currentPage = 1;
    allLoadedProducts.clear();
    notifyListeners();
  }

  /// Update sort order
  void updateSort(String sort) {
    selectedSort = sort;
    currentPage = 1;
    allLoadedProducts.clear();
    notifyListeners();
  }

  /// Fetch products with current filters
  Future<void> fetchProducts() async {
    try {
      isFetching = true;
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _apiService.fetchProducts(
        search: searchQuery.isEmpty ? null : searchQuery,
        category: selectedCategory == 'all' ? null : selectedCategory,
        sort: selectedSort,
        page: currentPage,
        limit: itemsPerPage,
      );

      products = response.products;
      totalCount = response.totalCount;
      currentPage = response.currentPage;
      totalPages = response.totalPages;
      hasNextPage = response.hasNextPage;
      hasPrevPage = response.hasPrevPage;

      if (currentPage == 1) {
        allLoadedProducts = response.products;
      } else {
        allLoadedProducts.addAll(response.products);
      }

      isFetching = false;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to fetch products: $e';
      isFetching = false;
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load more products (infinite scroll)
  Future<void> loadMoreProducts() async {
    if (isLoadingMore || !hasNextPage) return;

    try {
      isLoadingMore = true;
      notifyListeners();

      currentPage++;
      await fetchProducts();

      isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load more: $e';
      isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Fetch single product by ID
  Future<Product?> fetchProductById(int id) async {
    try {
      return await _apiService.fetchProductById(id);
    } catch (e) {
      errorMessage = 'Failed to fetch product: $e';
      notifyListeners();
      return null;
    }
  }

  /// Reset all filters and state
  void resetFilters() {
    searchQuery = '';
    selectedCategory = 'all';
    selectedSort = 'asc';
    currentPage = 1;
    allLoadedProducts.clear();
    products.clear();
    errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
