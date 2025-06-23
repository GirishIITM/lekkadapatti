import 'package:flutter/material.dart';
import 'package:lekkadapatti/utils/models/project.dart';
import 'package:lekkadapatti/utils/project_manager.dart';

class ProjectDetails extends StatefulWidget {
  final String projectId;
  final ProjectManager projectManager;

  const ProjectDetails({super.key, required this.projectId, required this.projectManager});

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  late Project? project;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  void _loadProject() {
    setState(() {
      project = widget.projectManager.getProjectById(widget.projectId);
      isLoading = false;
    });
  }

  void _addWorkplaceDialog() async {
    String workplace = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Workplace'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Workplace'),
          onChanged: (v) => workplace = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (workplace.isNotEmpty && project != null) {
                setState(() {
                  project!.workplaces.add(workplace);
                  widget.projectManager.updateProject(project!);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addWorkTypeDialog() async {
    String workType = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Work Type'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Work Type'),
          onChanged: (v) => workType = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (workType.isNotEmpty && project != null) {
                setState(() {
                  project!.workTypes.add(workType);
                  widget.projectManager.updateProject(project!);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addExpenseDialog() async {
    double expense = 0.0;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Expense Amount'),
          keyboardType: TextInputType.number,
          onChanged: (v) => expense = double.tryParse(v) ?? 0.0,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (expense > 0 && project != null) {
                setState(() {
                  project!.expenses += expense;
                  widget.projectManager.updateProject(project!);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || project == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      appBar: AppBar(title: Text(project!.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Budget: ₹${project!.budget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Expenses: ₹${project!.expenses.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Balance: ₹${(project!.budget - project!.expenses).toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Workplaces', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add), onPressed: _addWorkplaceDialog),
              ],
            ),
            ...project!.workplaces.map((w) => ListTile(title: Text(w))).toList(),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Work Types', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add), onPressed: _addWorkTypeDialog),
              ],
            ),
            ...project!.workTypes.map((w) => ListTile(title: Text(w))).toList(),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add), onPressed: _addExpenseDialog),
              ],
            ),
            ListTile(title: Text('Total Expenses: ₹${project!.expenses.toStringAsFixed(2)}')),
          ],
        ),
      ),
    );
  }
}