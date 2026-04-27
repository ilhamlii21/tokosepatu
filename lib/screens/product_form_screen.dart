import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  
  // Dynamic fields for the JSONB 'details'
  List<Map<String, TextEditingController>> _dynamicFields = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _categoryController = TextEditingController(text: widget.product?.category ?? '');
    
    if (widget.product != null && widget.product!.details.isNotEmpty) {
      widget.product!.details.forEach((key, value) {
        _dynamicFields.add({
          'key': TextEditingController(text: key),
          'value': TextEditingController(text: value.toString()),
        });
      });
    } else {
      // Add one empty field by default for convenience
      _addDynamicField();
    }
  }

  void _addDynamicField() { //add untuk kolom inputan dinamis 
    setState(() {
      _dynamicFields.add({
        'key': TextEditingController(),
        'value': TextEditingController(),
      });
    });
  }

  void _removeDynamicField(int index) { //remove untuk kolom inputan dinamis
    setState(() {
      _dynamicFields[index]['key']?.dispose();
      _dynamicFields[index]['value']?.dispose();
      _dynamicFields.removeAt(index);
    });
  }

  Future<void> _saveProduct() async { //save untuk data product
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Construct details map
      Map<String, dynamic> details = {};
      for (var field in _dynamicFields) {
        final key = field['key']!.text.trim();
        final value = field['value']!.text.trim();
        if (key.isNotEmpty) {
          details[key] = value;
        }
      }

      final data = {
        'name': _nameController.text.trim(),
        'category': _categoryController.text.trim(),
        'details': details,
      };

      if (widget.product == null) {
        // Create
        await _supabase.from('products').insert(data);
      } else {
        // Update
        await _supabase.from('products').update(data).eq('id', widget.product!.id);
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct() async { //delete untuk product
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _supabase.from('products').delete().eq('id', widget.product!.id);
      if (mounted) {
        Navigator.pop(context, true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting product: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    for (var field in _dynamicFields) {
      field['key']?.dispose();
      field['value']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: _deleteProduct,
              tooltip: 'Delete Product',
            ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dynamic Attributes (NoSQL)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _addDynamicField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Attribute'),
                    ),
                  ],
                ),
                const Divider(),
                ..._dynamicFields.asMap().entries.map((entry) {
                  final index = entry.key;
                  final field = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: field['key'],
                            decoration: const InputDecoration(
                              hintText: 'Key (Contoh : Warna)',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: field['value'],
                            decoration: const InputDecoration(
                              hintText: 'Value (Contoh : Merah)',
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeDynamicField(index),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: _saveProduct,
                  child: Text(
                    isEditing ? 'Save Changes' : 'Create Product',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
