import 'package:flutter/material.dart';
import 'package:lekkadapatti/components/attendance_options.dart';
import 'package:lekkadapatti/utils/date_time.dart';
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
    'Vittal',
    'Ganga',
    'Mohammad',
    'Nahida',
    'Babu Kale',
    'Sonu',
    'Jannu'
  ];

  Map<String, String> attendance = {};
  Map<String, Map<String, String>> attendanceData = {};

  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAttendanceData = prefs.getString('attendanceData');
    if (savedAttendanceData != null) {
      setState(() {
        attendanceData = Map<String, Map<String, String>>.from(
            jsonDecode(savedAttendanceData).map((key, value) =>
                MapEntry(key, Map<String, String>.from(value))));
        attendance = attendanceData[formattedDate(currentDate)] ?? {};
      });
    }
  }

  Future<void> _saveAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendanceData', jsonEncode(attendanceData));
  }

  void _setAttendance(String name, String status) {
    setState(() {
      attendance[name] = status;
    });
    _saveAttendanceData();
  }

  void _goToPreviousDay() {
    setState(() {
      attendanceData[formattedDate(currentDate)] = attendance;
      currentDate = currentDate.subtract(const Duration(days: 1));
      attendance = attendanceData[formattedDate(currentDate)] ?? {};
    });
    _saveAttendanceData();
  }

  void _goToNextDay() {
    if (currentDate.year == DateTime.now().year &&
        currentDate.month == DateTime.now().month &&
        currentDate.day == DateTime.now().day) return;

    setState(() {
      attendanceData[formattedDate(currentDate)] = attendance;
      currentDate = currentDate.add(const Duration(days: 1));
      attendance = attendanceData[formattedDate(currentDate)] ?? {};
    });
    _saveAttendanceData();
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
        attendanceData[formattedDate(currentDate)] = attendance;
        currentDate = picked;
        attendance = attendanceData[formattedDate(currentDate)] ?? {};
      });
      _saveAttendanceData();
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
            child: ListView.builder(
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
              '${formattedDate(currentDate)} ${daysINKannada[currentDate.weekday]}',
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
