import 'package:flutter/foundation.dart';
import 'package:gsheets/gsheets.dart';
import 'package:flutter/services.dart';
import 'package:lekkadapatti/utils/functions/date_time.dart';
import 'package:lekkadapatti/utils/functions/logger.dart';

const spreadSheetId = '1q9P-1regUnlaolI-rpwK37zK4vX-0SnIR7Y0Jo3ucLk';
const rowStartDate = "15/9/2024";

Future<String> readJson() async {
  return await rootBundle.loadString('assets/g_sheet_creds.json');
}

Future<void> fetchGsheet() async {
  try {
    final credentials = await readJson();
    final sheets = GSheets(credentials);
    final ss = await sheets.spreadsheet(spreadSheetId);

    var data = await ss.sheets.first.values.map.allRows() as List<Map<String, dynamic>>?;
    final dataFormatted = data?.map((element) {
      if (kDebugMode) logger(element);
      return {
        'Name': element['Name'],
        'Status': element['Status'],
        "Date": dateFromGsheets(element["Date"]),
      };
    }).toList();

    logger(dataFormatted);
  } on Exception catch (e) {
    errorLogger('Error: $e');
    logger('StackTrace: ${StackTrace.current}');
  }
}

Future<void> insertData(DateTime date, List<String> data) async {
  try {
    const spreadSheetId = '1q9P-1regUnlaolI-rpwK37zK4vX-0SnIR7Y0Jo3ucLk';
    final credentials = await readJson();
    final sheets = GSheets(credentials);
    final ss = await sheets.spreadsheet(spreadSheetId);

    final sheet = ss.sheets.first;
    final allRows = await sheet.values.allRows();

    final dateString = formatDate(date);

    final nextEmptyRow = allRows.length + 1; // Calculate the next available row

    await sheet.values.insertRow(nextEmptyRow, [dateString, ...data]);
  } on Exception catch (e) {
    errorLogger("Error: $e");
    logger("StackTrace: ${StackTrace.current}");
  }
}



Future<void> updateAttendanceForDate(DateTime date, String name, String status) async {
  try {
    const spreadSheetId = '1q9P-1regUnlaolI-rpwK37zK4vX-0SnIR7Y0Jo3ucLk';
    final credentials = await readJson();
    final sheets = GSheets(credentials);
    final ss = await sheets.spreadsheet(spreadSheetId);
    
    final dateString = formatDate(date);

    final sheet = ss.sheets.first;
    final allRows = await sheet.values.allRows(); // Fetches all rows

    for (int i = 0; i < allRows.length; i++) {
      final row = allRows[i];
      if (row.contains(dateString)) {
        final rowIndex = i + 1; // Since sheet rows are 1-based
        final nameIndex = row.indexOf(name);
        
        if (nameIndex != -1) {
          await sheet.values.insertValue(status, column: nameIndex + 1, row: rowIndex);
        }
      }
    }
  } on Exception catch (e) {
    errorLogger("Error: $e");
    logger("StackTrace: ${StackTrace.current}");
  }
}

