import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'pelanggan.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final String username;

  const HomePage({super.key, required this.userId, required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _products = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  late TabController _tabController;

  get supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchProduk();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

 void showDeleteConfirmation(int id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Konfirmasi Penghapusan'),
        content: Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.red, // Warna teks tombol
            ),
            child: Text('Tidak'),
            onPressed: () {
              Navigator.of(context).pop(); // Menutup dialog
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.green, // Warna teks tombol
            ),
            child: Text('Iya'),
            onPressed: () {
              deleteProduct(id);
              Navigator.of(context).pop(); // Menutup dialog setelah menghapus
            },
          ),
        ],
      );
    },
  );
}


  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tuanmuda Liquor'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(widget.username),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.account_circle, size: 50),
              ),
            ),
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.logout),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Produk Tab
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: _products.map((product) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(product['nama_produk'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Harga: Rp${product['harga']}', style: TextStyle(fontSize: 16)),
                        Text('Stok: ${product['stok']}', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => showProductDialog(
                            id: product['produk_id'],
                            nama: product['nama_produk'],
                            harga: product['harga'],
                            stok: product['stok'],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => showDeleteConfirmation(product['produk_id']),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Transaksi Tab
          Center(child: Text('Halaman Transaksi')),
          // Pelanggan Tab
          HalamanPelanggan(),
          // Profil Tab
          ProfilePage(username: widget.username, logout: logout),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => showProductDialog(id: null, nama: null, harga: null, stok: null),
              child: Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.index = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pelanggan'),
        ],
        selectedItemColor: Colors.blue[300],
        unselectedItemColor: Colors.black,
      ),
    );
  }

  // Function to show the product dialog (for adding and editing)
  void showProductDialog({required id, required nama, required harga, required stok}) {
    _nameController.text = nama ?? '';
    _hargaController.text = harga != null ? harga.toString() : '';
    _stokController.text = stok != null ? stok.toString() : '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Tambah Produk' : 'Edit Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
              ),
              TextField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Harga'),
              ),
              TextField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Stok'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (id == null) {
                  addProduct();
                } else {
                  updateProduct(id);
                }
              },
              child: Text(id == null ? 'Tambah' : 'Perbarui'),
            ),
          ],
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String username;
  final VoidCallback logout;

  const ProfilePage({super.key, required this.username, required this.logout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.account_circle, size: 50),
            title: Text(username, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Text('Profil Pengguna'),
          ),
          Divider(),
        ],
      ),
    );
  }
}
