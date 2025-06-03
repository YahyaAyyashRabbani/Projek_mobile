import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vector_math/vector_math.dart' show radians;

class KiblatPage extends StatefulWidget {
  const KiblatPage({Key? key}) : super(key: key);

  @override
  State<KiblatPage> createState() => _KiblatPageState();
}

class _KiblatPageState extends State<KiblatPage> {
  double? _heading; // arah utara device
  Position? _position;
  double? _kiblatDirection; // sudut arah kiblat dari utara

  final double kaabahLatitude = 21.4225;
  final double kaabahLongitude = 39.8262;

  StreamSubscription<CompassEvent>? _compassSub;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _listenCompass();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  void _listenCompass() {
    _compassSub = FlutterCompass.events?.listen((CompassEvent event) {
  if (event.heading == null) return;
  setState(() {
    _heading = event.heading!;
  });
});
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // cek service lokasi
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // service lokasi dimatikan
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _position = position;
      _kiblatDirection = _calculateQiblaDirection(
          position.latitude, position.longitude, kaabahLatitude, kaabahLongitude);
    });
  }

  double _calculateQiblaDirection(double lat, double lon, double kaabahLat, double kaabahLon) {
    final latRad = radians(lat);
    final kaabahLatRad = radians(kaabahLat);
    final deltaLon = radians(kaabahLon - lon);

    final x = math.sin(deltaLon);
    final y = math.cos(latRad) * math.tan(kaabahLatRad) - math.sin(latRad) * math.cos(deltaLon);

    double bearing = math.atan2(x, y);
    bearing = bearing * 180 / math.pi; // convert ke derajat
    bearing = (bearing + 360) % 360; // normalisasi ke 0-360

    return bearing;
  }

  @override
  Widget build(BuildContext context) {
    double? direction;

    if (_heading != null && _kiblatDirection != null) {
      // arah untuk panah kiblat = sudut kiblat - heading utara device
      direction = (_kiblatDirection! - _heading!) % 360;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arah Kiblat'),
        backgroundColor: Colors.green.shade700,
      ),
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: _position == null
            ? const Text('Mengambil lokasi...',
                style: TextStyle(fontSize: 18, color: Colors.green))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Arah Kiblat Anda:',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(height: 20),
                  if (direction != null)
                    Transform.rotate(
                      angle: direction * (math.pi / 180) * -1,
                      child: Icon(
                        Icons.navigation,
                        size: 120,
                        color: Colors.green.shade900,
                      ),
                    )
                  else
                    const Text(
                      'Mengambil data kompas...',
                      style: TextStyle(color: Colors.green),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'Latitude: ${_position!.latitude.toStringAsFixed(5)}\n'
                    'Longitude: ${_position!.longitude.toStringAsFixed(5)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sudut Kiblat: ${_kiblatDirection?.toStringAsFixed(2)}°',
                    style: const TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Heading Kompas: ${_heading?.toStringAsFixed(2) ?? '-'}°',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
      ),
    );
  }
}
