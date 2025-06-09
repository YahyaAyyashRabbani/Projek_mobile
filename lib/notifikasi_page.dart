import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:projek_prak_mobile/model/notifikasi.dart'; // Model Notifikasi yang telah diperbarui
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<String> sholatOptions = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
  final List<String> notifTimesOptions = ['10 menit sebelum', '5 menit sebelum', 'Pas adzan'];

  List<Notifikasi> notifications = [];

  String? selectedSholat;
  Set<String> selectedNotifTimes = {};

  bool isLoading = false;
  String? error;

  bool isEditing = false;
  String? editingId;

  String userId = 'user_1'; // Misalnya, kita menggunakan user ID tetap, ganti dengan yang sesuai.

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Load notifications from Hive
  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final box = await Hive.openBox<Notifikasi>('notificationBox');
      final data = box.values.where((notif) => notif.userId == userId).toList();
      setState(() {
        notifications = data;  // Refresh the notifications list
      });
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

  // Save selected notification times to SharedPreferences
  Future<void> _savePreferences() async {
    if (selectedSholat == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_${selectedSholat!}', selectedNotifTimes.join(','));
  }

  // Reset the form
  void _resetForm() {
    selectedSholat = null;
    selectedNotifTimes.clear();
    editingId = null;
    isEditing = false;
  }

  // Add or update notification in Hive
 Future<void> _addOrUpdateNotification() async {
  if (selectedSholat == null || selectedNotifTimes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pilih sholat dan setidaknya satu opsi notifikasi')),
    );
    return;
  }

  final notifData = Notifikasi(
    sholat: selectedSholat!,
    notifTimes: selectedNotifTimes.join(', '),
    userId: userId,
    id: editingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
  );

    bool success = false;
    final box = await Hive.openBox<Notifikasi>('notificationBox');

  if (isEditing && editingId != null) {
    // Update existing notification
    await box.put(editingId, notifData); // Use put to explicitly set the id
    success = true;
  } else {
    // Add new notification using put with a unique key
    await box.put(notifData.id, notifData); // Use the unique id as the key
    success = true;
  }

    if (success) {
      await _savePreferences();
      // Reload notifications and rebuild UI
      await _loadNotifications();  // Ensure the UI is refreshed
      setState(() {
        _resetForm();  // Reset the form after successful operation
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


  // Start editing an existing notification
  void _startEditNotification(Notifikasi notif) {
    setState(() {
      selectedSholat = notif.sholat;
      selectedNotifTimes = notif.notifTimes.split(',').map((e) => e.trim()).toSet();
      editingId = notif.id;
      isEditing = true;
    });
  }

  // Delete notification from Hive
  void _deleteNotification(String id) async {
  final box = await Hive.openBox<Notifikasi>('notificationBox');
  await box.delete(id); // Delete the notification using the id

  // Reload notifications and rebuild the UI
  await _loadNotifications();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Notifikasi berhasil dihapus')),
  );
}

  // Format Fication times to display
  String _getNotifTimesText(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    List<String> parts = raw.split(',').map((e) => e.trim()).toList();
    return parts.join(', ');
  }

  // Build the form to add or update notifications
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
                      style: const TextStyle(fontSize: 16, color: Colors.white),
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

  // Build the list of notifications
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
        final id = notif.id;
        final sholat = notif.sholat;
        final notifTimes = _getNotifTimesText(notif.notifTimes);

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
         automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        title: const Text('Manajemen Notifikasi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
