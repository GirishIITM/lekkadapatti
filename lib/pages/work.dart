import 'package:flutter/material.dart';
import 'package:lekkadapatti/utils/project_manager.dart';
import 'package:lekkadapatti/utils/models/project.dart';
import 'package:uuid/uuid.dart';
import 'project_details.dart';
import 'package:lekkadapatti/utils/ui/attendance_manager.dart';

class Work extends StatefulWidget {
  const Work({super.key});

  @override
  _WorkState createState() => _WorkState();
}

class _WorkState extends State<Work> with TickerProviderStateMixin {
  final ProjectManager projectManager = ProjectManager();
  final AttendanceManager attendanceManager = AttendanceManager(currentDate: DateTime.now());
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await projectManager.loadProjects();
    await attendanceManager.loadAttendanceDataPerDate(setState: setState);
    // Sync available groups
    await projectManager.updateAvailableGroups(attendanceManager.groups);
    setState(() {
      isLoading = false;
    });
  }

  void _addProjectDialog() async {
    String name = "";
    String description = "";
    String clientName = "";
    ContractType contractType = ContractType.taken;
    double budget = 0.0;
    List<String> selectedWorkplaces = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Project/Contract'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Project Name *'),
                      onChanged: (v) => name = v,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Description'),
                      onChanged: (v) => description = v,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Client Name'),
                      onChanged: (v) => clientName = v,
                    ),
                    const SizedBox(height: 8),
                    const Text('Select Workplaces:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: projectManager.defaultWorkplaces.map((workplace) {
                        final isSelected = selectedWorkplaces.contains(workplace);
                        return FilterChip(
                          label: Text(workplace),
                          selected: isSelected,
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                selectedWorkplaces.add(workplace);
                              } else {
                                selectedWorkplaces.remove(workplace);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ContractType>(
                      decoration: const InputDecoration(labelText: 'Contract Type'),
                      value: contractType,
                      items: ContractType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getContractTypeDisplayName(type)),
                        );
                      }).toList(),
                      onChanged: (v) => setDialogState(() => contractType = v ?? ContractType.taken),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Budget'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => budget = double.tryParse(v) ?? 0.0,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (name.isNotEmpty && selectedWorkplaces.isNotEmpty) {
                      final project = Project(
                        id: const Uuid().v4(),
                        name: name,
                        description: description,
                        clientName: clientName,
                        contractType: contractType,
                        budget: budget,
                        startDate: DateTime.now(),
                        workplaces: selectedWorkplaces,
                        workTypes: List.from(projectManager.defaultWorkTypes),
                      );
                      await projectManager.addProject(project);
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
      },
    );
  }

  String _getContractTypeDisplayName(ContractType type) {
    switch (type) {
      case ContractType.taken:
        return 'Ongoing Projects (Taken)';
      case ContractType.forwarded:
        return 'Sub Contracts (Forwarded)';
      case ContractType.allocated:
        return 'Allocated Projects';
    }
  }

  Widget _buildProjectCard(Project project) {
    Color statusColor = project.isOverBudget ? Colors.red : Colors.green;
    IconData statusIcon = project.isOverBudget ? Icons.warning : Icons.check_circle;
    
    // Get assigned groups based on workplaces
    final assignedGroups = project.getAssignedGroups(attendanceManager.workplaceToGroupMapping);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.clientName.isNotEmpty) Text('Client: ${project.clientName}'),
            if (assignedGroups.isNotEmpty) Text('Groups: ${assignedGroups.join(", ")}'),
            if (project.workplaces.isNotEmpty) Text('Workplaces: ${project.workplaces.join(", ")}'),
            Text('Budget: ₹${project.budget.toStringAsFixed(2)}'),
            Text('Expenses: ₹${project.expenses.toStringAsFixed(2)}'),
            Text(
              'Balance: ₹${project.remainingBudget.toStringAsFixed(2)}',
              style: TextStyle(
                color: project.isOverBudget ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetails(
                projectId: project.id,
                projectManager: projectManager,
              ),
            ),
          ).then((_) => setState(() {}));
        },
      ),
    );
  }

  Widget _buildSubContractCard(SubContract subContract) {
    final parentProject = projectManager.getProjectById(subContract.parentProjectId);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.forward, color: Colors.white),
        ),
        title: Text(subContract.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To Group: ${subContract.toGroup}'),
            if (parentProject != null) Text('Parent: ${parentProject.name}'),
            Text('Budget: ₹${subContract.budget.toStringAsFixed(2)}'),
            Text('Expenses: ₹${subContract.expenses.toStringAsFixed(2)}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to sub-contract details if needed
        },
      ),
    );
  }

  Widget _buildFinancialSummary() {
    final summary = projectManager.getProjectFinancialSummary();
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Financial Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Budget:'),
                Text('₹${summary['totalBudget']!.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Expenses:'),
                Text('₹${summary['totalExpenses']!.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Profit/Loss:'),
                Text(
                  '₹${summary['profit']!.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: summary['profit']! >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects & Contracts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ongoing', icon: Icon(Icons.work)),
            Tab(text: 'Sub Contracts', icon: Icon(Icons.forward)),
            Tab(text: 'Allocated', icon: Icon(Icons.assignment)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProjectDialog,
        tooltip: 'Add Project/Contract',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            _buildFinancialSummary(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Ongoing Projects
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...projectManager.getProjectsByType(ContractType.taken)
                          .map(_buildProjectCard).toList(),
                      if (projectManager.getProjectsByType(ContractType.taken).isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No ongoing projects'),
                          ),
                        ),
                    ],
                  ),
                  // Sub Contracts
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...projectManager.getAllSubContracts()
                          .map(_buildSubContractCard).toList(),
                      if (projectManager.getAllSubContracts().isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No sub contracts'),
                          ),
                        ),
                    ],
                  ),
                  // Allocated Projects
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...projectManager.getProjectsByType(ContractType.allocated)
                          .map(_buildProjectCard).toList(),
                      if (projectManager.getProjectsByType(ContractType.allocated).isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No allocated projects'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
