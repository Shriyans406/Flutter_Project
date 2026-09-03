import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

/// Page 2: Product Listing Page
///
/// Features:
/// - Live search, category filter, sort selector at top
/// - Automatic updates when filters change (300ms debounce)
/// - Responsive grid (desktop) / list (mobile) layout
/// - Infinite scroll pagination
/// - Loading and empty state indicators
class Page2ListingScreen extends StatefulWidget {
  const Page2ListingScreen({Key? key}) : super(key: key);

  @override
  State<Page2ListingScreen> createState() => _Page2ListingScreenState();
}

class _Page2ListingScreenState extends State<Page2ListingScreen> {
  final ScrollController _scrollController = ScrollController();
  late Future<void> _initialFetch;

  @override
  void initState() {
    super.initState();

    // Fetch products on first load
    _initialFetch = WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    }).then((_) => Future.value());

    // Setup infinite scroll listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle scroll to load more products
  void _onScroll() {
    final provider = context.read<ProductProvider>();

    // If user scrolled near bottom, load more products
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (!provider.isLoadingMore && provider.hasNextPage) {
        provider.loadMoreProducts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Products'),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Filter Header (Sticky)
              _buildFilterHeader(context, isMobile),

              // Products List/Grid
              Expanded(
                child: _buildProductsList(context, isMobile, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build filter header with search, category, sort
  Widget _buildFilterHeader(BuildContext context, bool isMobile) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return Container(
          color: Colors.grey[100],
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            spacing: 12,
            children: [
              // Search box
              TextField(
                onChanged: (value) {
                  provider.updateSearchQuery(value);
                  // Trigger fetch after 300ms debounce
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) provider.fetchProducts();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              // Category & Sort Row
              if (!isMobile)
                Row(
                  spacing: 12,
                  children: [
                    Expanded(child: _buildCategoryDropdown(context, provider)),
                    Expanded(child: _buildSortDropdown(context, provider)),
                  ],
                )
              else
                Column(
                  spacing: 10,
                  children: [
                    _buildCategoryDropdown(context, provider),
                    _buildSortDropdown(context, provider),
                  ],
                ),

              // Results info
              Text(
                provider.isFetching
                    ? 'Loading...'
                    : 'Showing ${provider.products.length} of ${provider.totalCount} products',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build category dropdown
  Widget _buildCategoryDropdown(
      BuildContext context, ProductProvider provider) {
    return DropdownButtonFormField<String>(
      value: provider.selectedCategory,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      items: [
        const DropdownMenuItem(value: 'all', child: Text('All Categories')),
        ...provider.categories.map(
          (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          provider.updateCategory(value);
          provider.fetchProducts();
        }
      },
    );
  }

  /// Build sort dropdown
  Widget _buildSortDropdown(BuildContext context, ProductProvider provider) {
    return DropdownButtonFormField<String>(
      value: provider.selectedSort,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      items: const [
        DropdownMenuItem(value: 'asc', child: Text('Low to High 📈')),
        DropdownMenuItem(value: 'desc', child: Text('High to High 📉')),
      ],
      onChanged: (value) {
        if (value != null) {
          provider.updateSort(value);
          provider.fetchProducts();
        }
      },
    );
  }

  /// Build products list/grid
  Widget _buildProductsList(
    BuildContext context,
    bool isMobile,
    ProductProvider provider,
  ) {
    // Show loading on first load
    if (provider.isLoading && provider.allLoadedProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.blue[700])),
            const SizedBox(height: 16),
            const Text('Loading products...'),
          ],
        ),
      );
    }

    // Show error
    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${provider.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchProducts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show no products found
    if (provider.allLoadedProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No products found'),
            const SizedBox(height: 8),
            const Text('Try adjusting your filters',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Build grid or list based on screen size
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: isMobile ? 8 : 12,
        mainAxisSpacing: isMobile ? 8 : 12,
        childAspectRatio: 0.7,
      ),
      itemCount:
          provider.allLoadedProducts.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= provider.allLoadedProducts.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final product = provider.allLoadedProducts[index];
        return _buildProductCard(context, product);
      },
    );
  }

  /// Build individual product card
  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        // Navigate to Page 3 with product data
        context.push('/product/${product.id}', extra: product);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Center(
                  child: Icon(
                    Icons.shopping_bag,
                    size: 40,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ),

            // Product details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Category badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
