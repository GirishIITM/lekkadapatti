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
    workManager.loadDataForCurrentDate(setState: setState);
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Place", style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      children: workManager.projects.map((String project) {
                        return FilterChip(
                          label: Text(project),
                          selected: workManager.selectedProject == project,
                          onSelected: (bool selected) {
                            workManager.onProjectSelected(
                                selected, project, setState);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text("Work Types", style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      children:
                          workManager.projectTypes.map((String projectType) {
                        return FilterChip(
                          label: Text(projectType),
                          selected: workManager.selectedProjectTypes
                              .contains(projectType),
                          onSelected: (bool selected) {
                            workManager.onProjectTypeSelected(
                                selected, projectType, setState);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text("Names", style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      children: workManager.names.map((String name) {
                        return FilterChip(
                          label: Text(name),
                          selected: workManager.selectedNames.contains(name),
                          onSelected: (bool selected) {
                            workManager.onNameSelected(
                                selected, name, setState);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
