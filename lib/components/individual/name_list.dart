import 'package:flutter/material.dart';
import 'package:lekkadapatti/utils/ui/attendance_manager.dart';

class NameList extends StatelessWidget {
  final List<String> names;
  final Map<String, String> attendance;
  final AttendanceManager attendanceManager;
  final Function setState;

  const NameList({
    super.key,
    required this.names,
    required this.attendance,
    required this.attendanceManager,
    required this.setState,
  });

  void onDeleteTap(String name) {
    attendanceManager.deleteName(name: name, setState: setState);
  }

  Future<String?> _showEditInputDialog(
      BuildContext context, String oldName) async {
    String name = oldName;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Name'),
          content: TextField(
            onChanged: (value) {
              name = value;
            },
            decoration: const InputDecoration(
              hintText: "Enter name here",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(name);
                attendanceManager.editName(
                    oldName: oldName, newName: name, setState: setState);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: names.length,
      itemBuilder: (context, index) {
        String name = names[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            PopupMenuButton(itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const Text('delete'),
                  onTap: () => onDeleteTap(name),
                ),
                PopupMenuItem(
                  child: const Text('edit'),
                  onTap: () => _showEditInputDialog(context, name),
                ),
              ];
            }),
          ],
        );
      },
    );
  }
}
