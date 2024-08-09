import 'package:flutter/foundation.dart';
import 'package:gsheets/gsheets.dart';
import 'package:flutter/services.dart';

Future<String> readJson() async {
  return await rootBundle.loadString('assets/g_sheet_creds.json');
}

const gsDateBase = 2209161600 / 86400;
const gsDateFactor = 86400000;

String _formattedDate(DateTime currentDate) {
  return "${currentDate.day}/${currentDate.month}/${currentDate.year}";
}

double dateToGsheets(DateTime dateTime, {bool localTime = true}) {
  final offset = dateTime.millisecondsSinceEpoch / gsDateFactor;
  final shift = localTime ? dateTime.timeZoneOffset.inHours / 24 : 0;
  return gsDateBase + offset + shift;
}

DateTime? dateFromGsheets(String value, {bool localTime = true}) {
  final date = double.tryParse(value);
  if (date == null) return null;
  final millis = (date - gsDateBase) * gsDateFactor;
  return DateTime.fromMillisecondsSinceEpoch(millis.toInt(), isUtc: localTime);
}

Future<void> fetchGsheet() async {
  try {
    const spredadSheetId = '1q9P-1regUnlaolI-rpwK37zK4vX-0SnIR7Y0Jo3ucLk';
    final credentials = await readJson();
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spredadSheetId);

    final data = await ss.sheets.first.values.map.allRows()
        as List<Map<String, dynamic>>?;

    data?.forEach((element) {
      if (kDebugMode) print(element);
      element["Date"] = dateFromGsheets(element["Date"]!)!;
    });
    if (kDebugMode) print(data);

    if (kDebugMode) print(data);
  } on Exception catch (e) {
    if (kDebugMode) print(e);
  }
}
