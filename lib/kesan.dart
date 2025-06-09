import 'package:flutter/material.dart';

class KesanPage extends StatelessWidget {
  const KesanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftar kesan dan pesan yang sudah ditentukan
    final List<String> _kesanList = [
      'Projeknya menantang karena banyak ketentuannya',
      'Ya gitu deh',
      'Semoga adik kelas dapat merasakan apa yang kami rasakan.',
      'Semoga dapet A',
    ];

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
         automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        title: const Text('Kesan dan Pesan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kesan dan Pesan Saya',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 20),
              const Text(
                'Berikut adalah beberapa kesan dan pesan yang dapat saya sampaikan',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // Menampilkan daftar kesan/pesan yang sudah dimasukkan
              Expanded(
                child: ListView.builder(
                  itemCount: _kesanList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            _kesanList[index],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
