import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pelanggan.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final String username;

  const HomePage({super.key, required this.userId, required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _products = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  get supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    try {
      final response = await supabase.from('produk').select().order('produk_id');
      setState(() {
        _products = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> addProduct() async {
    if (_nameController.text.isEmpty || _hargaController.text.isEmpty || _stokController.text.isEmpty) return;
    try {
      await supabase.from('produk').insert({
        'nama_produk': _nameController.text,
        'harga': int.parse(_hargaController.text),
        'stok': int.parse(_stokController.text),
      });
      fetchProduk();
      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  Future<void> updateProduct(int id) async {
    try {
      await supabase.from('produk').update({
        'nama_produk': _nameController.text,
        'harga': int.parse(_hargaController.text),
        'stok': int.parse(_stokController.text),
      }).eq('produk_id', id);
      fetchProduk();
      Navigator.of(context).pop();
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await supabase.from('produk').delete().eq('produk_id', id);
      fetchProduk();
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  void showProductDialog({int? id, String? nama, int? harga, int? stok}) {
    _nameController.text = nama ?? '';
    _hargaController.text = harga?.toString() ?? '';
    _stokController.text = stok?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Tambah Produk' : 'Edit Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Nama Produk')),
              TextField(controller: _hargaController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga')),
              TextField(controller: _stokController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Stok')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Batal')),
            ElevatedButton(
              onPressed: () => id == null ? addProduct() : updateProduct(id),
              child: Text(id == null ? 'Tambah' : 'Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manajemen Produk')),
      body: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: _products.map((product) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product['nama_produk'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text('Harga: Rp${product['harga']}', style: TextStyle(fontSize: 16)),
                          Text('Stok: ${product['stok']}', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(icon: Icon(Icons.edit), onPressed: () => showProductDialog(id: product['produk_id'], nama: product['nama_produk'], harga: product['harga'], stok: product['stok'])),
                              IconButton(icon: Icon(Icons.delete), onPressed: () => deleteProduct(product['produk_id'])),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          : _currentIndex == 1
              ? Center(child: Text('Halaman Transaksi'))
              : HalamanPelanggan(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => showProductDialog(),
              child: Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pelanggan'),
        ],
      ),
    );
  }
}