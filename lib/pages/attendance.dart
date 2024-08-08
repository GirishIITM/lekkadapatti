import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

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

  final Map<String, String> attendance = {};

  void _setAttendance(String name, String status) {
    setState(() {
      attendance[name] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, index) {
          String name = names[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
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
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
