import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'models/project.dart';
import 'functions/logger.dart';

class ProjectManager {
  List<Project> projects = [];
  List<String> availableGroups = [];
  List<String> defaultWorkTypes = [
    "Kutare kelasa (ಕುಟಾರೆ ಕೆಲಸ)",
    "Shashi Neduvudu (ಶಶಿ ನೆಡುವುದು)",
    "Katti Kelasa (ಕತ್ತಿ ಕೆಲಸ)",
    "Line out (ಲೈನ್ ಔಟ್)",
    "Spray (ಸ್ಪ್ರೇ)",
    "Jeevamruta (ಜೀವಾಮೃತ)",
    "Mannu kelasa (ಮಣ್ಣು ಕೆಲಸ)",
    "Maddu hodeyudu (ಮದ್ದು ಹೊಡೆಯುದು)",
    "Kone Koyyudu (ಕೊನೆ ಕೊಯ್ಯುದು)",
  ];
  List<String> defaultWorkplaces = [
    "Devara Mundige (ದೇವರಮುಂಡಿಗೆ)",
    "Ekaana (ಏಕಾನ)",
    "Chapegaali (ಚಾಪೆಗಾಳಿ)",
    "Nammane (ನಮ್ಮನೆ)",
    "MatthiiHakkalu (ಮತ್ತಿಹಕ್ಕಲು)",
    "Dehalli (ದೇಹಳ್ಳಿ)",
  ];

