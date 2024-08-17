import 'package:flutter/material.dart';
import 'package:lekkadapatti/components/group/group_list.dart';
import 'package:lekkadapatti/utils/attendance_manager.dart';
import 'package:lekkadapatti/utils/date_time.dart';

class AttendanceGroup extends StatelessWidget {
  final String name;
  final Map<String, Map<String, int>> status;
  final Function setState;
  final AttendanceManager attendanceManager;
  final String groupName;

  const AttendanceGroup(
      {super.key,
      required this.name,
      required this.status,
      required this.setState,
      required this.groupName,
      required this.attendanceManager});

  void onIncrement(type, count) {
    setState(() {
      attendanceManager.status[groupName]?[type] = count + 1;
      if (attendanceManager
              .groupDataPerDate[formattedDate(attendanceManager.currentDate)] ==
          null) {
        attendanceManager.groupDataPerDate[
            formattedDate(attendanceManager.currentDate)] = {};
      }
      attendanceManager.groupDataPerDate[
              formattedDate(attendanceManager.currentDate)]![groupName] =
          status[groupName]!;
    });
    attendanceManager.saveAttendanceAndGroupData();
  }

  void onDecrement(type, count) {
    setState(() {
      if (count > 0) {
        attendanceManager.status[groupName]?[type] = count - 1;
        if (attendanceManager.groupDataPerDate[
                formattedDate(attendanceManager.currentDate)] ==
            null) {
          attendanceManager.groupDataPerDate[
              formattedDate(attendanceManager.currentDate)] = {};
        }
      }
    });
    attendanceManager.saveAttendanceAndGroupData();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GroupList(
                label: name,
                attendanceManager: attendanceManager,
                setState: setState),
            const SizedBox(height: 20),
            _buildCounter('male', status[groupName]?['male'] ?? 0),
            const SizedBox(height: 20),
            _buildCounter('female', status[groupName]?['female'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(String label, int count) {
    final labelTexts = {
      "male": "Male ಗಂಡು ",
      "female": "Female ಹೆಣ್ಣು ",
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          labelTexts[label]!,
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: const Color.fromARGB(255, 236, 88, 88),
                padding: const EdgeInsets.all(15),
              ),
              onPressed: () => onDecrement(label.toLowerCase(), count),
              child: const Icon(Icons.remove, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: const Color.fromARGB(255, 0, 243, 126),
                padding: const EdgeInsets.all(15),
              ),
              onPressed: () => onIncrement(label.toLowerCase(), count),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
