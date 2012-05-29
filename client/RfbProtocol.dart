
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

class RFBFrameRectUpdate {
  int x;
  int y;
  int width;
  int height;
  int encondingType;
  List<int> pixelData;
}

class RFBFrameBufferUpdate {
  List<RFBFrameRectUpdate> Rects;
  RFBFrameBufferUpdate(int num) {
    Rects = new List<RFBFrameRectUpdate>(num);
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
   
    if (format.bpp != 32) {
      print("can't handle this format: format.bpp: " + format.bpp);
    }
    return [true, null];
  }
  
  createFrameBufferUpdateRequest(int x, int y,int incremental, int width, int height) {
    List<int> message = new List<int>(10);
    message[0] = 3;
    message[1] = incremental;;
    ConvertU16(x, message, 2);
    ConvertU16(y, message, 4);
    ConvertU16(width, message, 6);
    ConvertU16(height, message, 8);
    return message;
  }
  
  _processFrameBufferUpdate(List<int> data, List<int> currentData) {
    List<int> stream = null;
    if (currentData != null) {
      stream = currentData;
    } else {
      stream = data;
    }
    int rectNum = U16BigToInt(stream, 2);
    RFBFrameBufferUpdate update = new RFBFrameBufferUpdate(rectNum);
   
    for (int i = 0, index = 4; i < rectNum; i++) {
      RFBFrameRectUpdate rect = new RFBFrameRectUpdate();
      rect.x = U16BigToInt(stream, index);
      index = index +2;
      rect.y = U16BigToInt(stream, index);
      index = index +2;
      rect.width = U16BigToInt(stream, index);
      index = index + 2;
      rect.height = U16BigToInt(stream, index);
      index = index + 2;
      rect.encondingType = U32BigToInt(stream, index);
      index = index + 4;
      print("rect num: " + rectNum +"," + rect.width+ "," + rect.height + ", length: " + data.length);
      int bytes = rect.width * rect.height * (format.bpp~/8);
      if (currentData == null) {
        currentData = new List<int>();
      }
      
      if ((data.length + currentData.length) < (16 + bytes)) {
        print("less: " + data.length +"," +currentData.length);
        currentData.addAll(data);
        return [false, currentData];
      }
     
      currentData.addAll(data);
      print("got all the data: " + currentData.length);
      rect.pixelData = new List<int>(bytes);
      for(int pixel = 0 ; pixel < bytes; ) {
        int pixelData = 0;
        if (format.bef != 0) {
          if (format.bpp == 32) {
            pixelData = U32BigToInt(stream, index);
            index = index + 4;
          }
        } else {
          if (format.bpp == 32) {
            pixelData = U32ToInt(stream, index);
            index = index + 4;
          }
        }
        
        rect.pixelData[pixel++] = (pixelData >> format.redShift) & format.redShift;
        rect.pixelData[pixel++] = (pixelData >> format.greenShift) & format.greenMax;
        rect.pixelData[pixel++] = (pixelData >> format.blueShift) & format.blueMax;
        rect.pixelData[pixel++] = 255; //alpha channel
      }
      update.Rects[i] = rect;
    }
    return [true, update];
  }
  
  processServerMessage(List<int> data, List<int> currentData) {
    List<int> stream;
    if (currentData != null) {
      stream = currentData;
    }else {
      stream = data;
    }
    int messageType = stream[0];
    if (messageType == 0) {
      return _processFrameBufferUpdate(data, currentData);
    }
  }
  
}
