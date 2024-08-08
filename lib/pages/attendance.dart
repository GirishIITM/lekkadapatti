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

  Map<String, String> attendance = {};
  // Map to store attendance data with date as the key
  Map<String, Map<String, String>> attendanceData = {};

  DateTime currentDate = DateTime.now();

  void _setAttendance(String name, String status) {
    setState(() {
      attendance[name] = status;
    });
  }

  void _goToPreviousDay() {
    setState(() {
      // Save current day's attendance before changing the date and update the date
      attendanceData[_formattedDate()] = attendance;
      currentDate = currentDate.subtract(const Duration(days: 1));
      attendance = attendanceData[_formattedDate()] ?? {};
    });
  }

  void _goToNextDay() {
    if (currentDate.year == DateTime.now().year &&
        currentDate.month == DateTime.now().month &&
        currentDate.day == DateTime.now().day) return;

    setState(() {
      // Save current day's attendance before changing the date and update the date
      attendanceData[_formattedDate()] = attendance;
      currentDate = currentDate.add(const Duration(days: 1));
      attendance = attendanceData[_formattedDate()] ?? {};
    });
  }

  String _formattedDate() {
    return "${currentDate.day}-${currentDate.month}-${currentDate.year}";
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
          Text(
            _formattedDate(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _goToNextDay,
            disabledColor: Colors.grey,
            color: currentDate.isAtSameMomentAs(DateTime.now())
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
