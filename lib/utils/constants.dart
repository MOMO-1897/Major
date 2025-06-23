class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000'; // For Android Emulator
  //static const String baseUrl = 'http://localhost:3000'; // For iOS Simulator
  // static const String baseUrl = 'http://YOUR_IP_ADDRESS:3000'; // For physical device

  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/users';
  static const String uploadsEndpoint = '/uploads';
}