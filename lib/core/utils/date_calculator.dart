class DateCalculator {
  /// Calculates exact age in years given a date of birth
  static int calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Checks if age is greater than or equal to minimum threshold (16)
  static bool isEligibleAge(DateTime dateOfBirth, {int minimumAge = 16}) {
    return calculateAge(dateOfBirth) >= minimumAge;
  }
}
