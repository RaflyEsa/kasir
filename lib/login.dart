import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Username dan password tidak boleh kosong.')),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('user')
          .select('id, username')
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (response != null) {
        final userId = response['id'];
        final userName = response['username'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selamat datang, $userName!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomePage(userId: userId, username: userName)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Login gagal. Username atau password salah.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Gambar Header (Kasir)
          Container(
            width: 200,
            height: 200, // Mengurangi ukuran menjadi 25% dari tinggi layar
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/kasir.png'), // Gambar kasir
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Teks Header
                      const Text(
                        'Welcome 👏',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Halaman Login Kasir',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),

                      // Input Username
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle:
                              const TextStyle(color: Colors.grey), // Default
                          floatingLabelStyle: const TextStyle(
                              color: Colors.black), // Saat fokus
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          prefixIcon:
                              const Icon(Icons.people, color: Colors.black),
                        ),
                        cursorColor: Colors.black,
                        style: const TextStyle(
                            color: Colors.black), // Warna teks saat diketik
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.grey),
                          floatingLabelStyle:
                              const TextStyle(color: Colors.black),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.black),
                        ),
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Login
                      SizedBox(
                        width: double.infinity,
                        height: 45, // Sedikit lebih kecil agar lebih elegan
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.blue[400], // Warna soft biru
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Sudut tidak terlalu bulat
                            ),
                            elevation: 3, // Efek bayangan
                          ),
                          onPressed: _login,
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize:
                                  16, // Lebih kecil agar tidak terlalu besar
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
