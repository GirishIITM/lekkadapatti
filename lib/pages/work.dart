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
            Column(
              children: workManager.projects.map((project) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(project),
                );
              }).toList(),
            ),
          ],
        ));
  }
}
