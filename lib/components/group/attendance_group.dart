import 'package:flutter/material.dart';
import 'package:lekkadapatti/components/group/group_list.dart';
import 'package:lekkadapatti/pages/group_details.dart';
import 'package:lekkadapatti/utils/ui/attendance_manager.dart';
import 'package:lekkadapatti/utils/ui/work_manager.dart';
import 'package:lekkadapatti/utils/functions/date_time.dart';

class AttendanceGroup extends StatefulWidget {
  final String name;
  final Map<String, Map<String, int>> status;
  final Function setState;
  final AttendanceManager attendanceManager;
  final String groupName;
  final DateTime currentDate;

  const AttendanceGroup(
      {super.key,
      required this.name,
      required this.status,
      required this.setState,
      required this.groupName,
      required this.attendanceManager,
      required this.currentDate});

  @override
  State<AttendanceGroup> createState() => _AttendanceGroupState();
}

class _AttendanceGroupState extends State<AttendanceGroup> {
  late List<String> selectedProjects;
  late List<String> selectedWorkTypes;

  @override
  void initState() {
    super.initState();
    _loadSelections();
  }

  @override
  void didUpdateWidget(covariant AttendanceGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDate != widget.currentDate) {
      _loadSelections();
    }
  }

  void _loadSelections() {
    selectedProjects = widget.attendanceManager.getGroupSelectedProjects(widget.groupName);
    selectedWorkTypes = widget.attendanceManager.getGroupSelectedWorkTypes(widget.groupName);
    setState(() {});
  }

  void _onWorkTypeSelected(bool selected, String workType) {
    widget.attendanceManager.onGroupWorkTypeSelected(
      selected,
      widget.groupName,
      workType,
      setState,
    );
    _loadSelections();
  }

  Future<void> _showAddWorkTypeDialog() async {
    String workType = "";
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Work Type'),
          content: TextField(
            onChanged: (value) {
              workType = value;
            },
            decoration: const InputDecoration(hintText: "Enter work type here"),
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
                if (workType.isNotEmpty) {
                  widget.attendanceManager.addWorkType(
                    workType: workType,
                    setState: setState,
                  );
                  _onWorkTypeSelected(true, workType);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupDetails(
              groupName: widget.groupName,
              attendanceManager: widget.attendanceManager,
            ),
          ),
        );
      },
      child: Card(
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
                  label: widget.name,
                  attendanceManager: widget.attendanceManager,
                  setState: widget.setState),
              const SizedBox(height: 20),
              _buildWorkplaceSelection(),
              const SizedBox(height: 20),
              _buildWorkTypeSelection(),
              const SizedBox(height: 20),
              _buildCounter('male', widget.status[widget.groupName]?['male'] ?? 0),
              const SizedBox(height: 20),
              _buildCounter('female', widget.status[widget.groupName]?['female'] ?? 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkplaceSelection() {
    final selectedProjects = widget.attendanceManager.getGroupSelectedProjects(widget.groupName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Workplace:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              formatDate(widget.currentDate),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: widget.attendanceManager.projects.map((project) {
            final isSelected = selectedProjects.contains(project);
            return FilterChip(
              label: Text(
                project,
                style: const TextStyle(fontSize: 12),
              ),
              selected: isSelected,
              onSelected: (selected) {
                widget.attendanceManager.onGroupProjectSelected(
                  selected,
                  widget.groupName,
                  project,
                  setState,
                );
                _loadSelections();
              },
              selectedColor: Colors.blue.withOpacity(0.3),
              checkmarkColor: Colors.blue,
            );
          }).toList(),
        ),
        if (selectedProjects.isEmpty)
          Text(
            "No workplace selected for ${formatDate(widget.currentDate)}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildWorkTypeSelection() {
    final selectedWorkTypes = widget.attendanceManager.getGroupSelectedWorkTypes(widget.groupName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Work Types:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddWorkTypeDialog,
              tooltip: 'Add Work Type',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: widget.attendanceManager.workTypes.map((workType) {
            final isSelected = selectedWorkTypes.contains(workType);
            return FilterChip(
              label: Text(
                workType,
                style: const TextStyle(fontSize: 12),
              ),
              selected: isSelected,
              onSelected: (selected) {
                _onWorkTypeSelected(selected, workType);
              },
              selectedColor: Colors.green.withOpacity(0.3),
              checkmarkColor: Colors.green,
            );
          }).toList(),
        ),
        if (selectedWorkTypes.isEmpty)
          const Text(
            "No work type selected for this date.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
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
              onPressed: () => widget.attendanceManager.onDecrement(
                  widget.groupName, label.toLowerCase(), count, widget.setState),
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
              onPressed: () => widget.attendanceManager.onIncrement(
                  widget.groupName, label.toLowerCase(), count, widget.setState),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
