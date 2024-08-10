import 'package:flutter/material.dart';
import 'attendance_group.dart';

class GroupList extends StatelessWidget {
  final List<String> groups;
  final Map<String, int> status;
  final Function(String, int) setStatus;

  const GroupList({
    Key? key,
    required this.groups,
    required this.status,
    required this.setStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        String group = groups[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: AttendanceGroup(
            name: group,
            status: status,
            onIncrement: (type, count) => setStatus(type, count + 1),
            onDecrement: (type, count) {
              if (count > 0) {
                setStatus(type, count - 1);
              }
            },
          ),
        );
      },
    );
  }
}
