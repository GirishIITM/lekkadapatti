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
  Map<String, Map<String, List<String>>> workDataPerDate = {};
  WorkManager({required this.currentDate});

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('workDataPerDate');
  }

  Future<void> saveDataForCurrentDate(Function setState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final formatedDate = formattedDate(currentDate);
      if (workDataPerDate[formatedDate] == null) {
        workDataPerDate[formatedDate] = {};
      }
      setState(() {
        workDataPerDate[formatedDate]?["selectedNames"] = selectedNames;
        workDataPerDate[formatedDate]?["selectedProject"] = List<String>.from(
            selectedProject != null ? [selectedProject!] : []);
        workDataPerDate[formatedDate]?["selectedProjectTypes"] =
            selectedProjectTypes;
      });
      await prefs.setString('workDataPerDate', json.encode(workDataPerDate));
    } on Exception catch (e) {
      errorLogger(e);
    }
  }

  Future<void> loadDataForCurrentDate({required Function setState}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedWorkDataPerDate = prefs.getString('workDataPerDate');

      final workedDataPerDate = savedWorkDataPerDate != null
          ? jsonDecode(savedWorkDataPerDate)
          : <String, Map<String, List<String>>>{};
      final workData = workedDataPerDate[formattedDate(currentDate)] ?? {};

      setState(() {
        selectedNames = List<String>.from(workData["selectedNames"] ?? []);
        selectedProject = workData["selectedProject"] ?? "";
        selectedProjectTypes =
            List<String>.from(workData["selectedProjectTypes"] ?? []);
      });
    } on Exception catch (e) {
      errorLogger(e);
    }
  }

  Future<void> goToPreviousDay({required Function setState}) async {
    try {
      setState(() {
        currentDate = currentDate.subtract(const Duration(days: 1));
      });
      await loadDataForCurrentDate(setState: setState);
    } on Exception catch (e) {
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
    } on Exception catch (e) {
      errorLogger(e);
    }
  }

  void onProjectSelected(bool selected, String project, Function setState) {
    try {
      setState(() {
        selectedProject = selected ? project : null;
      });
    } on Exception catch (e) {
      errorLogger(e);
    }
  }

  void onProjectTypeSelected(
      bool selected, String projectType, Function setState) {
    try {
      setState(() {
        if (selected) {
          selectedProjectTypes.add(projectType);
        } else {
          selectedProjectTypes.remove(projectType);
        }
      });
    } on Exception catch (e) {
      errorLogger(e);
    }
  }

  void onNameSelected(bool selected, String name, Function setState) {
    try {
      setState(() {
        if (selected) {
          selectedNames.add(name);
        } else {
          selectedNames.remove(name);
        }
      });
      saveDataForCurrentDate(setState);
    } on Exception catch (e) {
      errorLogger(e);
    }
  }
}
