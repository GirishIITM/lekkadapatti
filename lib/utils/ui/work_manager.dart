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

  String? selectedProject;
  String? selectedProjectType;
  List<String> selectedNames = [];

  DateTime currentDate;
  Map<String, String> workDetails = {};
  Map<String, Map<String, String>> workDataPerDate = {};
  WorkManager({required this.currentDate});

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
        workDataPerDate = Map<String, Map<String, String>>.from(
          parsedData.map(
            (key, value) => MapEntry(key, Map<String, String>.from(value)),
          ),
        );
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
}
