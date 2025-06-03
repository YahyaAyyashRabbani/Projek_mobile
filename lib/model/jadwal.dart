class Jadwal {
  final int id;
  final String lokasi;
  final String daerah;
  final JadwalSholat jadwal;

  Jadwal({
    required this.id,
    required this.lokasi,
    required this.daerah,
    required this.jadwal,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: json['id'] ?? 0,
      lokasi: json['lokasi'] ?? '',
      daerah: json['daerah'] ?? '',
      jadwal: JadwalSholat.fromJson(json['jadwal'] ?? {}),
    );
  }
}

class JadwalSholat {
  final String tanggal;
  final String imsak;
  final String subuh;
  final String terbit;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
  final String date;

  JadwalSholat({
    required this.tanggal,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.date,
  });

  factory JadwalSholat.fromJson(Map<String, dynamic> json) {
    return JadwalSholat(
      tanggal: json['tanggal'] ?? '',
      imsak: json['imsak'] ?? '',
      subuh: json['subuh'] ?? '',
      terbit: json['terbit'] ?? '',
      dhuha: json['dhuha'] ?? '',
      dzuhur: json['dzuhur'] ?? '',
      ashar: json['ashar'] ?? '',
      maghrib: json['maghrib'] ?? '',
      isya: json['isya'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
