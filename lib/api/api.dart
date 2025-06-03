import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projek_prak_mobile/model/jadwal.dart';

class ApiService {
  static const String baseUrl = 'https://api.myquran.com/v2/sholat/jadwal/';

  static Future<Jadwal> fetchJadwal({
    required String kota,
    required String tahun,
    required String bulan,
    required String tanggal,
  }) async {
    final url = '$baseUrl$kota/$tahun/$bulan/$tanggal';
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final jsonMap = json.decode(res.body) as Map<String, dynamic>;
      if (jsonMap['status'] == true) {
        final data = jsonMap['data'] as Map<String, dynamic>;
        return Jadwal.fromJson(data);
      } else {
        throw Exception('Data tidak ditemukan');
      }
    } else {
      throw Exception('Gagal load data jadwal');
    }
  }
}
