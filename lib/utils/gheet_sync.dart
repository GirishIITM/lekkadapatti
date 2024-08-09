import 'package:flutter/foundation.dart';
import 'package:gsheets/gsheets.dart';
import 'package:flutter/services.dart';
import 'package:lekkadapatti/utils/date_time.dart';
import 'package:lekkadapatti/utils/logger.dart';

Future<String> readJson() async {
  return await rootBundle.loadString('assets/g_sheet_creds.json');
}

const gsDateBase = 2209161600 / 86400;
const gsDateFactor = 86400000;

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

    var data = await ss.sheets.first.values.map.allRows()
        as List<Map<String, dynamic>>?;
    final dataFormatted = data?.map((element) {
      if (kDebugMode) logger(element);
      return {
        'Name': element['Name'],
        'Status': element['Status'],
        "Date": dateFromGsheets(element["Date"]),
      };
    }).toList();

    if (kDebugMode) logger(dataFormatted);
  } on Exception catch (e) {
    errorLogger('Error: $e');
    logger('StackTrace: ${StackTrace.current}');
  }
}

Future<void> insertData(DateTime date, Map<String, String> data) async {
  try {
    const spredadSheetId = '1q9P-1regUnlaolI-rpwK37zK4vX-0SnIR7Y0Jo3ucLk';
    final credentials = await readJson();
    final gsheets = GSheets(credentials);
    final sheetName = getYearWeekFromDate(date);
    final ss = await gsheets.spreadsheet(spredadSheetId);
    var sheet = ss.worksheetByTitle(sheetName);

    sheet ??= await ss.addWorksheet(sheetName);

    final rowIndex = date.day;

    await sheet.values.map.insertRow(rowIndex, data);

    if (kDebugMode) logger('inserted row $rowIndex of sheet $sheetName.');
  } on Exception catch (e) {
    if (kDebugMode) {
      errorLogger("Error: $e");
      logger("StackTrace: ${StackTrace.current}");
    }
  }
}

Future<void> updateData(DateTime date, Map<String, String> data) async {
  try {
    const spredadSheetId = '1q9P-1regUnlaolI-rpwK37zK4vX-0SnIR7Y0Jo3ucLk';
    final credentials = await readJson();
    final gsheets = GSheets(credentials);
    final sheetName = getYearWeekFromDate(date);
    final ss = await gsheets.spreadsheet(spredadSheetId);
    var sheet = ss.worksheetByTitle(sheetName);

    if (sheet == null) {
      logger('Sheet $sheetName does not exist.');
      return;
    }

    final rowIndex = date.day;

    await sheet.values.map.insertRow(rowIndex, data);

    logger('Data updated in row $rowIndex of sheet $sheetName.');
  } on Exception catch (e) {
    errorLogger(e);
  }
}
