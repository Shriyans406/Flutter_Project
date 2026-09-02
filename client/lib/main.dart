import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/product_provider.dart';
import 'models/product.dart';
import 'pages/page1_search.dart';
import 'pages/page2_listing.dart';
import 'pages/page3_details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp.router(
        title: 'CashRich - Product Browsing',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          fontFamily: 'Roboto',
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// GoRouter configuration
/// Defines all routes in the application
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Page 1: Search Screen (Home)
    GoRoute(
      path: '/',
      builder: (context, state) => const Page1SearchScreen(),
    ),

    // Page 2: Products Listing Screen
    GoRoute(
      path: '/products',
      builder: (context, state) => const Page2ListingScreen(),
    ),

    // Page 3: Product Details Screen
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final product = state.extra as Product?;
        
        return Page3DetailsScreen(
          productId: id,
          initialProduct: product,
        );
      },
    ),

    // Fallback route (404)
    GoRoute(
      path: '/404',
      builder: (context, state) => const NotFoundScreen(),
    ),
  ],

  // Handle unrecognized routes
  errorBuilder: (context, state) => const NotFoundScreen(),
);

/// 404 Not Found Screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('404 - Not Found'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'The page you are looking for does not exist.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
