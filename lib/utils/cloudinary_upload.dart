import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String?> uploadImageToCloudinary(File imageFile) async {
  const cloudName = 'do72beek2';
  const uploadPreset = 'dinogambar';

  final url =
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final resStr = await response.stream.bytesToString();
    final resJson = json.decode(resStr);
    return resJson['secure_url'];
  } else {
    return null;
  }
}
