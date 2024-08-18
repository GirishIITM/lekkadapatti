import 'package:lekkadapatti/utils/functions/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../functions/date_time.dart';
import '../functions/gheet_sync.dart';

class AttendanceManager {
  DateTime currentDate;
  Map<String, Map<String, String>> attendanceDataPerDate = {};
  Map<String, Map<String, Map<String, int>>> groupDataPerDate = {};
  Map<String, String> attendance = {};
  Map<String, Map<String, int>> status = {
    "Hindesgeri (ಹಿಂಡಸಗೇರಿ)": {"male": 0, "female": 0}
  };

  List<String> names = [
    'ವಿಠ್ಠಲ Vithal',
    'ಗಂಗಾ Ganga',
    'ಮೊಹಮ್ಮದ್ Mohammad',
    'ನಹಿದಾ Nahida',
  ];

  List<String> groups = ["Hindesgeri (ಹಿಂಡಸಗೇರಿ)"];

  AttendanceManager({required this.currentDate});

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('attendanceDataPerDate');
    await prefs.remove('groupDataPerDate');
    await prefs.remove('names');
    await prefs.remove('groups');
  }

  Future<void> loadAttendanceDataPerDate({required Function setState}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAttendanceDataPerDate =
          prefs.getString('attendanceDataPerDate');
      final savedGroupDataPerDate = prefs.getString('groupDataPerDate');
      final savedNames = prefs.getString("names");
      final savedGroups = prefs.getString("groups");

      if (savedNames != null) {
        names = List<String>.from(jsonDecode(savedNames));
      }

      if (savedGroups != null) {
        groups = List<String>.from(jsonDecode(savedGroups));
      }

      if (savedAttendanceDataPerDate != null) {
        attendanceDataPerDate = Map<String, Map<String, String>>.from(
          jsonDecode(savedAttendanceDataPerDate).map(
              (key, value) => MapEntry(key, Map<String, String>.from(value))),
        );
      }

      if (savedGroupDataPerDate != null) {
        final Map<String, dynamic> decodedData =
            jsonDecode(savedGroupDataPerDate);
        groupDataPerDate = Map<String, Map<String, Map<String, int>>>.from(
          decodedData.map(
            (key, value) => MapEntry(
              key,
              Map<String, Map<String, int>>.from(
                value.map(
                  (key, value) => MapEntry(
                    key,
                    Map<String, int>.from(value),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      setState(() {
        attendance = attendanceDataPerDate[formattedDate(currentDate)] ?? {};
        status = groupDataPerDate[formattedDate(currentDate)] ?? status;
        names = names;
        groups = groups;
      });
    } on Exception catch (e) {
      errorLogger(e);
    }
  }

  Future<void> saveAttendanceAndGroupData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'attendanceDataPerDate', jsonEncode(attendanceDataPerDate));
      await prefs.setString('groupDataPerDate', jsonEncode(groupDataPerDate));
      await prefs.setString("names", jsonEncode(names));
      await prefs.setString("groups", jsonEncode(groups));
    } on Exception catch (e) {
      errorLogger(e);
    }
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

  void addGroup({required String groupName, required Function setState}) {
    setState(() {
      groups.add(groupName);
      status[groupName] = {
        "male": 0,
        "female": 0,
      };
      groupDataPerDate[formattedDate(currentDate)] = status;
    });
    saveAttendanceAndGroupData();
  }

  void deleteGroup({required String groupName, required Function setState}) {
    setState(() {
      groups.remove(groupName);
      status.remove(groupName);
    });
    saveAttendanceAndGroupData();
  }

  void onIncrement(
      String groupName, String type, int count, Function setState) {
    status[groupName]?[type] = count + 1;
    if (groupDataPerDate[formattedDate(currentDate)] == null) {
      groupDataPerDate[formattedDate(currentDate)] = {};
    }
    setState(() {
      groupDataPerDate[formattedDate(currentDate)]?[groupName] =
          status[groupName]!;
    });
    saveAttendanceAndGroupData();
  }

  void onDecrement(
      String groupName, String type, int count, Function setState) {
    if (count > 0) {
      status[groupName]?[type] = count - 1;
      if (groupDataPerDate[formattedDate(currentDate)] == null) {
        groupDataPerDate[formattedDate(currentDate)] = {};
      }
      setState(() {
        groupDataPerDate[formattedDate(currentDate)]?[groupName] =
            status[groupName]!;
      });
    }
    saveAttendanceAndGroupData();
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
    Map<String, Map<String, int>> initStatus = {};
    for (var group in groups) {
      initStatus[group] = {"male": 0, "femaile": 0};
    }
    setState(() {
      attendance = attendanceDataPerDate[formattedDate(currentDate)] ?? {};
      status = groupDataPerDate[formattedDate(currentDate)] ?? initStatus;
    });
  }

  void editName(
      {required String oldName,
      required String newName,
      required Function setState}) {
    final index = names.indexOf(oldName);
    setState(() {
      names[index] = newName;
    });
    saveAttendanceAndGroupData();
  }

  void deleteName({
    required String name,
    required Function setState,
  }) {
    setState(() {
      names.remove(name);
      names = names;
    });
    saveAttendanceAndGroupData();
  }
}

extension DateTimeExtensions on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

const daysInKannada = [
  "ಸೋಮವಾರ",
  "ಮಂಗಳವಾರ",
  "ಬುಧವಾರ",
  "ಗುರುವಾರ",
  "ಶುಕ್ರವಾರ",
  "ಶನಿವಾರ",
  "ಭಾನುವಾರ",
];
