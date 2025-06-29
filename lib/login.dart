import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:projek_prak_mobile/model/user.dart'; // Pastikan file user.dart sudah ada
import 'package:bcrypt/bcrypt.dart'; // Import bcrypt untuk enkripsi
import 'register.dart'; // Import halaman register
import 'root_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Cek status login menggunakan SharedPreferences
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? savedUsername = prefs.getString('username');

    if (isLoggedIn && savedUsername != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => RootPage(username: savedUsername),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance, size: 100, color: Colors.teal.shade700),
              const SizedBox(height: 16),
              const Text(
                "Jadwal Sholat",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Silahkan login untuk melanjutkan",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _username,
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: isError ? Colors.red.shade100 : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: isError ? Colors.red.shade100 : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    var box = await Hive.openBox('userBox');
                    User? user = box.get(_username.text);

                    if (user != null && await BCrypt.checkpw(_password.text, user.password)) {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool("isLoggedIn", true);
                      await prefs.setString("username", _username.text);

                      setState(() {
                        isError = false;
                      });

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => RootPage(username: _username.text),
                        ),
                      );
                    } else {
                      setState(() {
                        isError = true;
                      });
                    }

                    String message = isError ? "Username atau password salah" : "Login berhasil";
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, color : Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Add some space between buttons
              // Tombol untuk mendaftar
              TextButton(
                onPressed: () {
                  // Arahkan ke halaman Register
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text(
                  "Belum punya akun? Daftar di sini",
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
