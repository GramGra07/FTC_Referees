import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Simple JSON parser: prefers Flutter assets (rootBundle). If `source` looks
/// like raw JSON (starts with '{' or '[') it decodes it directly.
class JsonParser {
  /// Parse JSON from a raw JSON string or an asset path.
  ///
  /// Notes:
  /// - For Flutter web and mobile, include the JSON file in `pubspec.yaml`
  ///   under `flutter.assets` and call `parse('assets/res.json')`.
  /// - For desktop, you can still call `parse` with an absolute filesystem
  ///   path but this implementation does not attempt to read files via
  ///   `dart:io` to remain web-compatible. If you need filesystem fallback,
  ///   let me know and I can add a conditional import that uses `dart:io` on
  ///   non-web platforms.
  Future<Map<String, dynamic>> parse(String source) async {
    final trimmed = source.trimLeft();

    String text;
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      // Raw JSON string
      text = source;
    } else {
      // Try loading as an asset via rootBundle
      try {
        text = await rootBundle.loadString(source);
      } catch (e) {
        throw Exception(
          'Failed to load asset "$source". Make sure it is added to pubspec.yaml under flutter.assets. Error: $e',
        );
      }
    }

    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }
}
