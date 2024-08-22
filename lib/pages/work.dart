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
                    (project) => workManager.selectedProject == project,
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
                  _buildChipSection(
                    "Names",
                    workManager.names,
                    (name) => workManager.selectedNames.contains(name),
                    (selected, name) =>
                        workManager.onNameSelected(selected, name, setState),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
