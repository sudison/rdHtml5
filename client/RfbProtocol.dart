
class RFBSecurityType {
  static final int INVALID = 0;
  static final int NONE = 1;
  static final int AUTHENTICATION = 2;
  //TODO: add other types
}

class RFBServerMessage {
  static final int FRAMEBUFFERUPDATE = 0;
  static final int SETCOLOURMAPENTRIES = 1;
  static final int BELL = 2;
  static final int SERVERCUTEXT = 3;
  static final int SCREENINIT = 4;
  int type;
  var message;
}

class RFBScreenInitMessage {
  int width;
  int height;
}

class _RfbProtocolVersion {
  static final int length = 12;
  String _protocol;
  int _major;
  int _minor;
  _RfbProtocolVersion() {
  }
  
  List<int> toData() {
    List<int> _data = new List<int>(length);
    _data[0] = _protocol.charCodeAt(0);
    _data[1] = _protocol.charCodeAt(1);
    _data[2] = _protocol.charCodeAt(2);
    _data[3] = ' '.charCodes()[0];
    _data[4] = 0 + 0x30;
    _data[5] = 0 + 0x30;
    _data[6] = _major + 0x30;
    _data[7] = '.'.charCodes()[0];
    _data[8] = 0 + 0x30;
    _data[9] = 0 + 0x30;
    _data[10] = _minor + 0x30;
    _data[11] = '\n'.charCodes()[0];
    return _data;
  }
  
  set protocol(String pro) => _protocol = pro;
  String get protocol() => _protocol;
  
  set major(int mj) => _major = mj;
  int get major() => _major;
  
  set minor(int mi) => _minor = mi;
  int get minor() => _minor;
}

class RFBInternalMessage {
  static final int SENDTOSERVER = 1;
  static final int READFROMSERVER = 2;
  static final int INPUTMESSAGE = 3;
  int _type;
  List<int> _data;
  
  RFBInternalMessage(int type, List<int> data) {
    _type = type;
    _data = data;
  }
  
  get type() => _type;
  get data() => _data;
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
  StateMachine _stateMachine;
  ByteStream _bytes;
  var _sendToServer;
  var _notifyClient;
  var _logger;
  
  RfbProtocol(callBack, client) {
    _logger = Logging.getLogger("RfbProtocol");
    
    _stateMachine = new StateMachine();
    _stateMachine.registerState(RFBStates.START, RFBStates.STARTEVENT, 
      RFBStates.HANDSHAKING_PROTOCOLVERSION, startRFB);
    _stateMachine.registerState(RFBStates.HANDSHAKING_PROTOCOLVERSION,
      RFBStates.DATARECEIVED, RFBStates.HANDSHAKING_PROTOCOLVERSION, readProtocolVersion);
    _stateMachine.registerState(RFBStates.HANDSHAKING_PROTOCOLVERSION, 
      RFBStates.MOVEON, RFBStates.HANDSHAKING_SECURITY, writeProtocolVersion);
    
    _stateMachine.registerState(RFBStates.HANDSHAKING_SECURITY, 
      RFBStates.DATARECEIVED, RFBStates.HANDSHAKING_SECURITY, readSecurityType);
    _stateMachine.registerState(RFBStates.HANDSHAKING_SECURITY,
      RFBStates.MOVEON, RFBStates.HANDSHAKING_SECURITY_RESULT, writeSecurityType);
    _stateMachine.registerState(RFBStates.HANDSHAKING_SECURITY,
      RFBStates.HANDSHAKING_FAILED, RFBStates.TERMINATED, terminated);
    
    _stateMachine.registerState(RFBStates.HANDSHAKING_SECURITY_RESULT,
      RFBStates.DATARECEIVED, RFBStates.HANDSHAKING_SECURITY_RESULT, readSecurityResult);
    _stateMachine.registerState(RFBStates.HANDSHAKING_SECURITY_RESULT,
      RFBStates.MOVEON, RFBStates.HANDSHAKING_FINISHED, WriteclientInit);
    _stateMachine.registerState(RFBStates.HANDSHAKING_SECURITY_RESULT,
      RFBStates.HANDSHAKING_FAILED, RFBStates.TERMINATED, terminated);
    
    _stateMachine.registerState(RFBStates.HANDSHAKING_FINISHED,
      RFBStates.DATARECEIVED, RFBStates.HANDSHAKING_FINISHED, ReadServerInit);
    _stateMachine.registerState(RFBStates.HANDSHAKING_FINISHED,
      RFBStates.MOVEON, RFBStates.READY, ready);
    
    _stateMachine.registerState(RFBStates.READY,
      RFBStates.DATARECEIVED, RFBStates.READY, processServerMessage);
    
    _stateMachine.setInitialState(RFBStates.START);
    _stateMachine.transit(RFBStates.STARTEVENT);
    
    _bytes = new ByteStream();
    _sendToServer = callBack;
    _notifyClient = client;

  }
  
