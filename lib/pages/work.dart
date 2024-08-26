import 'package:flutter/material.dart';
import 'package:lekkadapatti/components/work_date_picker.dart';
import 'package:lekkadapatti/utils/ui/work_manager.dart';

class Work extends StatefulWidget {
  const Work({super.key});

  @override
  _WorkState createState() => _WorkState();
}

class _WorkState extends State<Work> {
  late WorkManager workManager;

  @override
  void initState() {
    super.initState();
    workManager = WorkManager(currentDate: DateTime.now());
    _loadData();
  }

  Future<void> _loadData() async {
    await workManager.loadDataForCurrentDate(setState: setState);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildChipSection(String title, List<String> items,
      bool Function(String) isSelected, Function(bool, String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: items
              .map((item) => FilterChip(
                    label: Text(item),
                    selected: isSelected(item),
                    onSelected: (selected) => onSelected(selected, item),
                  ))
              .toList(),
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

  Widget _buildAddButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Wrap(
        spacing: 8.0,
        alignment: WrapAlignment.center,
        children: [
          // ElevatedButton(
          //   onPressed: () => _showNameInputDialog(context).then((newName) =>
          //       workManager.addData(setState: setState, name: newName)),
          //   child: const Text('Add name'),
          // ),
          ElevatedButton(
            onPressed: () => _showNameInputDialog(context).then((newGroup) =>
                workManager.addData(setState: setState, project: newGroup)),
            child: const Text('Add place'),
          ),
          ElevatedButton(
            onPressed: () => workManager.addData(
                setState: setState, projectType: 'New Work Type'),
            child: const Text('Add type'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
      ),
      body: Column(
        children: [
          DatePicker(setState: setState, workManager: workManager),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildChipSection(
                    "Place",
                    workManager.projects,
                    (project) => workManager.selectedProject.contains(project),
                    (selected, project) => workManager.onProjectSelected(
                        selected, project, setState),
                  ),
                  _buildChipSection(
                    "Work Types",
                    workManager.projectTypes,
                    (type) => workManager.selectedProjectTypes.contains(type),
                    (selected, type) => workManager.onProjectTypeSelected(
                        selected, type, setState),
                  ),
                  // _buildChipSection(
                  //   "Names",
                  //   workManager.names,
                  //   (name) => workManager.selectedNames.contains(name),
                  //   (selected, name) =>
                  //       workManager.onNameSelected(selected, name, setState),
                  // ),
                  _buildAddButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
