import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HalamanPelanggan extends StatefulWidget {
  const HalamanPelanggan({super.key});

  @override
  _HalamanPelangganState createState() => _HalamanPelangganState();
}

class _HalamanPelangganState extends State<HalamanPelanggan> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pelangganList = [];

  @override
  void initState() {
    super.initState();
    _loadPelangganData();
  }

  // Fungsi untuk memuat data pelanggan dari Supabase
  Future<void> _loadPelangganData() async {
    final response = await supabase.from('pelanggan').select('pelanggan_id, nama_pelanggan, alamat'); // Menampilkan nama_pelanggan, alamat, dan pelanggan_id

    // Pastikan ada data yang didapat dan tidak terjadi error
    if (response == null) {
      setState(() {
        // Mengupdate daftar pelanggan setelah berhasil mengambil data
        pelangganList = List<Map<String, dynamic>>.from(response);
      });
    } else {
      // Jika ada error, tampilkan pesan error
      print('Error loading pelanggan');
    }
  }

  // Fungsi untuk menambahkan pelanggan baru
  Future<void> _addPelanggan(String nama, String alamat, String nomorTelepon) async {
    final response = await supabase.from('pelanggan').insert([
      {
        'nama_pelanggan': nama,
        'alamat': alamat,
        'nomor_telepon': nomorTelepon,
      }
    ]);

    if (response.error == null) {
      _loadPelangganData(); // Reload data setelah menambah
    } else {
      print('Error adding pelanggan');
    }
  }

  // Fungsi untuk memperbarui pelanggan
  Future<void> _updatePelanggan(int pelangganId, String nama, String alamat, String nomorTelepon) async {
    final response = await supabase.from('pelanggan').update({
      'nama_pelanggan': nama,
      'alamat': alamat,
      'nomor_telepon': nomorTelepon,
    }).eq('pelanggan_id', pelangganId);

    if (response.error == null) {
      _loadPelangganData(); // Reload data setelah update
    } else {
      print('Error updating pelanggan');
    }
  }

  // Fungsi untuk menghapus pelanggan
  Future<void> _deletePelanggan(int pelangganId) async {
    final response = await supabase.from('pelanggan').delete().eq('pelanggan_id', pelangganId);

    if (response.error == null) {
      _loadPelangganData(); // Reload data setelah hapus
    } else {
      print('Error deleting pelanggan');
    }
  }

  // Menampilkan form untuk menambahkan data pelanggan
  void _showAddForm() {
    final TextEditingController namaController = TextEditingController();
    final TextEditingController alamatController = TextEditingController();
    final TextEditingController nomorTeleponController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Pelanggan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
              ),
              TextField(
                controller: alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: nomorTeleponController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final nama = namaController.text;
                final alamat = alamatController.text;
                final nomorTelepon = nomorTeleponController.text;
                if (nama.isNotEmpty && alamat.isNotEmpty && nomorTelepon.isNotEmpty) {
                  _addPelanggan(nama, alamat, nomorTelepon);
                  Navigator.pop(context);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  // Menampilkan form untuk mengedit data pelanggan
  void _showEditForm(int pelangganId, String nama, String alamat, String nomorTelepon) {
    final TextEditingController namaController = TextEditingController(text: nama);
    final TextEditingController alamatController = TextEditingController(text: alamat);
    final TextEditingController nomorTeleponController = TextEditingController(text: nomorTelepon);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Pelanggan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
              ),
              TextField(
                controller: alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: nomorTeleponController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final nama = namaController.text;
                final alamat = alamatController.text;
                final nomorTelepon = nomorTeleponController.text;
                if (nama.isNotEmpty && alamat.isNotEmpty && nomorTelepon.isNotEmpty) {
                  _updatePelanggan(pelangganId, nama, alamat, nomorTelepon);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Konfirmasi penghapusan pelanggan
  void _confirmDelete(int pelangganId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Pelanggan'),
          content: const Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                _deletePelanggan(pelangganId);
                Navigator.pop(context);
              },
              child: const Text('Hapus'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Pelanggan'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Pelanggan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: pelangganList.length,
                itemBuilder: (context, index) {
                  final pelanggan = pelangganList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(pelanggan['nama_pelanggan']),
                      subtitle: Text('Alamat: ${pelanggan['alamat']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditForm(
                                pelanggan['pelanggan_id'],
                                pelanggan['nama_pelanggan'],
                                pelanggan['alamat'],
                                pelanggan['nomor_telepon'],
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _confirmDelete(pelanggan['pelanggan_id']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
