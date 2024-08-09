import 'package:flutter/material.dart';
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
    print(savedAttendanceData);
    if (savedAttendanceData != null) {
      setState(() {
        attendanceData = Map<String, Map<String, String>>.from(
            jsonDecode(savedAttendanceData).map((key, value) =>
                MapEntry(key, Map<String, String>.from(value))));
        attendance = attendanceData[_formattedDate()] ?? {};
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
      attendanceData[_formattedDate()] = attendance;
      currentDate = currentDate.subtract(const Duration(days: 1));
      attendance = attendanceData[_formattedDate()] ?? {};
    });
    _saveAttendanceData();
  }

  void _goToNextDay() {
    if (currentDate.year == DateTime.now().year &&
        currentDate.month == DateTime.now().month &&
        currentDate.day == DateTime.now().day) return;

    setState(() {
      attendanceData[_formattedDate()] = attendance;
      currentDate = currentDate.add(const Duration(days: 1));
      attendance = attendanceData[_formattedDate()] ?? {};
    });
    _saveAttendanceData();
  }

  String _formattedDate() {
    return "${currentDate.day}/${currentDate.month}/${currentDate.year}";
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
        attendanceData[_formattedDate()] = attendance;
        currentDate = picked;
        attendance = attendanceData[_formattedDate()] ?? {};
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
              '${_formattedDate()} ${daysINKannada[currentDate.weekday]}',
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

class AttendanceOptions extends StatelessWidget {
  final String name;
  final String currentStatus;
  final Function(String, String) onStatusChanged;

  const AttendanceOptions({
    super.key,
    required this.name,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildOption('Present', Colors.green),
        _buildOption('Absent', Colors.red),
        _buildOption('Half Day', Colors.orange),
      ],
    );
  }

  Widget _buildOption(String status, Color color) {
    return GestureDetector(
      onTap: () => onStatusChanged(name, status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              currentStatus == status ? color.withOpacity(0.7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          status,
          style:
              TextStyle(color: currentStatus == status ? Colors.white : color),
        ),
      ),
    );
  }
}
