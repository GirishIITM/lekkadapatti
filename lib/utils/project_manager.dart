import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Project {
  final String id;
  final String name;
  final String groupName;
  double budget;
  double expenses;
  List<String> workplaces;
  List<String> workTypes;
  List<SubContract> subContracts;

  Project({
    required this.id,
    required this.name,
    required this.groupName,
    this.budget = 0.0,
    this.expenses = 0.0,
    List<String>? workplaces,
    List<String>? workTypes,
    List<SubContract>? subContracts,
  })  : workplaces = workplaces ?? [],
        workTypes = workTypes ?? [],
        subContracts = subContracts ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'groupName': groupName,
        'budget': budget,
        'expenses': expenses,
        'workplaces': workplaces,
        'workTypes': workTypes,
        'subContracts': subContracts.map((s) => s.toJson()).toList(),
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'],
        name: json['name'],
        groupName: json['groupName'],
        budget: (json['budget'] ?? 0.0).toDouble(),
        expenses: (json['expenses'] ?? 0.0).toDouble(),
        workplaces: List<String>.from(json['workplaces'] ?? []),
        workTypes: List<String>.from(json['workTypes'] ?? []),
        subContracts: (json['subContracts'] as List?)?.map((s) => SubContract.fromJson(s)).toList() ?? [],
      );
}

class SubContract {
  final String id;
  final String name;
  final String toGroup;
  double budget;
  double expenses;

  SubContract({
    required this.id,
    required this.name,
    required this.toGroup,
    this.budget = 0.0,
    this.expenses = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'toGroup': toGroup,
        'budget': budget,
        'expenses': expenses,
      };

  factory SubContract.fromJson(Map<String, dynamic> json) => SubContract(
        id: json['id'],
        name: json['name'],
        toGroup: json['toGroup'],
        budget: (json['budget'] ?? 0.0).toDouble(),
        expenses: (json['expenses'] ?? 0.0).toDouble(),
      );
}

class ProjectManager {
  List<Project> projects = [];

  Future<void> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('projects');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      projects = jsonList
          .where((e) => e is Map)
          .map((e) => Project.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  Future<void> saveProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(projects.map((e) => e.toJson()).toList());
    await prefs.setString('projects', data);
  }

  void addProject(Project project) {
    projects.add(project);
    saveProjects();
  }

  void updateProject(Project project) {
    final idx = projects.indexWhere((p) => p.id == project.id);
    if (idx != -1) {
      projects[idx] = project;
      saveProjects();
    }
  }

  Project? getProjectById(String id) {
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Project> getProjectsForGroup(String groupName) {
    return projects.where((p) => p.groupName == groupName).toList();
  }

  // Add more methods as needed for subcontracts, expenses, workplaces, work types, etc.
} 