class ApiConstants {
  //static const String baseUrl = 'http://10.0.2.2:3000'; // For Android Emulator
  //static const String baseUrl = 'http://localhost:3000'; // For iOS Simulator
  static const String baseUrl = 'http://192.168.1.73:3000'; // For physical device
  //static const String baseUrl = 'http://192.168.20.160:3000';

  static const String socketUrl = 'http://192.168.1.73:4000';

  static const String AIUrl= 'http://192.168.1.73:8000';

  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/users';
  static const String uploadsEndpoint = '/uploads';
  static const String sendLocation = '/users/location';
  static const String getSpecialistsLocation= '/specialists/nearby';

  static const String sendReport= '/reports';

  static const String Conversation= '/conversation/';
}
