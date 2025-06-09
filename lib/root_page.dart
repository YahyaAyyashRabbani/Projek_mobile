import 'package:flutter/material.dart';
import 'package:projek_prak_mobile/kesan.dart';
import 'home_page.dart';
import 'notifikasi_page.dart';
import 'kiblat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projek_prak_mobile/doa_page.dart';
import 'package:projek_prak_mobile/DonasiPage.dart';

class RootPage extends StatefulWidget {
  final String username;
  const RootPage({super.key, required this.username});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(username: widget.username),
      const NotificationPage(),
      const KiblatPage(),
      const DoaPage(),
      const DonasiPage(),
      const KesanPage(), // Pastikan DoaPage ada di posisi yang benar
    ];
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ingin keluar?"),
          content: const Text("Apakah yakin ingin logout dari aplikasi?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tidak", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool("isLoggedIn", false);
                await prefs.remove("username");
                if (!mounted) return;
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text("Iya"),
            ),
          ],
        );
      },
    );
  }

  void _onNavTapped(int index) {
    if (index == 6) {
      // Logika logout hanya untuk index ke-4
      _showLogoutDialog();
    } else {
      setState(() {
        _currentIndex = index; // Update index untuk halaman yang sesuai
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _pages[_currentIndex], // Menampilkan halaman sesuai dengan _currentIndex
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation),
            label: 'Kiblat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Doa',
          ), 
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Donasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Kesan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ), // Logout di posisi 4
        ],
      ),
    );
  }
}