  processMessage(RFBInternalMessage message) {
    if (message.type == RFBInternalMessage.READFROMSERVER) {
      _bytes.AddData(message.data);
      _stateMachine.transit(RFBStates.DATARECEIVED);
    }
  }
  
  startRFB() {
    _logger.Debug("starting event");
  }
  
  terminated() {
    _logger.Debug("terminated");
  }
  
  sendFrameUpdate() {
    _logger.Debug("send frameupdate to server");
    createFrameBufferUpdateRequest(0,0,0,
      frameBufferWidth, frameBufferHeight);
  }
  ready() {
    _logger.Debug("ready");
    window.setInterval(sendFrameUpdate, 10000);
    
  }
  
  readProtocolVersion() {
    if (_bytes.size < _RfbProtocolVersion.length) {
      return;
    }
    
    _versionFromServer = new _RfbProtocolVersion();
    StringBuffer pro = new StringBuffer();
    pro.addCharCode(_bytes.ReadByte());
    pro.addCharCode(_bytes.ReadByte());
    pro.addCharCode(_bytes.ReadByte());
    _versionFromServer.protocol = pro.toString();
    
    //skip space
    _bytes.Advance(1);
    _versionFromServer.major =  (_bytes.ReadByte() - 0x30) * 100 + 
        (_bytes.ReadByte() - 0x30) * 10 + (_bytes.ReadByte() - 0x30);
    
    //skip .
    _bytes.Advance(1);
    
    _versionFromServer.minor =  (_bytes.ReadByte() - 0x30) * 100 + 
        (_bytes.ReadByte() - 0x30) * 10 + (_bytes.ReadByte() - 0x30);
    
    _bytes.Tail();
    return RFBStates.MOVEON;
  }
  
  writeProtocolVersion() {
    _sendToServer(_versionFromServer.toData());
  }
  
  readSecurityType() {
    if (_versionFromServer.minor >= 7) {
      //version onwards 3.7
      int numTypes = _bytes.ReadByte();
      if (numTypes == 0) {
        return RFBStates.TERMINATED;
      }
      _securityTypes = new List<int>(numTypes);
      for (int i = 0; i < numTypes; i++) {
        _securityTypes[i] = _bytes.ReadByte();
      }
    } else {
      int type = _bytes.ReadU32();
      if (type == 0) {
        return RFBStates.TERMINATED;
      }
      _securityTypes = new List<int>(1);
      _securityTypes[0] = (type);
    }
    return RFBStates.MOVEON;
  }
  
  writeSecurityType() {
    int securityType = RFBSecurityType.INVALID;
    if (_versionFromServer.minor < 7) {
      return null;
    }
    //TODO: add VNC authentication support
    for (int i = 0; i < _securityTypes.length; i++) {
      if (_securityTypes[i] == RFBSecurityType.NONE) {
        securityType = RFBSecurityType.NONE;
      }
    }
    if (securityType != RFBSecurityType.NONE) {
      print("can't use None security type");
    }
    List<int> u8list = new List(1);
    u8list[0] = securityType;
    _sendToServer(u8list);
  }
  
  readSecurityResult() {
    int result = _bytes.ReadU32();
    if (result == 0) {
      return RFBStates.MOVEON;
    } else {
      return RFBStates.HANDSHAKING_FAILED;
    }
  }
  
  WriteclientInit() {
    List<int> cl = new List<int>(1);
    //no share with other clients
    cl[0] = 1;
    _sendToServer(cl);
  }
  
