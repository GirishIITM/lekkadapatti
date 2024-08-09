int getWeekNumber(DateTime date) {
  DateTime startOfYear = DateTime(date.year, 1, 1);
  int days = date.difference(startOfYear).inDays;
  int weekNumber = ((days + startOfYear.weekday) / 7).ceil();
  return weekNumber;
}

String getYearWeekFromDate(DateTime date) {
  String year = date.year.toString();
  int weekNumber = getWeekNumber(date);
  return '$year-W${weekNumber.toString().padLeft(2, '0')}';
}

String formattedDate(DateTime currentDate) {
  return "${currentDate.day}/${currentDate.month}/${currentDate.year}";
}
