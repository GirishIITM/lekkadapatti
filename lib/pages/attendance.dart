import 'package:flutter/material.dart';
import 'package:lekkadapatti/components/date_picker.dart';
import 'package:lekkadapatti/components/group/attendance_group.dart';
import 'package:lekkadapatti/components/individual/attendance_options.dart';
import 'package:lekkadapatti/components/individual/name_list.dart';
import 'package:lekkadapatti/utils/ui/attendance_manager.dart';
import 'package:lekkadapatti/utils/functions/date_time.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late AttendanceManager attendanceManager;

  @override
  void initState() {
    super.initState();
    attendanceManager = AttendanceManager(currentDate: DateTime.now());
    attendanceManager.loadAttendanceDataPerDate(setState: setState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: Column(
        children: [
          DatePicker(attendanceManager: attendanceManager, setState: setState),
          Expanded(
            child: ListView(
              children: [
                _buildNamesListView(),
                const Divider(),
                _buildGroupsListView(),
                const Divider(),
                _buildAddButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNamesListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attendanceManager.names.length,
      itemBuilder: (context, index) {
        String name = attendanceManager.names[index];
        return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                title: NameList(
                  names: [name],
                  attendance: attendanceManager.attendance,
                  attendanceManager: attendanceManager,
                  setState: setState,
                ),
                subtitle: AttendanceOptions(
                  name: name,
                  currentStatus: attendanceManager.attendance[name] ?? '',
                  onStatusChanged: (String name, String status) {
                    attendanceManager.setAttendance(
                      name: name,
                      status: status,
                      setState: setState,
                    );
                  },
                ),
              ),
            ));
      },
    );
  }

  Widget _buildGroupsListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attendanceManager.groups.length,
      itemBuilder: (context, index) {
        String group = attendanceManager.groups[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: AttendanceGroup(
            name: group,
            attendanceManager: attendanceManager,
            setState: setState,
            status: attendanceManager.status,
            groupName: group,
          ),
        );
      },
    );
  }

  Widget _buildAddButtons() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              String? newName = await _showNameInputDialog(context);
              if (newName != null && newName.isNotEmpty) {
                setState(() {
                  attendanceManager.names.add(newName);
                });
              }
            },
            child: const Text('Add Name'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              String? groupName = await _showNameInputDialog(context);
              if (groupName != null && groupName.isNotEmpty) {
                attendanceManager.addGroup(
                    groupName: groupName, setState: setState);
              }
            },
            child: const Text('Add Group'),
          ),
        ),
      ],
    );
  }

  Future<String?> _showNameInputDialog(BuildContext context) async {
    String name = "";
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Name'),
          content: TextField(
            onChanged: (value) {
              name = value;
            },
            decoration: const InputDecoration(hintText: "Enter name here"),
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
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
