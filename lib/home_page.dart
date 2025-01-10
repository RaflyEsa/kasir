import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart'; // Pastikan file ini diimpor

class HomePage extends StatelessWidget {
  final int userId;
  final String username;

  const HomePage({Key? key, required this.userId, required this.username}) : super(key: key);

  Future<void> _confirmLogout(BuildContext context) async {
    // Tampilkan dialog konfirmasi
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Tidak logout
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // Logout
              child: const Text('Iya'),
            ),
          ],
        );
      },
    );

    // Jika pengguna memilih "Iya", lakukan logout
    if (shouldLogout == true) {
      await Supabase.instance.client.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selamat datang, $username!',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _confirmLogout(context),
              child: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
