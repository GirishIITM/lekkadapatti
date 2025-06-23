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
  Map<String, List<Map<String, dynamic>>> paymentHistory = {};
  Map<String, List<Map<String, dynamic>>> groupPaymentHistory = {};
  Map<String, Map<String, int>> groupRates = {};

  AttendanceManager({required this.currentDate}) {
    // Initialize default rates for existing groups
    for (String group in groups) {
      groupRates[group] = {"male": 200, "female": 200};
    }
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('attendanceDataPerDate');
    await prefs.remove('groupDataPerDate');
    await prefs.remove('names');
    await prefs.remove('groups');
    await prefs.remove('paymentHistory');
    await prefs.remove('groupPaymentHistory');
    await prefs.remove('groupRates');
  }

  Future<void> loadAttendanceDataPerDate({required Function setState}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAttendanceDataPerDate = prefs.getString('attendanceDataPerDate');
      final savedGroupDataPerDate = prefs.getString('groupDataPerDate');
      final savedNames = prefs.getString("names");
      final savedGroups = prefs.getString("groups");
      final savedPaymentHistory = prefs.getString("paymentHistory");
      final savedGroupPaymentHistory = prefs.getString("groupPaymentHistory");
      final savedGroupRates = prefs.getString("groupRates");

      if (savedNames != null) {
        names = List<String>.from(jsonDecode(savedNames));
      }

      if (savedGroups != null) {
        groups = List<String>.from(jsonDecode(savedGroups));
      }

      if (savedAttendanceDataPerDate != null) {
        attendanceDataPerDate = Map<String, Map<String, String>>.from(
          jsonDecode(savedAttendanceDataPerDate).map((key, value) => MapEntry(key, Map<String, String>.from(value))),
        );
      }

      if (savedGroupDataPerDate != null) {
        final Map<String, dynamic> decodedData = jsonDecode(savedGroupDataPerDate);
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

      if (savedPaymentHistory != null) {
        final Map<String, dynamic> decodedPayments = jsonDecode(savedPaymentHistory);
        paymentHistory = Map<String, List<Map<String, dynamic>>>.from(
          decodedPayments.map(
            (key, value) => MapEntry(
              key,
              List<Map<String, dynamic>>.from(value),
            ),
          ),
        );
      }

      if (savedGroupPaymentHistory != null) {
        final Map<String, dynamic> decodedGroupPayments = jsonDecode(savedGroupPaymentHistory);
        groupPaymentHistory = Map<String, List<Map<String, dynamic>>>.from(
          decodedGroupPayments.map(
            (key, value) => MapEntry(
              key,
              List<Map<String, dynamic>>.from(value),
            ),
          ),
        );
      }

      if (savedGroupRates != null) {
        final Map<String, dynamic> decodedRates = jsonDecode(savedGroupRates);
        groupRates = Map<String, Map<String, int>>.from(
          decodedRates.map(
            (key, value) => MapEntry(
              key,
              Map<String, int>.from(value),
            ),
          ),
        );
      }

      // Initialize rates for groups that don't have rates set
      for (String group in groups) {
        if (!groupRates.containsKey(group)) {
          groupRates[group] = {"male": 200, "female": 200};
        }
      }

      setState(() {
        attendance = attendanceDataPerDate[formatDate(currentDate)] ?? {};
        status = groupDataPerDate[formatDate(currentDate)] ?? status;
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
      await prefs.setString('attendanceDataPerDate', jsonEncode(attendanceDataPerDate));
      await prefs.setString('groupDataPerDate', jsonEncode(groupDataPerDate));
      await prefs.setString("names", jsonEncode(names));
      await prefs.setString("groups", jsonEncode(groups));
      await prefs.setString("paymentHistory", jsonEncode(paymentHistory));
      await prefs.setString("groupPaymentHistory", jsonEncode(groupPaymentHistory));
      await prefs.setString("groupRates", jsonEncode(groupRates));
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
    insertData(currentDate, [name, status, formatDate(currentDate)]);
  }

  void addName({required String name, required Function setState}) {
    if (names.contains(name) || name.isEmpty) return;
    setState(() {
      names.add(name);
    });
    saveAttendanceAndGroupData();
  }

  void addGroup({required String groupName, required Function setState}) {
    setState(() {
      groups.add(groupName);
      status[groupName] = {
        "male": 0,
        "female": 0,
      };
      groupRates[groupName] = {"male": 200, "female": 200};
      groupDataPerDate[formatDate(currentDate)] = status;
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

  void onIncrement(String groupName, String type, int count, Function setState) {
    status[groupName]?[type] = count + 1;
    if (groupDataPerDate[formatDate(currentDate)] == null) {
      groupDataPerDate[formatDate(currentDate)] = {};
    }
    setState(() {
      groupDataPerDate[formatDate(currentDate)]?[groupName] = status[groupName]!;
    });
    saveAttendanceAndGroupData();
  }

  void onDecrement(String groupName, String type, int count, Function setState) {
    if (count > 0) {
      status[groupName]?[type] = count - 1;
      if (groupDataPerDate[formatDate(currentDate)] == null) {
        groupDataPerDate[formatDate(currentDate)] = {};
      }
      setState(() {
        groupDataPerDate[formatDate(currentDate)]?[groupName] = status[groupName]!;
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
    attendanceDataPerDate[formatDate(currentDate)] = attendance;
    groupDataPerDate[formatDate(currentDate)] = status;
    saveAttendanceAndGroupData();
  }

  void loadDataForCurrentDate({required Function setState}) {
    Map<String, Map<String, int>> initStatus = {};
    for (var group in groups) {
      initStatus[group] = {"male": 0, "female": 0};
    }
    setState(() {
      attendance = attendanceDataPerDate[formatDate(currentDate)] ?? {};
      status = groupDataPerDate[formatDate(currentDate)] ?? initStatus;
    });
  }

  void editName({required String oldName, required String newName, required Function setState}) {
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

  Map<String, int> getAttendanceStats(String employeName) {
    int presentDays = 0;
    int absentDays = 0;
    int halfDays = 0;

    for (var dateData in attendanceDataPerDate.values) {
      final status = dateData[employeName];
      if (status == 'Present') {
        presentDays++;
      } else if (status == 'Absent') {
        absentDays++;
      } else if (status == 'Half Day') {
        halfDays++;
      }
    }

    return {
      'present': presentDays,
      'absent': absentDays,
      'halfDay': halfDays,
    };
  }

  void addPayment({
    required String employeName,
    required double amount,
    required String note,
    required Function setState,
  }) {
    if (paymentHistory[employeName] == null) {
      paymentHistory[employeName] = [];
    }

    paymentHistory[employeName]!.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'amount': amount,
      'note': note,
      'date': formatDate(DateTime.now()),
      'timestamp': DateTime.now().toIso8601String(),
    });

    setState(() {});
    saveAttendanceAndGroupData();
  }

  void editPayment({
    required String employeName,
    required String paymentId,
    required double newAmount,
    required String newNote,
    required Function setState,
  }) {
    if (paymentHistory[employeName] != null) {
      final paymentIndex = paymentHistory[employeName]!
          .indexWhere((payment) => payment['id'] == paymentId);

      if (paymentIndex != -1) {
        paymentHistory[employeName]![paymentIndex]['amount'] = newAmount;
        paymentHistory[employeName]![paymentIndex]['note'] = newNote;
        setState(() {});
        saveAttendanceAndGroupData();
      }
    }
  }

  void deletePayment({
    required String employeName,
    required String paymentId,
    required Function setState,
  }) {
    if (paymentHistory[employeName] != null) {
      paymentHistory[employeName]!
          .removeWhere((payment) => payment['id'] == paymentId);
      setState(() {});
      saveAttendanceAndGroupData();
    }
  }

  double getTotalPaidAmount(String employeName) {
    if (paymentHistory[employeName] == null) return 0.0;

    return paymentHistory[employeName]!
        .fold(0.0, (sum, payment) => sum + (payment['amount'] as double));
  }

  List<Map<String, dynamic>> getPaymentHistory(String employeName) {
    return paymentHistory[employeName] ?? [];
  }

  Map<String, int> getGroupStats(String groupName) {
    int totalMale = 0;
    int totalFemale = 0;

    for (var dateData in groupDataPerDate.values) {
      final groupData = dateData[groupName];
      if (groupData != null) {
        totalMale += groupData['male'] ?? 0;
        totalFemale += groupData['female'] ?? 0;
      }
    }

    return {
      'male': totalMale,
      'female': totalFemale,
    };
  }

  void addGroupPayment({
    required String groupName,
    required double amount,
    required String note,
    required Function setState,
  }) {
    if (groupPaymentHistory[groupName] == null) {
      groupPaymentHistory[groupName] = [];
    }

    groupPaymentHistory[groupName]!.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'amount': amount,
      'note': note,
      'date': formatDate(DateTime.now()),
      'timestamp': DateTime.now().toIso8601String(),
    });

    setState(() {});
    saveAttendanceAndGroupData();
  }

  void editGroupPayment({
    required String groupName,
    required String paymentId,
    required double newAmount,
    required String newNote,
    required Function setState,
  }) {
    if (groupPaymentHistory[groupName] != null) {
      final paymentIndex = groupPaymentHistory[groupName]!
          .indexWhere((payment) => payment['id'] == paymentId);

      if (paymentIndex != -1) {
        groupPaymentHistory[groupName]![paymentIndex]['amount'] = newAmount;
        groupPaymentHistory[groupName]![paymentIndex]['note'] = newNote;
        setState(() {});
        saveAttendanceAndGroupData();
      }
    }
  }

  void deleteGroupPayment({
    required String groupName,
    required String paymentId,
    required Function setState,
  }) {
    if (groupPaymentHistory[groupName] != null) {
      groupPaymentHistory[groupName]!
          .removeWhere((payment) => payment['id'] == paymentId);
      setState(() {});
      saveAttendanceAndGroupData();
    }
  }

  double getTotalGroupPaidAmount(String groupName) {
    if (groupPaymentHistory[groupName] == null) return 0.0;

    return groupPaymentHistory[groupName]!
        .fold(0.0, (sum, payment) => sum + (payment['amount'] as double));
  }

  List<Map<String, dynamic>> getGroupPaymentHistory(String groupName) {
    return groupPaymentHistory[groupName] ?? [];
  }

  void updateGroupRate({
    required String groupName,
    required String type,
    required int rate,
    required Function setState,
  }) {
    if (groupRates[groupName] != null) {
      setState(() {
        groupRates[groupName]![type] = rate;
      });
      saveAttendanceAndGroupData();
    }
  }

  Map<String, int> getGroupRates(String groupName) {
    return groupRates[groupName] ?? {"male": 200, "female": 200};
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
