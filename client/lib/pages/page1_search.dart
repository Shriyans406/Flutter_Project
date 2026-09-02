// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
// import '../providers/product_provider.dart';

// /// Page 1: Product Search Page
// /// 
// /// Features:
// /// - Search box for product name
// /// - Category filter dropdown
// /// - Price sort selector
// /// - Button to navigate to listing page
// /// - Responsive layout (mobile/desktop)
// class Page1SearchScreen extends StatefulWidget {
//   const Page1SearchScreen({Key? key}) : super(key: key);

//   @override
//   State<Page1SearchScreen> createState() => _Page1SearchScreenState();
// }

// class _Page1SearchScreenState extends State<Page1SearchScreen> {
//   late TextEditingController _searchController;

//   @override
//   void initState() {
//     super.initState();
//     _searchController = TextEditingController();
    
//     // Initialize provider and fetch categories on first load
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = context.read<ProductProvider>();
//       if (provider.categories.isEmpty) {
//         provider.initialize();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width <= 600;
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('🛍️ Product Search'),
//         centerTitle: true,
//         backgroundColor: Colors.blue[700],
//         elevation: 4,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(isMobile ? 16 : 24),
//             child: Container(
//               constraints: const BoxConstraints(maxWidth: 500),
//               child: Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Title
//                       Text(
//                         'Find Products',
//                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Search Box
//                       _buildSearchBox(),
//                       const SizedBox(height: 20),

//                       // Category Filter
//                       _buildCategoryFilter(),
//                       const SizedBox(height: 20),

//                       // Sort Selector
//                       _buildSortSelector(),
//                       const SizedBox(height: 32),

//                       // View Products Button
//                       _buildViewProductsButton(context),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /// Build search input field
//   Widget _buildSearchBox() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Search Product Name',
//           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _searchController,
//           onChanged: (value) {
//             context.read<ProductProvider>().updateSearchQuery(value);
//           },
//           decoration: InputDecoration(
//             hintText: 'e.g., laptop, shirt, keyboard...',
//             prefixIcon: const Icon(Icons.search),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//           ),
//         ),
//       ],
//     );
//   }

//   /// Build category dropdown
//   Widget _buildCategoryFilter() {
//     return Consumer<ProductProvider>(
//       builder: (context, provider, _) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Category',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(height: 8),
//             if (provider.isLoading)
//               Container(
//                 height: 50,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey[300]!),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation(Colors.blue[700]),
//                     ),
//                   ),
//                 ),
//               )
//             else
//               DropdownButtonFormField<String>(
//                 value: provider.selectedCategory,
//                 isExpanded: true,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                 ),
//                 items: [
//                   const DropdownMenuItem(
//                     value: 'all',
//                     child: Text('All Categories'),
//                   ),
//                   ...provider.categories.map(
//                     (category) => DropdownMenuItem(
//                       value: category,
//                       child: Text(category),
//                     ),
//                   ),
//                 ],
//                 onChanged: (value) {
//                   if (value != null) {
//                     context.read<ProductProvider>().updateCategory(value);
//                   }
//                 },
//               ),
//           ],
//         );
//       },
//     );
//   }

//   /// Build sort selector
//   Widget _buildSortSelector() {
//     return Consumer<ProductProvider>(
//       builder: (context, provider, _) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Price Sorting',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<String>(
//               value: provider.selectedSort,
//               isExpanded: true,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               ),
//               items: const [
//                 DropdownMenuItem(
//                   value: 'asc',
//                   child: Text('Price: Low to High 📈'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'desc',
//                   child: Text('Price: High to Low 📉'),
//                 ),
//               ],
//               onChanged: (value) {
//                 if (value != null) {
//                   context.read<ProductProvider>().updateSort(value);
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   /// Build view products button
//   Widget _buildViewProductsButton(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton.icon(
//         onPressed: () {
//           // Navigate to Page 2 with search parameters
//           context.push('/products');
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blue[700],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         icon: const Icon(Icons.arrow_forward, color: Colors.white),
//         label: const Text(
//           'View Products',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }
