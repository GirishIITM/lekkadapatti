import 'package:flutter/material.dart';
import 'attendance_options.dart';

class NameList extends StatelessWidget {
  final List<String> names;
  final Map<String, String> attendance;
  final Function(String, String) setAttendance;

  const NameList({
    Key? key,
    required this.names,
    required this.attendance,
    required this.setAttendance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: names.length,
      itemBuilder: (context, index) {
        String name = names[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                onStatusChanged: setAttendance,
              ),
            ),
          ),
        );
      },
    );
  }
}
