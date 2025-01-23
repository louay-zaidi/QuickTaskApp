import 'dart:convert';
import 'package:http/http.dart' as http;

class HolidayService {
  static const String _apiUrl = 'https://date.nager.at/api/v3/PublicHolidays';
  static const String _countryCode = 'IT'; 

  /// Fetch Italian holidays for the current year.
  static Future<Map<DateTime, List<String>>> getItalianHolidays() async {
    final currentYear = DateTime.now().year;
    final url = '$_apiUrl/$currentYear/$_countryCode';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      final holidays = <DateTime, List<String>>{};

      for (var holiday in data) {
        final date = DateTime.parse(holiday['date']);
        final name = holiday['localName'];

        holidays.putIfAbsent(date, () => []).add(name);
      }

      return holidays;
    } else {
      throw Exception('Failed to load holidays');
    }
  }
}
