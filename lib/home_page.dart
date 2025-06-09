import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:projek_prak_mobile/api/api.dart';
import 'package:projek_prak_mobile/model/jadwal.dart';
import 'package:projek_prak_mobile/utils/id_kota.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Jadwal? _jadwal;
  bool _isLoading = false;
  String? _error;

  String? _detectedCity;
  int? _cityId;

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.init();
    _deteksiLokasiDanFetch();
  }

  // Function to search city in the mapping (Kota/Kab)
  String? _searchCityInMapping(String placeName, Map<String, String> mapping) {
    placeName = placeName.toUpperCase();

    for (var key in mapping.keys) {
      String normKey = key.replaceAll(RegExp(r'\bKOTA\b|\bKAB\.\b'), '').trim().toUpperCase();
      if (placeName.contains(normKey)) {
        return key;
      }
    }
    return null;
  }

  // Method to fetch location and schedule data
  Future<void> _deteksiLokasiDanFetch() async {
  setState(() {
    _isLoading = true;
    _error = null;
    _jadwal = null;
    _detectedCity = null;
    _cityId = null;
  });

  try {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _error = 'Izin lokasi ditolak';
            _isLoading = false;
          });
        }
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _error = 'Izin lokasi ditolak permanen, buka pengaturan';
          _isLoading = false;
        });
      }
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isEmpty) {
      if (mounted) {
        setState(() {
          _error = 'Gagal mendapatkan lokasi';
          _isLoading = false;
        });
      }
      return;
    }

    Placemark place = placemarks.first;
    String placeRaw = place.subAdministrativeArea ?? '';

    if (placeRaw.isEmpty) {
      if (mounted) {
        setState(() {
          _error = 'Nama kota/kabupaten tidak ditemukan dari lokasi';
          _isLoading = false;
        });
      }
      return;
    }

    String cityNormalized = placeRaw
        .toUpperCase()
        .replaceAll(RegExp(r'\bKABUPATEN\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\bKAB\.\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\bKOTA\b', caseSensitive: false), '')
        .trim();

    String? matchedCityKey;

    if (idKota.containsKey('KAB. $cityNormalized')) {
      matchedCityKey = 'KAB. $cityNormalized';
    } else if (idKota.containsKey('KOTA $cityNormalized')) {
      matchedCityKey = 'KOTA $cityNormalized';
    } else {
      matchedCityKey = _searchCityInMapping(cityNormalized, idKota);
    }

    if (matchedCityKey == null) {
      if (mounted) {
        setState(() {
          _error = 'Kota/kabupaten untuk "$placeRaw" tidak ditemukan dalam data';
          _isLoading = false;
        });
      }
      return;
    }

    String cityIdStr = idKota[matchedCityKey]!;
    int cityId = int.parse(cityIdStr);

    DateTime now = DateTime.now();
    String tahun = now.year.toString();
    String bulan = now.month.toString().padLeft(2, '0');
    String tanggal = now.day.toString().padLeft(2, '0');

    final jadwal = await ApiService.fetchJadwal(
      kota: cityId.toString(),
      tahun: tahun,
      bulan: bulan,
      tanggal: tanggal,
    );

    if (mounted) {
      setState(() {
        _jadwal = jadwal;
        _detectedCity = matchedCityKey;
        _cityId = cityId;
        _isLoading = false;
      });
    }

    // Jadwalkan notifikasi setelah data jadwal siap
    await _scheduleAllNotifications();

  } catch (e) {
    if (mounted) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }
}


  // Method to schedule all notifications
  Future<void> _scheduleAllNotifications() async {
    if (_jadwal == null) return;

    final prefs = await SharedPreferences.getInstance();

    // Mapping prayer times
    Map<String, String> jadwalMap = {
      'Subuh': _jadwal!.jadwal.subuh,
      'Dzuhur': _jadwal!.jadwal.dzuhur,
      'Ashar': _jadwal!.jadwal.ashar,
      'Maghrib': _jadwal!.jadwal.maghrib,
      'Isya': _jadwal!.jadwal.isya,
    };

    // Cancel all previous notifications
    await _notificationService.cancelAll();

    int notifId = 0;

    // Loop through each prayer time and schedule notifications
    for (var sholat in jadwalMap.keys) {
      final notifTimesStr = prefs.getString('notif_$sholat');
      if (notifTimesStr == null || notifTimesStr.isEmpty) continue;

      final notifTimes = notifTimesStr.split(',').map((e) => e.trim()).toList();

      for (var notifTime in notifTimes) {
        final prayerTimeStr = jadwalMap[sholat];
        if (prayerTimeStr == null) continue;

        final parts = prayerTimeStr.split(':');
        if (parts.length < 2) continue;
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        DateTime now = DateTime.now();
        DateTime scheduledTime =
            DateTime(now.year, now.month, now.day, hour, minute);

        // Adjust the scheduled time based on the notification time option
        if (notifTime == '10 menit sebelum') {
          scheduledTime = scheduledTime.subtract(const Duration(minutes: 10));
        } else if (notifTime == '5 menit sebelum') {
          scheduledTime = scheduledTime.subtract(const Duration(minutes: 5));
        }

        // If scheduled time is in the past, set it for the next day
        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }

        // Schedule the notification
        await _notificationService.scheduleNotification(
          id: notifId++,
          title: 'Waktu Sholat $sholat',
          body: 'Waktunya $sholat sekarang',
          scheduledDate: scheduledTime,
        );
      }
    }
  }

  // Header widget
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 32, color: Colors.teal.shade700),
          const SizedBox(width: 10),
          const Text(
            'PrayerReminder',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  // City info widget
  Widget _buildCityInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _detectedCity == null
              ? const Text('Lokasi belum terdeteksi',
                  style: TextStyle(fontSize: 16, color: Colors.black54))
              : Text(
                  'Lokasi: $_detectedCity',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
          IconButton(
            onPressed: _deteksiLokasiDanFetch,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Jadwal',
            color: Colors.teal.shade700,
            splashRadius: 24,
          )
        ],
      ),
    );
  }

  // Display Jadwal (prayer times)
  Widget _buildJadwalView() {
    if (_jadwal == null) {
      if (_isLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (_error != null) {
        return Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        );
      } else if (_detectedCity != null) {
        return Center(child: Text('Detected city: $_detectedCity'));
      } else {
        return const SizedBox();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jadwal Sholat untuk Kota: $_detectedCity ($_cityId)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Text('Tanggal: ${_jadwal!.jadwal.tanggal}', style: const TextStyle(fontSize: 16)),
              const Divider(height: 30, thickness: 1.2),
              Text('Imsak: ${_jadwal!.jadwal.imsak}', style: const TextStyle(fontSize: 16)),
              Text('Subuh: ${_jadwal!.jadwal.subuh}', style: const TextStyle(fontSize: 16)),
              Text('Terbit: ${_jadwal!.jadwal.terbit}', style: const TextStyle(fontSize: 16)),
              Text('Dhuha: ${_jadwal!.jadwal.dhuha}', style: const TextStyle(fontSize: 16)),
              Text('Dzuhur: ${_jadwal!.jadwal.dzuhur}', style: const TextStyle(fontSize: 16)),
              Text('Ashar: ${_jadwal!.jadwal.ashar}', style: const TextStyle(fontSize: 16)),
              Text('Maghrib: ${_jadwal!.jadwal.maghrib}', style: const TextStyle(fontSize: 16)),
              Text('Isya: ${_jadwal!.jadwal.isya}', style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildCityInfo(),
            Expanded(child: _buildJadwalView()),
          ],
        ),
      ),
    );
  }
}
