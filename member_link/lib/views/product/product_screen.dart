// ignore_for_file: library_private_types_in_public_api, curly_braces_in_flow_control_structures

import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:member_link/myconfig.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<dynamic> allProducts = []; // List to store products from the database
  List<dynamic> filteredProducts = []; // List for search results
  final Map<String, int> cart =
      {}; // Map to store cart items and their quantities
  final int itemsPerPage = 3; // Number of items per page
  int currentPage = 1; // Current page number
  int totalPages = 1; // Total number of pages
  bool isLoading = false; // Loading state
  bool isSearching = false; // Search mode state
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts(); // Fetch products when the screen initializes
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      // API URL (replace 'localhost' with your server address)
      final response = await http.get(
          Uri.parse('${MyConfig.servername}/memberlink/api/load_products.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            allProducts = data['data']['products'];
            filteredProducts = allProducts;
            totalPages = (filteredProducts.length / itemsPerPage).ceil();
          });
        } else {
          setState(() {
            allProducts = [];
            filteredProducts = [];
          });
          _showError('No products found.');
        }
      } else {
        _showError(
            'Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addToCart(String productId) {
    setState(() {
      if (cart.containsKey(productId)) {
        cart[productId] = cart[productId]! + 1;
      } else {
        cart[productId] = 1;
      }
    });
  }

  void _removeFromCart(String productId) {
    setState(() {
      if (cart.containsKey(productId)) {
        if (cart[productId]! > 1) {
          cart[productId] = cart[productId]! - 1;
        } else {
          cart.remove(productId);
        }
      }
    });
  }

  void _viewCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CartScreen(
              cart: cart, allProducts: allProducts, onUpdateCart: _updateCart)),
    );
  }

  void _updateCart(String productId) {
    setState(() {
      cart.remove(productId);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product['name']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(
                    '${MyConfig.servername}/memberlink/${product['image']}',
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 200),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Name: ${product['name']}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Price: \$${product['price']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Quantity: ${product['quantity']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Description: ${product['description'] ?? "No description available."}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = allProducts
          .where((product) =>
              product['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
      totalPages = (filteredProducts.length / itemsPerPage).ceil();
      currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage) < filteredProducts.length
        ? (startIndex + itemsPerPage)
        : filteredProducts.length;
    final displayedProducts = filteredProducts.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF191A1A), // Use dark theme color
        iconTheme: const IconThemeData(
            color: Colors.white), // Change back button color
        title: isSearching
            ? Container(
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light background color
                  borderRadius: BorderRadius.circular(24), // Rounded corners
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textAlign: TextAlign.left, // Start typing from the left
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  onChanged: (query) {
                    _filterProducts(query);
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0), // Add padding inside the field
                    hintText: 'Search products...', // Placeholder text
                    border: InputBorder.none,
                  ),
                ),
              )
            : const Text(
                'Products',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.cancel : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  _searchController.clear();
                  _filterProducts('');
                }
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: displayedProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.orange,
                                size: 100,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No Products Available!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Please check back later or refresh the page.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton.icon(
                                onPressed: fetchProducts, // Reload products
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedProducts.length,
                          itemBuilder: (context, index) {
                            final product = displayedProducts[index];
                            final productId = product['product_id'].toString();
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            '${MyConfig.servername}/memberlink/${product['image']}',
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return const CircularProgressIndicator();
                                            },
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Icon(Icons.broken_image,
                                                    size: 100),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['name'],
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                  'Price: \$${product['price']}'),
                                              Text(
                                                  'Quantity: ${product['quantity']}'),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                                0xFF191A1A), // Match AppBar color
                                            foregroundColor:
                                                Colors.white, // Text color
                                          ),
                                          onPressed: () => _showProductDetails(
                                              context, product),
                                          child: const Text('View Details'),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove,
                                                  color: Colors.red),
                                              onPressed: () {
                                                _removeFromCart(productId);
                                              },
                                            ),
                                            Text(
                                              '${cart[productId] ?? 0}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add,
                                                  color: Colors.green),
                                              onPressed: () {
                                                _addToCart(productId);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                _buildPaginationControls(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _viewCart,
        backgroundColor: const Color(0xFF191A1A), // Match AppBar color
        child: const Icon(Icons.shopping_cart, color: Colors.white),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: currentPage > 1
                ? () {
                    setState(() {
                      currentPage--;
                    });
                  }
                : null,
          ),
          Text('Page $currentPage of $totalPages'),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: currentPage < totalPages
                ? () {
                    setState(() {
                      currentPage++;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<dynamic> allProducts;
  final Function(String) onUpdateCart;

  const CartScreen(
      {super.key,
      required this.cart,
      required this.allProducts,
      required this.onUpdateCart});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    double total = 0;
    final cartItems = widget.cart.entries
        .map((entry) {
          final product = widget.allProducts.firstWhere(
              (prod) => prod['product_id'].toString() == entry.key,
              orElse: () => null);
          if (product != null) {
            total += (double.tryParse(product['price'].toString()) ?? 0) *
                entry.value;
            return {
              'product': product,
              'quantity': entry.value,
            };
          }
          return null;
        })
        .where((item) => item != null)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF191A1A), // Match AppBar color
        iconTheme: const IconThemeData(
            color: Colors.white), // Change back button color
        title:
            const Text('Shopping Cart', style: TextStyle(color: Colors.white)),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty!'))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index]!;
                final product = item['product'];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Image.network(
                      '${MyConfig.servername}/memberlink/${product['image']}',
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50),
                    ),
                    title: Text(product['name']),
                    subtitle: Text(
                        'Price: \$${product['price']} \nQty: ${item['quantity']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          widget.cart.remove(product['product_id'].toString());
                          widget.onUpdateCart(product['product_id'].toString());
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF191A1A), // Match AppBar color
                foregroundColor: Colors.white, // Text color
              ),
              onPressed: () {
                // Implement checkout functionality
              },
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
