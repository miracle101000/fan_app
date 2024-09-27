import 'preferences.dart';

class UserData {
  static String _currentUrl = '';
  static String get currentUrl => _currentUrl;
  static List<String> _cookies = [];
  static List<String> get cookies => _cookies;
  static List<String> _sessionStorage = [];
  static List<String> get sessionStorage => _sessionStorage;
  static List<String> _localStorage = [];
  static List<String> get localStorage => _localStorage;

  //setters for above fields.
  //Sets the value and saves to hive

  static Future<void> initialize() async {
    _currentUrl = await Preferences.getData('currentUrl') ?? "";
    _cookies = await Preferences.getData('cookies') ?? [];
    _sessionStorage = await Preferences.getData('sessions') ?? [];
    _localStorage = await Preferences.getData('local') ?? [];
  }

  static set cookies(List<String> value) {
    _cookies = value;
    Preferences.saveData('cookies', _cookies);
  }

  static set sessionStorage(List<String> value) {
    _sessionStorage = value;
    Preferences.saveData('sessions', _sessionStorage);
  }

  static set localStorage(List<String> value) {
    _localStorage = value;
    Preferences.saveData('local', _localStorage);
  }

  static set currentUrl(String value) {
    _currentUrl = value;
    Preferences.saveData('currentUrl', value);
  }

 
}
