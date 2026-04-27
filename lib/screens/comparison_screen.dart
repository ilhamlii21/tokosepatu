import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import 'product_form_screen.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final _supabase = Supabase.instance.client;
  List<Product> _products = [];
  Product? _selectedProductA;
  Product? _selectedProductB;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _supabase.from('products').select();
      final List<Product> loadedProducts = 
          (response as List).map((e) => Product.fromJson(e)).toList();
      
      setState(() {
        _products = loadedProducts;
        
        // Re-assign selected products to the newly fetched ones to reflect any updates
        if (_selectedProductA != null) {
          _selectedProductA = _products.cast<Product?>().firstWhere(
            (p) => p?.id == _selectedProductA?.id, 
            orElse: () => null
          );
        } else if (_products.length >= 1) {
          _selectedProductA = _products[0];
        }

        if (_selectedProductB != null) {
          _selectedProductB = _products.cast<Product?>().firstWhere(
            (p) => p?.id == _selectedProductB?.id, 
            orElse: () => null
          );
        } else if (_products.length >= 2) {
          _selectedProductB = _products[1];
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching products: $e')),
        );
      }
    }
  }

  Future<void> _navigateToForm({Product? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    );

    // If product was added/updated, refresh the list
    if (result == true) {
      _fetchProducts();
    }
  }

  List<String> _getAllUniqueKeys() {
    if (_selectedProductA == null && _selectedProductB == null) return [];
    
    final Set<String> keys = {};
    if (_selectedProductA != null) {
      keys.addAll(_selectedProductA!.details.keys);
    }
    if (_selectedProductB != null) {
      keys.addAll(_selectedProductB!.details.keys);
    }
    
    final sortedKeys = keys.toList()..sort();
    return sortedKeys;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _products.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final uniqueKeys = _getAllUniqueKeys();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Product Comparison'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
        tooltip: 'Add New Product',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildProductDropdown(
                    label: 'Product A',
                    value: _selectedProductA,
                    onChanged: (Product? newValue) {
                      setState(() {
                        _selectedProductA = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProductDropdown(
                    label: 'Product B',
                    value: _selectedProductB,
                    onChanged: (Product? newValue) {
                      setState(() {
                        _selectedProductB = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_selectedProductA != null || _selectedProductB != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade700),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      // Header Row
                      TableRow(
                        decoration: BoxDecoration(color: Colors.white),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Attribute', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          _buildTableHeader(_selectedProductA),
                          _buildTableHeader(_selectedProductB),
                        ],
                      ),
                      // Data Rows
                      for (var key in uniqueKeys)
                        TableRow(
                          children: [
                            Container(
                              color: Colors.green.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(key, style: const TextStyle(fontWeight: FontWeight.w500)),
                              ),
                            ),
                            Container(
                              color: Colors.yellow.withOpacity(0.05),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(_selectedProductA?.details[key]?.toString() ?? '-'),
                              ),
                            ),
                            Container(
                              color: Colors.blue.withOpacity(0.05),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(_selectedProductB?.details[key]?.toString() ?? '-'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            if (_products.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text('No products found in the database. Please add some products to the "products" table.'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(Product? product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              product?.name ?? 'None', 
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (product != null)
            InkWell(
              onTap: () => _navigateToForm(product: product),
              child: const Icon(Icons.edit, size: 16, color: Colors.blue),
            )
        ],
      ),
    );
  }

  Widget _buildProductDropdown({
    required String label,
    required Product? value,
    required ValueChanged<Product?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<Product>(
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: value,
          hint: const Text('Select a product'),
          items: _products.map((Product product) {
            return DropdownMenuItem<Product>(
              value: product,
              child: Text(product.name ?? 'Unknown (ID: ${product.id})'),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
