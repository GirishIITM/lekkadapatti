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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown for selecting project
                  DropdownButton<String>(
                    hint: const Text("Select Project"),
                    value: workManager.selectedProject,
                    items: workManager.projects.map((String project) {
                      return DropdownMenuItem<String>(
                        value: project,
                        child: Text(project),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        workManager.selectedProject = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Dropdown for selecting project type
                  DropdownButton<String>(
                    hint: const Text("Select Project Type"),
                    value: workManager.selectedProjectType,
                    items: workManager.projectTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        workManager.selectedProjectType = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Multi-select for names using CheckboxListTile
                  Expanded(
                    child: ListView(
                      children: workManager.names.map((String name) {
                        return CheckboxListTile(
                          title: Text(name),
                          value: workManager.selectedNames.contains(name),
                          onChanged: (bool? isChecked) {
                            setState(() {
                              if (isChecked == true) {
                                workManager.selectedNames.add(name);
                              } else {
                                workManager.selectedNames.remove(name);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
