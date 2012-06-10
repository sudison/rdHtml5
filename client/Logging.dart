class Logging {
  static bool _enable = true;
  String _compName;
  disableLogging() {
    _enable = false;
  }
  Logging(String compName) {
    _compName = compName;
  }
  static getLogger(String compName) {
    return new Logging(compName);
  }
  Debug(String message) {
    if (_enable != true) {
      return;
    }
    print(_compName + ": " + message);
  }
}