  ReadServerInit() {
    if (_bytes.size < 24) {
      return;
    }
    
    int nameLength = _bytes.PeekReadU32(20);
    if (_bytes.size < (24 + nameLength)) {
      return;
    }
    
    //we got all the data
    frameBufferWidth = _bytes.ReadU16();
    frameBufferHeight = _bytes.ReadU16();
    format = new pixelFormat();
    format.bpp = _bytes.ReadByte();
    format.depth = _bytes.ReadByte();
    format.bef = _bytes.ReadByte();
    format.tcf = _bytes.ReadByte();
    format.redMax = _bytes.ReadU16();
    format.greenMax = _bytes.ReadU16();
    format.blueMax = _bytes.ReadU16();
    format.redShift = _bytes.ReadByte();
    format.greenShift = _bytes.ReadByte();
    format.blueShift = _bytes.ReadByte();
    
    //skip pading
    _bytes.Advance(3);
    
    nameLength = _bytes.ReadU32();
    if (nameLength != 0) {
      StringBuffer name = new StringBuffer();
      for(int i = 0 ; i < nameLength; i++) {
        name.addCharCode(_bytes.ReadByte());
      }
      serverName = name.toString();
    }
   
    print("bef:" + format.bef +
      "redshift:" + format.redShift +
      "redmax:" + format.redMax +
      "greenshift:" + format.greenShift +
      "greenmax:" + format.greenMax + 
      "blueshift: " + format.blueShift +
      "bluemax: " + format.blueMax +
      "truecolor:" + format.tcf +
      "bpp: " + format.bpp);
    
    RFBServerMessage msg = new RFBServerMessage();
    msg.type = RFBServerMessage.SCREENINIT;
   
    RFBScreenInitMessage screenInit = new RFBScreenInitMessage();
    screenInit.width = frameBufferWidth;
    screenInit.height = frameBufferHeight;
    msg.message = screenInit;
    _notifyClient(msg);
    return RFBStates.MOVEON;
  }
  
  createFrameBufferUpdateRequest(int x, int y,int incremental, int width, int height) {
    List<int> message = new List<int>(10);
    message[0] = 3;
    message[1] = incremental;;
    ConvertU16(x, message, 2);
    ConvertU16(y, message, 4);
    ConvertU16(width, message, 6);
    ConvertU16(height, message, 8);
    _sendToServer(message);
  }
  
  _processFrameBufferUpdate() {
    //skip padding
    _bytes.Advance(1);
    
    int rectNum = _bytes.ReadU16();
    RFBFrameBufferUpdate update = new RFBFrameBufferUpdate(rectNum);
   
    for (int i = 0; i < rectNum; i++) {
      if (_bytes.avail < 12) {
        _bytes.Seek(0);
        return;
      }
      
      RFBFrameRectUpdate rect = new RFBFrameRectUpdate();
      rect.x = _bytes.ReadU16();
      rect.y = _bytes.ReadU16();
      rect.width = _bytes.ReadU16();
      rect.height = _bytes.ReadU16();
      rect.encondingType = _bytes.ReadU32();
      int pixelBits = rect.width * rect.height * (format.bpp~/8);

      if (_bytes.avail < pixelBits) {
        _bytes.Seek(0);
        return;
      }
      _logger.Debug("x: " + rect.x + ";y:" + rect.y + ";w:" + rect.width +
        ";h: " + rect.height + ";bpp:" + format.bpp);
      //Note: no matter what bpp used by server, the client always uses 32bit/pixel
      int pixels = rect.width * rect.height * 4;
      rect.pixelData = new List<int>(pixels);
      for(int pixel = 0 ; pixel < pixels; ) {
        int pixelData = 0;
        if (format.bef != 0) {
          if (format.bpp == 32) {
            pixelData = _bytes.ReadU32();
          } else if (format.bpp == 16) {
            pixelData = _bytes.ReadU16();
          }
        } else {
          if (format.bpp == 32) {
            pixelData = _bytes.Read32();
          } else if (format.bpp == 16) {
            pixelData = _bytes.Read16();
          }
        }
        
        var red = (pixelData >> format.redShift) & format.redMax;
        var green = (pixelData >> format.greenShift) & format.greenMax;
        var blue = (pixelData >> format.blueShift) & format.blueMax;
        if (format.bpp == 16) {
          red = (red << 3) | (red >> 2);
          green = (green << 2) | (green >> 4);
          blue = (blue << 3) | (blue >> 2);
        }
        
        rect.pixelData[pixel++] = red;
        rect.pixelData[pixel++] = green;
        rect.pixelData[pixel++] = blue;
        rect.pixelData[pixel++] = 255; //alpha channel
      }
      update.Rects[i] = rect;
    }
    _logger.Debug("avail: " + _bytes.avail);
    return update;
  }
  
  processServerMessage() {

    int messageType = _bytes.ReadByte();
    _logger.Debug("received message from server, msg type: " + messageType);
    if (messageType == RFBServerMessage.FRAMEBUFFERUPDATE) {
      RFBFrameBufferUpdate frameUpdate = _processFrameBufferUpdate();
      if (frameUpdate != null) {
        RFBServerMessage msg = new RFBServerMessage();
        msg.type = RFBServerMessage.FRAMEBUFFERUPDATE;
        msg.message = frameUpdate;
        _notifyClient(msg);
      }
    } else if (messageType == RFBServerMessage.SETCOLOURMAPENTRIES) {
      _logger.Debug("setcolourmap");
    }
  }
  
}
