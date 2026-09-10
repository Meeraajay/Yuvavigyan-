import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'qzia5ini';
  static const String uploadPreset = 'yuvavigyan_upload';

  static Future<String?> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    String resourceType = 'auto',
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload',
      );

      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = uploadPreset;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['secure_url'];
      } else {
        print('Cloudinary upload failed: ${response.statusCode}');
        print(responseBody);
        return null;
      }
    } catch (e) {
      print('Cloudinary error: $e');
      return null;
    }
  }
}