class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = 'https://api.example.com';

  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';

  // Products
  static const String products = '$baseUrl/products';
}
