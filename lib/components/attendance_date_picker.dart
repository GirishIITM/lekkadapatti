import 'package:flutter/material.dart';
import 'package:lekkadapatti/utils/ui/attendance_manager.dart';
import 'package:lekkadapatti/utils/functions/date_time.dart';

class DatePicker extends StatelessWidget {
  final Function setState;
  final AttendanceManager attendanceManager;

  const DatePicker(
      {super.key, required this.setState, required this.attendanceManager});

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: attendanceManager.currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != attendanceManager.currentDate) {
      setState(() {
        attendanceManager.currentDate = picked;
        attendanceManager.loadDataForCurrentDate(setState: setState);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                attendanceManager.goToPreviousDay(setState: setState),
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Text(
              '${formattedDate(attendanceManager.currentDate)} ${daysInKannada[attendanceManager.currentDate.weekday - 1]}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => attendanceManager.goToNextDay(setState: setState),
            disabledColor: Colors.grey,
            color: attendanceManager.currentDate.isSameDate(DateTime.now())
                ? Colors.grey
                : null,
          ),
        ],
      ),
    );
  }
}
