import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Fungsi untuk mengunduh dan membuka PDF dari URL
Future<void> openRemotePdf(String url, {String? fileName}) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Gagal mengunduh file');
    }

    // Tentukan lokasi penyimpanan sementara
    final dir = await getTemporaryDirectory();
    final safeName = fileName ?? url.split('/').last;
    final file = File('${dir.path}/$safeName');

    // Simpan file ke lokal
    
    await file.writeAsBytes(response.bodyBytes);
    // Buka file dengan OpenFilex
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      throw Exception('Gagal membuka file');
    }
  } catch (e) {
    print('❌ Error membuka PDF: $e');
    rethrow;
  }
}
