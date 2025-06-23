import 'package:flutter/material.dart';
import 'package:lekkadapatti/utils/project_manager.dart';
import 'package:uuid/uuid.dart';
import 'project_details.dart';

class Work extends StatefulWidget {
  const Work({super.key});

  @override
  _WorkState createState() => _WorkState();
}

class _WorkState extends State<Work> {
  final ProjectManager projectManager = ProjectManager();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    await projectManager.loadProjects();
    setState(() {
      isLoading = false;
    });
  }

  void _addProjectDialog() async {
    String name = "";
    String group = "";
    double budget = 0.0;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Project/Contract'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Project Name'),
                onChanged: (v) => name = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Group Name'),
                onChanged: (v) => group = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Budget'),
                keyboardType: TextInputType.number,
                onChanged: (v) => budget = double.tryParse(v) ?? 0.0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && group.isNotEmpty) {
                  final project = Project(
                    id: const Uuid().v4(),
                    name: name,
                    groupName: group,
                    budget: budget,
                  );
                  projectManager.addProject(project);
                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(project.name),
        subtitle: Text('Group: ${project.groupName}\nBudget: ₹${project.budget.toStringAsFixed(2)}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetails(projectId: project.id, projectManager: projectManager),
            ),
          ).then((_) => setState(() {}));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects & Contracts')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProjects,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ongoing Projects/Contracts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addProjectDialog,
                        tooltip: 'Add Project/Contract',
                      ),
                    ],
                  ),
                  ...projectManager.projects.map(_buildProjectCard).toList(),
                  const SizedBox(height: 24),
                  const Text('Subcontracts (Forwarded)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...projectManager.projects.expand((p) => p.subContracts).map((sub) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(sub.name),
                          subtitle: Text('To Group: ${sub.toGroup}\nBudget: ₹${sub.budget.toStringAsFixed(2)}'),
                        ),
                      )),
                  // Allocated projects can be shown similarly if needed
                ],
              ),
            ),
    );
  }
}
