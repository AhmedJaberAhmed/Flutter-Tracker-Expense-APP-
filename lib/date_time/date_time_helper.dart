String convertDateToString(DateTime dateTime) {
  String year = dateTime.year.toString();

  String month = dateTime.month.toString().padLeft(2, '0');
  String day = dateTime.day.toString().padLeft(2, '0');

  String yyyymmdd = year + month + day;  // e.g. "20250303"
  return yyyymmdd;
}
