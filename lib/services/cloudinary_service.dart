import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // ⚠️ REPLACE THESE TWO VALUES WITH YOUR CLOUDINARY DETAILS
  static const String cloudName = "nejxbexi";
  static const String uploadPreset = "gzog2hnx";

  /// Uploads any file (PDF, DOCX, Video, Image) as bytes to Cloudinary
  /// Returns the public HTTPS Download URL if successful, or null if failed.
  static Future<String?> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    String resourceType = "auto", // 'auto', 'raw' (for PDF/DOCX), or 'video'
  }) async {
    try {
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload",
      );

      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: fileName,
          ),
        );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200) {
        // Return the secure HTTPS URL
        return jsonResponse['secure_url'] as String?;
      } else {
        print("Cloudinary Upload Failed: $responseData");
        return null;
      }
    } catch (e) {
      print("Cloudinary Error: $e");
      return null;
    }
  }
}