import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projek_prak_mobile/model/jadwal.dart';
import 'package:projek_prak_mobile/model/doa.dart';  // Assuming you have a Doa model

class ApiService {
  static const String baseUrl = 'https://api.myquran.com/v2/sholat/jadwal/';
  static const String baseUrl2 = 'https://api.myquran.com/v2/doa/';

  // Fetch Jadwal (Prayer Times) data by kota, tahun, bulan, tanggal
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

  // Fetch Doa (prayer) data by id
  static Future<Doa> fetchDoaById({required String id}) async {
    final url = '$baseUrl2$id';
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final jsonMap = json.decode(res.body) as Map<String, dynamic>;
      if (jsonMap['status'] == true) {
        final data = jsonMap['data'] as Map<String, dynamic>;
        return Doa.fromJson(data);  // Assuming you have a Doa.fromJson constructor
      } else {
        throw Exception('Data doa tidak ditemukan');
      }
    } else {
      throw Exception('Gagal load data doa');
    }
  }

   static Future<List<Doa>> fetchDoaList() async {
  final endpoint = 'semua'; // Endpoint to fetch all Doas
  final url = Uri.parse('$baseUrl2$endpoint'); // Combine base URL and endpoint
  final res = await http.get(url);

  if (res.statusCode == 200) {
    // Parse the response and return the list of Doas
    List<dynamic> data = jsonDecode(res.body);
    return data.map((doa) => Doa.fromJson(doa)).toList();
  } else {
    // Handle error if the response is not successful
    throw Exception('Failed to load Doas');
  }
}

}



