
class _RfbProtocolVersion {
  String protocol;
  int major;
  int minor;
  List<int> rawData;
  _RfbProtocolVersion(List<int> data) {
    StringBuffer pro = new StringBuffer();
    pro.addCharCode(data[0]);
    pro.addCharCode(data[1]);
    pro.addCharCode(data[2]);
    protocol = pro.toString();
    
    major =  data[4] * 100 + data[5] * 10 + data[6];
    minor =  data[8] * 100 + data[9] * 10 + data[10];
    rawData = data;
  }
}

class pixelFormat {
  int bpp;
  int depth;
  int bef;
  int tcf;
  int redMax;
  int greenMax;
  int blueMax;
  int redShift;
  int greenShift;
  int blueShift;
}

class RfbProtocol {
  _RfbProtocolVersion _versionFromServer;
  List<int> _securityTypes;
  int frameBufferWidth;
  int frameBufferHeight;
  String serverName;
  pixelFormat format;
  
  RfbProtocal() {
  }
  
  readProtocolVersion(List<int> data, String currentData) {
    _versionFromServer = new _RfbProtocolVersion(data);
    return [true, null];
  }
  
  writeProtocolVersion() {
    //reply the same version got from server
    return _versionFromServer.rawData;
  }
  
  readSecurityType(List<int> data, String currentData) {
    if (_versionFromServer.minor >= 7) {
      //version onwards 3.7
      int numTypes = data[0];
      if (numTypes == 0) {
        //connection failed
        return [false, null];
      }
      _securityTypes = new List<int>(numTypes);
      for (int i = 0; i < numTypes; i++) {
        _securityTypes[i] = (data[i + 1]);
      }
    } else {
      //convert big endian to little endian
      int type = U32BigToInt(data, 0);
      _securityTypes = new List<int>(1);
      _securityTypes[0] = (type);
    }
    return [true, data];
  }
  
  writeSecurityType() {
    int securityType = 0;
    if (_versionFromServer.minor < 7) {
      return null;
    }
    for (int i = 0; i < _securityTypes.length; i++) {
      if (_securityTypes[i] == 1) {
        securityType = 1;
      }
    }
    if (securityType != 1) {
      print("can't use None security type");
    }
    List<int> u8list = new List(1);
    u8list[0] = securityType;
    return u8list;
  }
  
  readSecurityResult(data, _) {
    return [true, U32BigToInt(data, 0)];
  }
  
  clientInit() {
    List<int> cl = new List<int>(1);
    //no share with other clients
    cl[0] = 1;
    return cl;
  }
  
  serverInit(List<int> data, _) {
    frameBufferWidth = U16BigToInt(data, 0);
    frameBufferHeight = U16BigToInt(data, 2);
    format = new pixelFormat();
    format.bpp = data[4];
    format.depth = data[5];
    format.bef = data[6];
    format.tcf = data[7];
    format.redMax = U16BigToInt(data, 8);
    format.greenMax = U16BigToInt(data, 10);
    format.blueMax = U16BigToInt(data, 12);
    format.redShift = data[14];
    format.greenShift = data[15];
    format.blueShift = data[16];
    
    int nameLength = U32BigToInt(data, 17);
    if (nameLength != 0) {
      StringBuffer name = new StringBuffer();
      for(int i = 0 ; i < nameLength; i++) {
        name.addCharCode(data[18+i]);
      }
      serverName = name.toString();
    }
   
    return [true, null];
  }
}
