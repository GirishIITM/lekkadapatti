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
  late WorkManager workManager;
  DateTime? _lastDate;

  @override
  void initState() {
    super.initState();
    workManager = WorkManager(currentDate: widget.currentDate);
    _lastDate = widget.currentDate;
    _loadWorkData();
  }

  @override
  void didUpdateWidget(covariant AttendanceGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_lastDate != widget.currentDate) {
      workManager.currentDate = widget.currentDate;
      _lastDate = widget.currentDate;
      _loadWorkData();
    }
  }

  Future<void> _loadWorkData() async {
    await workManager.loadDefaultData();
    setState(() {});
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
    final selectedProjects = workManager.getGroupSelectedWorkplaces(widget.groupName);

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
          children: workManager.projects.map((project) {
            final isSelected = selectedProjects.contains(project);
            return FilterChip(
              label: Text(
                project,
                style: const TextStyle(fontSize: 12),
              ),
              selected: isSelected,
              onSelected: (selected) {
                workManager.onGroupWorkplaceSelected(
                  selected,
                  widget.groupName,
                  project,
                  setState,
                );
                widget.setState(() {});
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
