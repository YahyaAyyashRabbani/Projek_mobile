import 'package:hive/hive.dart';

part 'notifikasi.g.dart'; // Hive code generator file

@HiveType(typeId: 1)
class Notifikasi {
  @HiveField(0)
  final String sholat;

  @HiveField(1)
  final String notifTimes;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String id;

  Notifikasi({
    required this.sholat,
    required this.notifTimes,
    required this.userId,
    required this.id,
  });
}
