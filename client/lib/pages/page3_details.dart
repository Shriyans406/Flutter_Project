// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
// import '../providers/product_provider.dart';
// import '../models/product.dart';

// /// Page 3: Product Details Page
// /// 
// /// Features:
// /// - Display product details (id, name, price, category)
// /// - Smart loading (use passed data if available, fetch otherwise)
// /// - Back navigation
// /// - Clean responsive layout
// class Page3DetailsScreen extends StatefulWidget {
//   final int productId;
//   final Product? initialProduct;

//   const Page3DetailsScreen({
//     Key? key,
//     required this.productId,
//     this.initialProduct,
//   }) : super(key: key);

//   @override
//   State<Page3DetailsScreen> createState() => _Page3DetailsScreenState();
// }

// class _Page3DetailsScreenState extends State<Page3DetailsScreen> {
//   late Future<Product?> _productFuture;

//   @override
//   void initState() {
//     super.initState();
    
//     // If we already have product data, use it
//     // Otherwise fetch it from API
//     if (widget.initialProduct != null) {
//       _productFuture = Future.value(widget.initialProduct);
//     } else {
//       _productFuture = WidgetsBinding.instance.addPostFrameCallback((_) {
//         return context.read<ProductProvider>().fetchProductById(widget.productId);
//       }).then((_) {
//         return context.read<ProductProvider>().fetchProductById(widget.productId);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width <= 600;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('📋 Product Details'),
//         centerTitle: true,
//         backgroundColor: Colors.blue[700],
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => context.pop(),
//         ),
//       ),
//       body: Center(
//         child: FutureBuilder<Product?>(
//           future: _productFuture,
//           builder: (context, snapshot) {
//             // Loading state
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation(Colors.blue[700]),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text('Loading product details...'),
//                 ],
//               );
//             }

//             // Error state
//             if (snapshot.hasError || snapshot.data == null) {
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error, size: 48, color: Colors.red),
//                   const SizedBox(height: 16),
//                   const Text('Product not found'),
//                   const SizedBox(height: 24),
//                   ElevatedButton.icon(
//                     onPressed: () => context.pop(),
//                     icon: const Icon(Icons.arrow_back),
//                     label: const Text('Go Back'),
//                   ),
//                 ],
//               );
//             }

//             final product = snapshot.data!;

//             return SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.all(isMobile ? 16 : 24),
//                 child: Container(
//                   constraints: const BoxConstraints(maxWidth: 500),
//                   child: Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // Product Image Placeholder
//                         Container(
//                           height: 300,
//                           decoration: BoxDecoration(
//                             color: Colors.blue[100],
//                             borderRadius: const BorderRadius.vertical(
//                               top: Radius.circular(12),
//                             ),
//                           ),
//                           child: Center(
//                             child: Icon(
//                               Icons.shopping_bag,
//                               size: 80,
//                               color: Colors.blue[700],
//                             ),
//                           ),
//                         ),

//                         // Product Details
//                         Padding(
//                           padding: const EdgeInsets.all(24),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             spacing: 20,
//                             children: [
//                               // Product Name
//                               Text(
//                                 product.name,
//                                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),

//                               // Product ID
//                               Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[100],
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   spacing: 8,
//                                   children: [
//                                     Text(
//                                       'Product ID',
//                                       style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                     Text(
//                                       '#${product.id}',
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),

//                               // Price (Highlighted)
//                               Container(
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   color: Colors.green[50],
//                                   border: Border.all(
//                                     color: Colors.green[300]!,
//                                   ),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   spacing: 8,
//                                   children: [
//                                     Text(
//                                       'Price',
//                                       style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                     Text(
//                                       '\$${product.price.toStringAsFixed(2)}',
//                                       style: TextStyle(
//                                         fontSize: 32,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.green[700],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),

//                               // Category
//                               Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue[50],
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   spacing: 8,
//                                   children: [
//                                     Text(
//                                       'Category',
//                                       style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 6,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: Colors.blue[700],
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                       child: Text(
//                                         product.category,
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),

//                               const SizedBox(height: 8),

//                               // Back Button
//                               SizedBox(
//                                 width: double.infinity,
//                                 child: ElevatedButton.icon(
//                                   onPressed: () => context.pop(),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.blue[700],
//                                     padding: const EdgeInsets.symmetric(vertical: 12),
//                                   ),
//                                   icon: const Icon(Icons.arrow_back, color: Colors.white),
//                                   label: const Text(
//                                     'Back to Products',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
