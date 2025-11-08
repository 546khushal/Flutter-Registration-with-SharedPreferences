import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const ProductApp());

class ProductApp extends StatefulWidget {
  const ProductApp({super.key});
  @override
  State<ProductApp> createState() => _ProductAppState();
}

class _ProductAppState extends State<ProductApp> {
  final name = TextEditingController();
  final price = TextEditingController();
  final qty = TextEditingController();
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('products', jsonEncode(products));
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('products');
    if (data != null) {
      setState(() => products = List<Map<String, dynamic>>.from(jsonDecode(data)));
    }
  }

  void addProduct() {
    if (name.text.isEmpty || price.text.isEmpty || qty.text.isEmpty) return;
    setState(() {
      products.add({
        'name': name.text,
        'price': double.tryParse(price.text) ?? 0,
        'qty': int.tryParse(qty.text) ?? 0,
      });
    });
    saveData();
    name.clear();
    price.clear();
    qty.clear();
  }

  void deleteProduct(int index) async {
    setState(() => products.removeAt(index));
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Product Inventory')),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Product Name')),
              TextField(controller: price, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              TextField(controller: qty, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: addProduct, child: const Text('Add Product')),
              const SizedBox(height: 10),
              Expanded(
                child: products.isEmpty
                    ? const Center(child: Text('No Products Added'))
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, i) => Card(
                          child: ListTile(
                            title: Text(products[i]['name']),
                            subtitle: Text('₹${products[i]['price']} | Qty: ${products[i]['qty']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteProduct(i),
                            ),
                          ),
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
