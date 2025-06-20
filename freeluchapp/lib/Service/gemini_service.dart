import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = 'AIzaSyDPj_b3WfhodE6DbW5bC5dQkMNwnITLB2g'; // Ganti dengan env jika perlu
const String apiUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

Future<String> askGemini(String prompt) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ]
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text'];
  } else {
    print('Error: ${response.body}');
    return 'Terjadi kesalahan saat memanggil Gemini API';
  }
}