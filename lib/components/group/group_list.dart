import 'package:flutter/material.dart';
import 'package:lekkadapatti/utils/ui/attendance_manager.dart';

class GroupList extends StatelessWidget {
  final String label;
  final AttendanceManager attendanceManager;
  final Function setState;

  const GroupList(
      {super.key,
      required this.label,
      required this.attendanceManager,
      required this.setState});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blueAccent,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'delete') {
              attendanceManager.deleteGroup(
                  groupName: label, setState: setState);
            } else if (value == 'edit') {
              // Handle edit option
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete'),
            ),
            const PopupMenuItem<String>(
              value: 'edit',
              child: Text('Edit'),
            ),
          ],
        ),
      ],
    );
  }
}
