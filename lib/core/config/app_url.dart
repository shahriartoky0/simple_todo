class AppUrl {
  AppUrl._();

  static const String baseUrl = 'https://qemu-api.billal.space';
  static const String getAirlines = '$baseUrl/airlines';

  static String airlineAssessment({required String airlineName}) {
    return '$baseUrl/assessments/airline/$airlineName';
  }
}
