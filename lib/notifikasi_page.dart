import 'package:flutter/material.dart';
import 'package:projek_prak_mobile/api/apiNotif.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<String> sholatOptions = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
  final List<String> notifTimesOptions = ['10 menit sebelum', '5 menit sebelum', 'Pas adzan'];

  List<Map<String, dynamic>> notifications = [];

  String? selectedSholat;
  Set<String> selectedNotifTimes = {};

  bool isLoading = false;
  String? error;

  bool isEditing = false;
  String? editingId;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await NotificationApi.fetchNotifications();
      setState(() {
        notifications = data;
      });
      await _loadPreferences();
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Kalau mau load ke form, bisa implementasi di sini
    // Saat ini kita biarkan kosong, karena form reset tiap load.
  }

  Future<void> _savePreferences() async {
    if (selectedSholat == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_${selectedSholat!}', selectedNotifTimes.join(','));
  }

  void _resetForm() {
    selectedSholat = null;
    selectedNotifTimes.clear();
    editingId = null;
    isEditing = false;
  }

  void _addOrUpdateNotification() async {
    if (selectedSholat == null || selectedNotifTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih sholat dan setidaknya satu opsi notifikasi')),
      );
      return;
    }

    final notifData = {
      'sholat': selectedSholat,
      'notif_times': selectedNotifTimes.join(', '), // format string sesuai backend
    };

    bool success = false;

    if (isEditing && editingId != null) {
      success = await NotificationApi.updateNotification(editingId!, notifData);
    } else {
      success = await NotificationApi.createNotification(notifData);
    }

    if (success) {
      await _savePreferences();
      await _loadNotifications();
      setState(() {
        _resetForm();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? 'Notifikasi berhasil diupdate' : 'Notifikasi berhasil ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? 'Gagal mengupdate notifikasi' : 'Gagal menambahkan notifikasi')),
      );
    }
  }

  void _startEditNotification(Map<String, dynamic> notif) {
    setState(() {
      selectedSholat = notif['sholat'];
      String rawNotifTimes = notif['notif_times'] ?? '';
      selectedNotifTimes = rawNotifTimes.split(',').map((e) => e.trim()).toSet();
      editingId = notif['id']?.toString();
      isEditing = true;
    });
  }

  void _deleteNotification(String id) async {
    final success = await NotificationApi.deleteNotification(id);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      // Hapus preferensi jika notifikasi yg dihapus sama dengan yang disimpan
      if (editingId == id) {
        await prefs.remove('notif_$selectedSholat');
      }
      _loadNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifikasi berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus notifikasi')),
      );
    }
  }

  String _getNotifTimesText(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    List<String> parts = raw.split(',').map((e) => e.trim()).toList();
    return parts.join(', ');
  }

  Widget _buildForm() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Notifikasi' : 'Tambah Notifikasi Baru',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal),
            ),
            const SizedBox(height: 16),
            const Text('Pilih Sholat:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSholat,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              hint: const Text('Pilih sholat'),
              items: sholatOptions
                  .map((sholat) => DropdownMenuItem(
                        value: sholat,
                        child: Text(sholat),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedSholat = val;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Pilih Waktu Notifikasi:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...notifTimesOptions.map(
              (notifTime) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(notifTime),
                value: selectedNotifTimes.contains(notifTime),
                activeColor: Colors.teal,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedNotifTimes.add(notifTime);
                    } else {
                      selectedNotifTimes.remove(notifTime);
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _addOrUpdateNotification,
                    child: Text(
                      isEditing ? 'Update Notifikasi' : 'Tambah Notifikasi',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _resetForm();
                      });
                    },
                    child: const Text('Batal'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: Colors.red)),
      );
    } else if (notifications.isEmpty) {
      return const Center(
        child: Text('Belum ada notifikasi', style: TextStyle(fontSize: 16, color: Colors.black54)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.tealAccent),
      itemBuilder: (context, index) {
        final notif = notifications[index];
        final id = notif['id']?.toString() ?? index.toString();
        final sholat = notif['sholat'] ?? '';
        final notifTimes = _getNotifTimesText(notif['notif_times']);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            sholat,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
          ),
          subtitle: Text(
            notifTimes,
            style: const TextStyle(color: Colors.black87),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                tooltip: 'Edit Notifikasi',
                onPressed: () => _startEditNotification(notif),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                tooltip: 'Hapus Notifikasi',
                onPressed: () => _deleteNotification(id),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Manajemen Notifikasi'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildForm(),
            const SizedBox(height: 24),
            Expanded(child: _buildNotificationsList()),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
