import 'package:flutter/material.dart';
import 'package:lekkadapatti/components/group/attendance_group.dart';
import 'package:lekkadapatti/components/individual/attendance_options.dart';
import 'package:lekkadapatti/components/individual/name_list.dart';
import 'package:lekkadapatti/utils/attendance_manager.dart';
import 'package:lekkadapatti/utils/date_time.dart';

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
          _buildDateNavigation(),
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
                  onStatusChanged: (status, name) {
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
                setState(() {
                  attendanceManager.groups.add(groupName);
                });
              }
            },
            child: const Text('Add Group'),
          ),
        ),
      ],
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