  Future<void> loadProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('projects_v2');
      final groupsData = prefs.getString('available_groups');
      final workTypesData = prefs.getString('default_work_types');
      final workplacesData = prefs.getString('default_workplaces');

      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        projects = jsonList.map((e) => Project.fromJson(Map<String, dynamic>.from(e))).toList();
      }

      if (groupsData != null) {
        availableGroups = List<String>.from(jsonDecode(groupsData));
      }

      if (workTypesData != null) {
        defaultWorkTypes = List<String>.from(jsonDecode(workTypesData));
      }

      if (workplacesData != null) {
        defaultWorkplaces = List<String>.from(jsonDecode(workplacesData));
      }
    } catch (e) {
      errorLogger(e);
    }
  }

  Future<void> saveProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(projects.map((e) => e.toJson()).toList());
      await prefs.setString('projects_v2', data);
      await prefs.setString('available_groups', jsonEncode(availableGroups));
      await prefs.setString('default_work_types', jsonEncode(defaultWorkTypes));
      await prefs.setString('default_workplaces', jsonEncode(defaultWorkplaces));
    } catch (e) {
      errorLogger(e);
    }
  }

  Future<void> addProject(Project project) async {
    projects.add(project);
    await saveProjects();
  }

  Future<void> updateProject(Project project) async {
    final idx = projects.indexWhere((p) => p.id == project.id);
    if (idx != -1) {
      projects[idx] = project;
      await saveProjects();
    }
  }

  Future<void> deleteProject(String projectId) async {
    projects.removeWhere((p) => p.id == projectId);
    await saveProjects();
  }

  Project? getProjectById(String id) {
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Project> getProjectsByType(ContractType type) {
    return projects.where((p) => p.contractType == type).toList();
  }

  List<Project> getProjectsForGroup(String groupName) {
    return projects.where((p) => p.assignedGroup == groupName).toList();
  }

  List<Project> getOngoingProjects() {
    return projects.where((p) => p.status == ProjectStatus.ongoing).toList();
  }

  List<SubContract> getAllSubContracts() {
    return projects.expand((p) => p.subContracts).toList();
  }

  Future<void> addSubContract(String projectId, SubContract subContract) async {
    final project = getProjectById(projectId);
    if (project != null) {
      project.subContracts.add(subContract);
      await saveProjects();
    }
  }

  Future<void> updateSubContract(String projectId, SubContract subContract) async {
    final project = getProjectById(projectId);
    if (project != null) {
      final idx = project.subContracts.indexWhere((s) => s.id == subContract.id);
      if (idx != -1) {
        project.subContracts[idx] = subContract;
        await saveProjects();
      }
    }
  }

  Future<void> deleteSubContract(String projectId, String subContractId) async {
    final project = getProjectById(projectId);
    if (project != null) {
      project.subContracts.removeWhere((s) => s.id == subContractId);
      await saveProjects();
    }
  }

  Future<void> addExpense(String projectId, ExpenseEntry expense, {String? subContractId}) async {
    final project = getProjectById(projectId);
    if (project != null) {
      if (subContractId != null) {
        final subContract = project.subContracts.firstWhere((s) => s.id == subContractId);
        subContract.expenseEntries.add(expense);
        subContract.expenses += expense.amount;
      } else {
        project.expenseEntries.add(expense);
      }
      project.expenses += expense.amount;
      await saveProjects();
    }
  }

  Future<void> updateExpense(String projectId, ExpenseEntry expense, {String? subContractId}) async {
    final project = getProjectById(projectId);
    if (project != null) {
      ExpenseEntry? oldExpense;
      
      if (subContractId != null) {
        final subContract = project.subContracts.firstWhere((s) => s.id == subContractId);
        final idx = subContract.expenseEntries.indexWhere((e) => e.id == expense.id);
        if (idx != -1) {
          oldExpense = subContract.expenseEntries[idx];
          subContract.expenseEntries[idx] = expense;
          subContract.expenses = subContract.expenses - oldExpense.amount + expense.amount;
        }
      } else {
        final idx = project.expenseEntries.indexWhere((e) => e.id == expense.id);
        if (idx != -1) {
          oldExpense = project.expenseEntries[idx];
          project.expenseEntries[idx] = expense;
        }
      }
      
      if (oldExpense != null) {
        project.expenses = project.expenses - oldExpense.amount + expense.amount;
        await saveProjects();
      }
    }
  }

  Future<void> deleteExpense(String projectId, String expenseId, {String? subContractId}) async {
    final project = getProjectById(projectId);
    if (project != null) {
      ExpenseEntry? removedExpense;
      
      if (subContractId != null) {
        final subContract = project.subContracts.firstWhere((s) => s.id == subContractId);
        removedExpense = subContract.expenseEntries.firstWhere((e) => e.id == expenseId);
        subContract.expenseEntries.removeWhere((e) => e.id == expenseId);
        subContract.expenses -= removedExpense.amount;
      } else {
        removedExpense = project.expenseEntries.firstWhere((e) => e.id == expenseId);
        project.expenseEntries.removeWhere((e) => e.id == expenseId);
      }
      
      project.expenses -= removedExpense.amount;
      await saveProjects();
    }
  }

  Future<void> addWorkType(String workType) async {
    if (!defaultWorkTypes.contains(workType)) {
      defaultWorkTypes.add(workType);
      await saveProjects();
    }
  }

  Future<void> addWorkplace(String workplace) async {
    if (!defaultWorkplaces.contains(workplace)) {
      defaultWorkplaces.add(workplace);
      await saveProjects();
    }
  }

  Future<void> updateAvailableGroups(List<String> groups) async {
    availableGroups = List.from(groups);
    await saveProjects();
  }

  Map<String, double> getProjectFinancialSummary() {
    double totalBudget = 0;
    double totalExpenses = 0;
    double totalRevenue = 0;

    for (var project in projects) {
      totalBudget += project.budget;
      totalExpenses += project.expenses;
      if (project.contractType == ContractType.taken) {
        totalRevenue += project.budget;
      }
    }

    return {
      'totalBudget': totalBudget,
      'totalExpenses': totalExpenses,
      'totalRevenue': totalRevenue,
      'profit': totalRevenue - totalExpenses,
    };
  }

  List<Project> searchProjects(String query) {
    final lowerQuery = query.toLowerCase();
    return projects.where((p) => 
      p.name.toLowerCase().contains(lowerQuery) ||
      p.description.toLowerCase().contains(lowerQuery) ||
      p.clientName.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}