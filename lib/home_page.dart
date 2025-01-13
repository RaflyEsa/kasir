import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final String username;

  const HomePage({Key? key, required this.userId, required this.username}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Contoh data produk dan stok barang
  final List<Map<String, dynamic>> _products = [
    {'name': 'Produk A', 'price': 10000, 'stock': 20},
    {'name': 'Produk B', 'price': 20000, 'stock': 15},
    {'name': 'Produk C', 'price': 30000, 'stock': 10},
  ];

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Iya'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await Supabase.instance.client.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  // Tambah atau Edit Produk
  void _addOrEditProduct({Map<String, dynamic>? product, int? index}) {
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final priceController = TextEditingController(text: product?['price']?.toString() ?? '');
    final stockController = TextEditingController(text: product?['stock']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Harga'),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Stok'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final price = int.tryParse(priceController.text.trim()) ?? 0;
                final stock = int.tryParse(stockController.text.trim()) ?? 0;

                if (name.isNotEmpty && price > 0 && stock >= 0) {
                  setState(() {
                    if (product == null) {
                      // Tambah produk baru
                      _products.add({'name': name, 'price': price, 'stock': stock});
                    } else if (index != null) {
                      // Edit produk
                      _products[index] = {'name': name, 'price': price, 'stock': stock};
                    }
                  });

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Harap isi data produk dengan benar.')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Hapus Produk
  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil dihapus.')),
    );
  }

  Widget _buildHomePage() {
    return Center(
      child: Text(
        'Halo, ${widget.username}! Selamat datang di aplikasi!',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildProductPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _addOrEditProduct(),
            child: const Text('Tambah Produk'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.2,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  elevation: 4.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            product['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Harga: Rp${product['price']}'),
                            Text('Stok: ${product['stock']} unit'),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _addOrEditProduct(product: product, index: index),
                                  child: const Text('Edit'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _deleteProduct(index),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selamat datang, ${widget.username}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _confirmLogout(context),
            tooltip: 'Logout',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: Colors.grey[300],
            height: 2,
          ),
        ),
      ),
      body: _currentIndex == 0 ? _buildHomePage() : _buildProductPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Produk & Stok',
          ),
        ],
      ),
    );
  }
}
