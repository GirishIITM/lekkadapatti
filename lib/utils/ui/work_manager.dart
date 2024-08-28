// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:lekkadapatti/utils/functions/date_time.dart';
import 'package:lekkadapatti/utils/functions/logger.dart';
import 'package:lekkadapatti/utils/ui/attendance_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkManager {
  List<String> projects = [
    "Devara Mundige (ದೇವರಮುಂಡಿಗೆ)",
    "Ekaana (ಏಕಾನ)",
    "Chapegaali (ಚಾಪೆಗಾಳಿ)",
    "Nammane (ನಮ್ಮನೆ)",
    "MatthiiHakkalu (ಮತ್ತಿಹಕ್ಕಲು)",
    "Dehalli (ದೇಹಳ್ಳಿ)",
  ];

  List<String> projectTypes = [
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

  List<String> names = [
    'ವಿಠ್ಠಲ Vithal',
    'ಗಂಗಾ Ganga',
    'ಮೊಹಮ್ಮದ್ Mohammad',
    'ನಹಿದಾ Nahida',
  ];

  List<String> selectedProject = [];
  List<String> selectedProjectTypes = [];
  List<String> selectedNames = [];

  DateTime currentDate;
  Map<String, String> workDetails = {};
  Map<String, Map<String, List<String>>> workDataPerDate = {};

  WorkManager({required this.currentDate});

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('workDataPerDate');
    await prefs.remove('names');
    await prefs.remove('projectTypes');
    await prefs.remove('projects');
  }

  Future<void> loadDefaultData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedProjectTypes = prefs.getString("projectTypes");
      final savedProject = prefs.getString("projects");
      // final savedNames = prefs.getString("names");

      // if (savedNames != null) {
      // names = List<String>.from(jsonDecode(savedNames));
      // }
      if (savedProjectTypes != null) {
        projectTypes = List<String>.from(jsonDecode(savedProjectTypes));
      }
      if (savedProject != null) {
        projects = List<String>.from(jsonDecode(savedProject));
      }
    } catch (e) {
      errorLogger(e);
    }
  }

  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("names", json.encode(names));
      await prefs.setString("projectTypes", json.encode(projectTypes));
      await prefs.setString("projects", json.encode(projects));
    } catch (e) {
      errorLogger(e);
    }
  }

  Future<void> addData({String? name, String? projectType, String? project, required Function setState}) async {
    try {
      if (name != null) names.add(name);
      if (projectType != null) projectTypes.add(projectType);
      if (project != null) projects.add(project);
      setState(() {});
      await saveData();
    } catch (e) {
      errorLogger(e);
    }
  }

  Future<void> saveDataForCurrentDate(Function setState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final formatedDate = formatDate(currentDate);
      if (workDataPerDate[formatedDate] == null) workDataPerDate[formatedDate] = {};

      if (workDataPerDate[formatedDate] != null && workDataPerDate[formatedDate] != {}) {
        workDataPerDate[formatedDate]?["selectedNames"] = selectedNames;
        workDataPerDate[formatedDate]?["selectedProject"] = selectedProject;
        workDataPerDate[formatedDate]?["selectedProjectTypes"] = selectedProjectTypes;
        try {
          await prefs.setString('workDataPerDate', json.encode(workDataPerDate));
        } catch (e) {
          errorLogger(e);
        }
      }
    } catch (e) {
      errorLogger(e);
    }
  }

  Future<void> loadDataForCurrentDate({required Function setState}) async {
    loadDefaultData();
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedWorkDataPerDate = prefs.getString('workDataPerDate');

      final workedDataPerDate =
          savedWorkDataPerDate != null ? jsonDecode(savedWorkDataPerDate) : <String, Map<String, List<String>>>{};
      final workData = workedDataPerDate[formatDate(currentDate)] ??
          {
            "selectedNames": [],
            "selectedProject": [],
            "selectedProjectTypes": [],
          };

      selectedNames = List<String>.from(workData["selectedNames"] ?? []);
      selectedProject = List<String>.from(workData["selectedProject"] ?? []);
      selectedProjectTypes = List<String>.from(workData["selectedProjectTypes"] ?? []);
      setState(() {});
    } catch (e) {
      errorLogger(e);
    }
  }

  Future<void> goToPreviousDay({required Function setState}) async {
    try {
      setState(() {
        currentDate = currentDate.subtract(const Duration(days: 1));
      });
      await loadDataForCurrentDate(setState: setState);
    } catch (e) {
      errorLogger(e);
    }
  }

  Future<void> goToNextDay({required Function setState}) async {
    try {
      if (currentDate.isSameDate(DateTime.now())) return;
      setState(() {
        currentDate = currentDate.add(const Duration(days: 1));
      });
      await loadDataForCurrentDate(setState: setState);
    } catch (e) {
      errorLogger(e);
    }
  }

  void onProjectSelected(bool selected, String project, Function setState) {
    try {
      selectedProject.clear();
      selected ? selectedProject.add(project) : selectedProject.remove(project);
      setState(() {});
      saveDataForCurrentDate(setState);
    } catch (e) {
      errorLogger(e);
    }
  }

  void onProjectTypeSelected(bool selected, String projectType, Function setState) {
    try {
      selected ? selectedProjectTypes.add(projectType) : selectedProjectTypes.remove(projectType);
      setState(() {});
      saveDataForCurrentDate(setState);
    } catch (e) {
      errorLogger(e);
    }
  }

  void onNameSelected(bool selected, String name, Function setState) {
    try {
      selected ? selectedNames.add(name) : selectedNames.remove(name);
      setState(() {});
      saveDataForCurrentDate(setState);
    } catch (e) {
      errorLogger(e);
    }
  }
}
