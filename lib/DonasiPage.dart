import 'package:flutter/material.dart';
import 'notification_service.dart'; // Import NotificationService

class DonasiPage extends StatefulWidget {
  const DonasiPage({super.key});

  @override
  State<DonasiPage> createState() => _DonasiPageState();
}

class _DonasiPageState extends State<DonasiPage> {
  final double _rupiahToUsd = 0.000067; // 1 IDR = 0.000067 USD
  final double _rupiahToRinggit = 0.00029; // 1 IDR = 0.00029 MYR
  String _convertedAmount = ''; // To store the converted value

  final TextEditingController _donationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        title: const Text('Halaman Donasi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Donasi Untuk Pengembangan Aplikasi',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 20),
              const Text(
                'Silakan berikan donasi untuk mendukung pengembangan aplikasi ini.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              
              // Input jumlah donasi
              const Text(
                'Masukkan Jumlah Donasi:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _donationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Jumlah (IDR)',
                  hintText: 'Masukkan jumlah dalam Rupiah',
                ),
              ),
              const SizedBox(height: 20),
              
              // Tombol konversi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _convertToCurrency('USD');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, 
                    ),
                    child: const Text('USD'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _convertToCurrency('MYR');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, 
                    ),
                    child: const Text('Ringgit'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showDonationNotification(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, 
                    ),
                    child: const Text('Kirim Donasi'),
                  ),
                ],
              ),

              // Menampilkan hasil konversi
              if (_convertedAmount.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Hasil Konversi: $_convertedAmount',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk mengonversi jumlah donasi
  void _convertToCurrency(String currency) {
    setState(() {
      final double donation = double.tryParse(_donationController.text) ?? 0;

      if (currency == 'USD') {
        _convertedAmount = '${(donation * _rupiahToUsd).toStringAsFixed(2)} USD';
      } else if (currency == 'MYR') {
        _convertedAmount = '${(donation * _rupiahToRinggit).toStringAsFixed(2)} MYR';
      }
    });
  }

  // Fungsi untuk menampilkan notifikasi saat tombol kirim donasi diklik
  void _showDonationNotification(BuildContext context) async {
    final notificationService = NotificationService();
    
    // Menyusun waktu untuk notifikasi
    DateTime scheduledTime = DateTime.now().add(Duration(seconds: 5)); // Contoh, setel 5 detik setelah klik

    // Menjadwalkan notifikasi
    await notificationService.scheduleNotification(
      id: 1,
      title: 'Terima Kasih atas Donasi Anda!',
      body: 'Donasi Anda sangat membantu pengembangan aplikasi ini.',
      scheduledDate: scheduledTime,
    );

    // Menampilkan notifikasi secara langsung
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifikasi Donasi berhasil dijadwalkan!')),
    );
  }
}
