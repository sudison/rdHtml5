
class _RfbProtocolVersion {
  String protocol;
  int major;
  int minor;
  _RfbProtocolVersion(Uint8List data) {
    StringBuffer pro;
    pro.addCharCode(data[0]);
    pro.addCharCode(data[1]);
    pro.addCharCode(data[2]);
    protocol = pro.toString();
    if (protocol != "RFB") {
      return;
    }
    
    major = 100 * data[4] + 10 * data[5] + data[6];
    minor = 100 * data[8] + 10 * data[9] + data[10];
  }
}

class RfbProtocol {
  _RfbProtocolVersion _versionFromServer;
  RfbProtocal() {
  }
  
  readProtocolVersion(Uint8List data, currentData) {
    if (currentData == null) {
      //read new data
      if (data.length == 12) {
        _versionFromServer = new _RfbProtocolVersion(data);
        return [true, currentData];
      }
      currentData = new Uint8List(0);
    }
    
    var newData = currentData.addAll(data);
    if (newData.length == 12) {
      _versionFromServer = new _RfbProtocolVersion(data);
      return [true, currentData];
    }
    return [false, newData];
  }
}
