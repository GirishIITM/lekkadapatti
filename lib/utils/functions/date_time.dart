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

String formatDate(DateTime currentDate) {
  return "${currentDate.day}/${currentDate.month}/${currentDate.year}";
}

const gsDateBase = 2209161600 / 86400;
const gsDateFactor = 86400000;

double dateToGsheets(DateTime dateTime, {bool localTime = true}) {
  final offset = dateTime.millisecondsSinceEpoch / gsDateFactor;
  final shift = localTime ? dateTime.timeZoneOffset.inHours / 24 : 0;
  return gsDateBase + offset + shift;
}

DateTime? dateFromGsheets(String value, {bool localTime = true}) {
  final date = double.tryParse(value);
  if (date == null) return null;
  final millis = (date - gsDateBase) * gsDateFactor;
  return DateTime.fromMillisecondsSinceEpoch(millis.toInt(), isUtc: localTime);
}
