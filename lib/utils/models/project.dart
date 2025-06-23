import 'dart:convert';

enum ProjectStatus { ongoing, completed, paused, cancelled }
enum ContractType { taken, forwarded, allocated }

class Project {
  final String id;
  String name;
  String description;
  String clientName;
  ContractType contractType;
  ProjectStatus status;
  double budget;
  double expenses;
  DateTime startDate;
  DateTime? endDate;
  String assignedGroup;
  List<String> workplaces;
  List<String> workTypes;
  List<SubContract> subContracts;
  List<ExpenseEntry> expenseEntries;
  Map<String, dynamic> metadata;

  Project({
    required this.id,
    required this.name,
    this.description = '',
    this.clientName = '',
    this.contractType = ContractType.taken,
    this.status = ProjectStatus.ongoing,
    this.budget = 0.0,
    this.expenses = 0.0,
    required this.startDate,
    this.endDate,
    this.assignedGroup = '',
    List<String>? workplaces,
    List<String>? workTypes,
    List<SubContract>? subContracts,
    List<ExpenseEntry>? expenseEntries,
    Map<String, dynamic>? metadata,
  })  : workplaces = workplaces ?? [],
        workTypes = workTypes ?? [],
        subContracts = subContracts ?? [],
        expenseEntries = expenseEntries ?? [],
        metadata = metadata ?? {};

  double get remainingBudget => budget - expenses;
  double get budgetUtilization => budget > 0 ? (expenses / budget) * 100 : 0;
  bool get isOverBudget => expenses > budget;

  // Add method to get all groups based on workplaces
  List<String> getAssignedGroups(Map<String, String> workplaceToGroupMapping) {
    return workplaces
        .map((workplace) => workplaceToGroupMapping[workplace] ?? "")
        .where((group) => group.isNotEmpty)
        .toSet()
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'clientName': clientName,
        'contractType': contractType.toString(),
        'status': status.toString(),
        'budget': budget,
        'expenses': expenses,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'assignedGroup': assignedGroup,
        'workplaces': workplaces,
        'workTypes': workTypes,
        'subContracts': subContracts.map((s) => s.toJson()).toList(),
        'expenseEntries': expenseEntries.map((e) => e.toJson()).toList(),
        'metadata': metadata,
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        clientName: json['clientName'] ?? '',
        contractType: ContractType.values.firstWhere(
          (e) => e.toString() == json['contractType'],
          orElse: () => ContractType.taken,
        ),
        status: ProjectStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => ProjectStatus.ongoing,
        ),
        budget: (json['budget'] ?? 0.0).toDouble(),
        expenses: (json['expenses'] ?? 0.0).toDouble(),
        startDate: DateTime.parse(json['startDate']),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        assignedGroup: json['assignedGroup'] ?? '',
        workplaces: List<String>.from(json['workplaces'] ?? []),
        workTypes: List<String>.from(json['workTypes'] ?? []),
        subContracts: (json['subContracts'] as List?)?.map((s) => SubContract.fromJson(s)).toList() ?? [],
        expenseEntries: (json['expenseEntries'] as List?)?.map((e) => ExpenseEntry.fromJson(e)).toList() ?? [],
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
}

class SubContract {
  final String id;
  final String parentProjectId;
  String name;
  String description;
  String toGroup;
  double budget;
  double expenses;
  DateTime startDate;
  DateTime? endDate;
  ProjectStatus status;
  List<ExpenseEntry> expenseEntries;

  SubContract({
    required this.id,
    required this.parentProjectId,
    required this.name,
    this.description = '',
    required this.toGroup,
    this.budget = 0.0,
    this.expenses = 0.0,
    required this.startDate,
    this.endDate,
    this.status = ProjectStatus.ongoing,
    List<ExpenseEntry>? expenseEntries,
  }) : expenseEntries = expenseEntries ?? [];

  double get remainingBudget => budget - expenses;

  Map<String, dynamic> toJson() => {
        'id': id,
        'parentProjectId': parentProjectId,
        'name': name,
        'description': description,
        'toGroup': toGroup,
        'budget': budget,
        'expenses': expenses,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'status': status.toString(),
        'expenseEntries': expenseEntries.map((e) => e.toJson()).toList(),
      };

  factory SubContract.fromJson(Map<String, dynamic> json) => SubContract(
        id: json['id'],
        parentProjectId: json['parentProjectId'],
        name: json['name'],
        description: json['description'] ?? '',
        toGroup: json['toGroup'],
        budget: (json['budget'] ?? 0.0).toDouble(),
        expenses: (json['expenses'] ?? 0.0).toDouble(),
        startDate: DateTime.parse(json['startDate']),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        status: ProjectStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => ProjectStatus.ongoing,
        ),
        expenseEntries: (json['expenseEntries'] as List?)?.map((e) => ExpenseEntry.fromJson(e)).toList() ?? [],
      );
}

class ExpenseEntry {
  final String id;
  final String projectId;
  final String? subContractId;
  String description;
  double amount;
  DateTime date;
  String category;
  String? receipt;
  Map<String, dynamic> metadata;

  ExpenseEntry({
    required this.id,
    required this.projectId,
    this.subContractId,
    required this.description,
    required this.amount,
    required this.date,
    this.category = 'General',
    this.receipt,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'subContractId': subContractId,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
        'receipt': receipt,
        'metadata': metadata,
      };

  factory ExpenseEntry.fromJson(Map<String, dynamic> json) => ExpenseEntry(
        id: json['id'],
        projectId: json['projectId'],
        subContractId: json['subContractId'],
        description: json['description'],
        amount: (json['amount']).toDouble(),
        date: DateTime.parse(json['date']),
        category: json['category'] ?? 'General',
        receipt: json['receipt'],
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
}
