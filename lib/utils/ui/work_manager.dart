import 'dart:convert';

import 'package:lekkadapatti/utils/ui/attendance_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkManager {
  List<String> projects = [
    "Devara Mundige (ದೇವರಮುಂಡಿಗೆ)",
    "Ekaana (ಏಕಾನ)",
    "Chapegaali (ಚಾಪೆಗಾಳಿ)",
    "Nammane (ನಮ್ಮನೆ)",
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

  String? selectedProject;
  List<String> selectedProjectTypes = [];
  List<String> selectedNames = [];

  DateTime currentDate;
  Map<String, String> workDetails = {};
  Map<String, Object> workDataPerDate = {
    "selectedNames": [],
    "selectedProject": "",
    "selectedProjectTypes": [],
  };
  WorkManager({required this.currentDate});

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedNames = prefs.getString("names");
    final savedProjects = prefs.getString("projects");
    final savedProjectTypes = prefs.getString("projectTypes");
    if (savedNames != null) {
      names = List<String>.from(jsonDecode(savedNames));
    }
    if (savedProjects != null) {
      projects = List<String>.from(jsonDecode(savedProjects));
    }
    if (savedProjectTypes != null) {
      projectTypes = List<String>.from(jsonDecode(savedProjectTypes));
    }
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('workDataPerDate');
  }

  Future<void> saveDataForCurrentDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workDataPerDate', json.encode(workDataPerDate));
  }

  Future<void> loadDataForCurrentDate({required Function setState}) async {
    final prefs = await SharedPreferences.getInstance();
    final savedWorkDataPerDate = prefs.getString('workDataPerDate');
    if (savedWorkDataPerDate != null) {
      final parsedData = json.decode(savedWorkDataPerDate);
      setState(() {
        selectedNames = List<String>.from(parsedData["selectedNames"]);
        selectedProject = parsedData["selectedProject"];
        selectedProjectTypes =
            List<String>.from(parsedData["selectedProjectTypes"]);
        workDataPerDate = parsedData.map((key, value) {
          if (key == "selectedNames") {
            return MapEntry(key, List<String>.from(value));
          } else if (key == "selectedProjectTypes") {
            return MapEntry(key, List<String>.from(value));
          } else {
            return MapEntry(key, value);
          }
        });
      });
    }
    loadData();
  }

  Future<void> goToPreviousDay({required Function setState}) async {
    setState(() {
      currentDate = currentDate.subtract(const Duration(days: 1));
    });
    await loadDataForCurrentDate(setState: setState);
  }

  Future<void> goToNextDay({required Function setState}) async {
    if (currentDate.isSameDate(DateTime.now())) return;
    setState(() {
      currentDate = currentDate.add(const Duration(days: 1));
    });
    await loadDataForCurrentDate(setState: setState);
  }

  void onProjectSelected(bool selected, String project, Function setState) {
    setState(() {
      selectedProject = selected ? project : null;
    });
  }

  void onProjectTypeSelected(
      bool selected, String projectType, Function setState) {
    setState(() {
      if (selected) {
        selectedProjectTypes.add(projectType);
      } else {
        selectedProjectTypes.remove(projectType);
      }
    });
  }

  void onNameSelected(bool selected, String name, Function setState) {
    setState(() {
      if (selected) {
        selectedNames.add(name);
      } else {
        selectedNames.remove(name);
      }
    });
  }
}
