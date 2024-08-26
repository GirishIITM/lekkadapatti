import 'package:flutter/material.dart';
import 'package:lekkadapatti/utils/ui/attendance_manager.dart';
import 'package:lekkadapatti/utils/functions/date_time.dart';
import 'package:lekkadapatti/utils/ui/work_manager.dart';

class DatePicker extends StatelessWidget {
  final Function setState;
  final WorkManager workManager;

  const DatePicker(
      {super.key, required this.setState, required this.workManager});

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: workManager.currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != workManager.currentDate) {
      setState(() {
        workManager.currentDate = picked;
        workManager.loadDataForCurrentDate(setState: setState);
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
            onPressed: () => workManager.goToPreviousDay(setState: setState),
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Text(
              '${formatDate(workManager.currentDate)} ${daysInKannada[workManager.currentDate.weekday - 1]}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => workManager.goToNextDay(setState: setState),
            disabledColor: Colors.grey,
            color: workManager.currentDate.isSameDate(DateTime.now())
                ? Colors.grey
                : null,
          ),
        ],
      ),
    );
  }
}
