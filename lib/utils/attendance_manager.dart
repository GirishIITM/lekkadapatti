import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'date_time.dart';
import 'gheet_sync.dart';

class AttendanceManager {
  DateTime currentDate;
  Map<String, Map<String, String>> attendanceDataPerDate = {};
  Map<String, Map<String, int>> groupDataPerDate = {};
  Map<String, String> attendance = {};
  Map<String, int> status = {"male": 0, "female": 0};
  List<String> names = [
    'ವಿಠ್ಠಲ Vithal',
    'ಗಂಗಾ Ganga',
    'ಮೊಹಮ್ಮದ್ Mohammad',
    'ನಹಿದಾ Nahida',
  ];

  List<String> groups = ["Hindesgeri (ಹಿಂಡಸಗೇರಿ)"];

  AttendanceManager({required this.currentDate});

  Future<void> loadAttendanceDataPerDate({required Function setState}) async {
    final prefs = await SharedPreferences.getInstance();
    final savedAttendanceDataPerDate = prefs.getString('attendanceDataPerDate');
    final savedGroupDataPerDate = prefs.getString('groupDataPerDate');

    if (savedAttendanceDataPerDate != null) {
      attendanceDataPerDate = Map<String, Map<String, String>>.from(
        jsonDecode(savedAttendanceDataPerDate).map(
            (key, value) => MapEntry(key, Map<String, String>.from(value))),
      );
    }

    if (savedGroupDataPerDate != null) {
      groupDataPerDate = Map<String, Map<String, int>>.from(
        jsonDecode(savedGroupDataPerDate)
            .map((key, value) => MapEntry(key, Map<String, int>.from(value))),
      );
    }

    setState(() {
      attendance = attendanceDataPerDate[formattedDate(currentDate)] ?? {};
      status = groupDataPerDate[formattedDate(currentDate)] ??
          {"male": 0, "female": 0};
    });
  }

  Future<void> saveAttendanceAndGroupData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'attendanceDataPerDate', jsonEncode(attendanceDataPerDate));
    await prefs.setString('groupDataPerDate', jsonEncode(groupDataPerDate));
  }

  void setAttendance({
    required String name,
    required String status,
    required Function setState,
  }) {
    setState(() {
      attendance[name] = status;
    });
    saveAttendanceAndGroupData();
    insertData(currentDate,
        {'Name': name, 'Date': dateToGsheets(currentDate), 'Status': status});
  }

  void goToPreviousDay({required Function setState}) {
    saveDataForCurrentDate();
    currentDate = currentDate.subtract(const Duration(days: 1));
    loadDataForCurrentDate(setState: setState);
  }

  void goToNextDay({required Function setState}) {
    if (currentDate.isSameDate(DateTime.now())) return;

    saveDataForCurrentDate();
    currentDate = currentDate.add(const Duration(days: 1));
    loadDataForCurrentDate(setState: setState);
  }

  void saveDataForCurrentDate() {
    attendanceDataPerDate[formattedDate(currentDate)] = attendance;
    groupDataPerDate[formattedDate(currentDate)] = status;
    saveAttendanceAndGroupData();
  }

  void loadDataForCurrentDate({required Function setState}) {
    setState(() {
      attendance = attendanceDataPerDate[formattedDate(currentDate)] ?? {};
      status = groupDataPerDate[formattedDate(currentDate)] ??
          {"male": 0, "female": 0};
    });
  }
}

extension DateTimeExtensions on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

const daysInKannada = [
  "ಭಾನುವಾರ",
  "ಸೋಮವಾರ",
  "ಮಂಗಳವಾರ",
  "ಬುಧವಾರ",
  "ಗುರುವಾರ",
  "ಶುಕ್ರವಾರ",
  "ಶನಿವಾರ",
];
