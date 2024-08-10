import 'package:flutter/material.dart';
import 'package:lekkadapatti/components/attendance_group.dart';
import 'package:lekkadapatti/components/attendance_options.dart';
import 'package:lekkadapatti/utils/date_time.dart';
import 'package:lekkadapatti/utils/gheet_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

final List<String> daysINKannada = [
  'ಭಾನುವಾರ',
  'ಸೋಮವಾರ',
  'ಮಂಗಳವಾರ',
  'ಬುಧವಾರ',
  'ಗುರುವಾರ',
  'ಶುಕ್ರವಾರ',
  'ಶನಿವಾರ'
];

class _AttendanceScreenState extends State<AttendanceScreen> {
  final List<String> names = [
    'ವಿಠ್ಠಲ Vithal',
    'ಗಂಗಾ Ganga',
    'ಮೊಹಮ್ಮದ್ Mohammad',
    'ನಹಿದಾ Nahida',
  ];

  final List<String> groups = ["Hindesgeri (ಹಿಂಡಸಗೇರಿ)"];

  Map<String, String> attendance = {};
  Map<String, Map<String, String>> attendanceDataPerDate = {};
  Map<String, Map<String, int>> groupDataPerDate = {};

  DateTime currentDate = DateTime.now();

  Map<String, int> status = {
    "male": 0,
    "female": 0,
  };

  @override
  void initState() {
    super.initState();
    _loadAttendanceDataPerDate();
  }
Future<void> _loadAttendanceDataPerDate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAttendanceDataPerDate = prefs.getString('attendanceDataPerDate');
    final savedGroupDataPerDate = prefs.getString('groupDataPerDate');

    if (savedAttendanceDataPerDate != null) {
      setState(() {
        attendanceDataPerDate = Map<String, Map<String, String>>.from(
            jsonDecode(savedAttendanceDataPerDate).map((key, value) =>
                MapEntry(key, Map<String, String>.from(value))));
      });
    }

    if (savedGroupDataPerDate != null) {
      setState(() {
        groupDataPerDate = Map<String, Map<String, int>>.from(
            jsonDecode(savedGroupDataPerDate).map(
                (key, value) => MapEntry(key, Map<String, int>.from(value))));
      });
    }

    setState(() {
      attendance = attendanceDataPerDate[formattedDate(currentDate)] ?? {};
      status = groupDataPerDate[formattedDate(currentDate)] ??
          {"male": 0, "female": 0};
    });
  }

  Future<void> _saveAttendanceAndGroupData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'attendanceDataPerDate', jsonEncode(attendanceDataPerDate));
    await prefs.setString('groupDataPerDate', jsonEncode(groupDataPerDate));
  }

  void _setAttendance(String name, String status) {
    setState(() {
      attendance[name] = status;
    });
    _saveAttendanceAndGroupData();
    insertData(currentDate,
        {'Name': status, 'Date': dateToGsheets(currentDate), 'Status': status});
  }

  void _goToPreviousDay() {
    setState(() {
      attendanceDataPerDate[formattedDate(currentDate)] = attendance;
      groupDataPerDate[formattedDate(currentDate)] = status;
      currentDate = currentDate.subtract(const Duration(days: 1));
      attendance = attendanceDataPerDate[formattedDate(currentDate)] ?? {};
      status = groupDataPerDate[formattedDate(currentDate)] ??
          {"male": 0, "female": 0};
    });
    _saveAttendanceAndGroupData();
  }

  void _goToNextDay() {
    if (currentDate.year == DateTime.now().year &&
        currentDate.month == DateTime.now().month &&
        currentDate.day == DateTime.now().day) return;

    setState(() {
      attendanceDataPerDate[formattedDate(currentDate)] = attendance;
      groupDataPerDate[formattedDate(currentDate)] = status;
      currentDate = currentDate.add(const Duration(days: 1));
      attendance = attendanceDataPerDate[formattedDate(currentDate)] ?? {};
      status = groupDataPerDate[formattedDate(currentDate)] ??
          {"male": 0, "female": 0};
    });
    _saveAttendanceAndGroupData();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != currentDate) {
      setState(() {
        attendanceDataPerDate[formattedDate(currentDate)] = attendance;
        currentDate = picked;
        attendance = attendanceDataPerDate[formattedDate(currentDate)] ?? {};
      });
      _saveAttendanceAndGroupData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: Column(
        children: [
          _buildDateNavigation(),
          Expanded(
            child: ListView(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: names.length,
                  itemBuilder: (context, index) {
                    String name = names[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: AttendanceOptions(
                            name: name,
                            currentStatus: attendance[name] ?? '',
                            onStatusChanged: _setAttendance,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(), // Optional: To separate names and groups visually
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    String group = groups[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: AttendanceGroup(
                        name: group,
                        status: status,
                        onIncrement: (type, count) {
                          setState(() {
                            status[type] = count + 1;
                          });
                        },
                        onDecrement: (type, count) {
                          setState(() {
                            if (count > 0) {
                              status[type] = count - 1;
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigation() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goToPreviousDay,
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Text(
              '${formattedDate(currentDate)} ${daysINKannada[currentDate.weekday - 1]}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _goToNextDay,
            disabledColor: Colors.grey,
            color: currentDate.year == DateTime.now().year &&
                    currentDate.month == DateTime.now().month &&
                    currentDate.day == DateTime.now().day
                ? Colors.grey
                : null,
          ),
        ],
      ),
    );
  }
}
