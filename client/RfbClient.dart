
class RFBClientMessage {
  String _t;
  var _d;
  String get type() => _t;
  set type(t) => _t = t; 
  get data() => _d;
  set data(d) => _d = d;
}

class RfbClient {
  String currentState; //"initial","connecting","connected","getVersion"
  var states;
  List<int> currentReceivedData;
  RfbProtocol rfb;
  WebSocket _ws;
  rdViewer _viewer;
  
  _initialStateCallBack(data) {
    
  }
  
  setViewer(rdViewer viewer) {
    _viewer = viewer;
  }
  
  _sendMessageToServer(data) {
    RFBClientMessage message = new RFBClientMessage();
    message.data = data;
    message.type = "dataFromClient";
    ProcessMessage(message);
  }

  _getVersionStateCallBack(data){
    var ret = rfb.readProtocolVersion(data, currentReceivedData);
    if (ret[0] == true) {
      var version = rfb.writeProtocolVersion();
      _sendMessageToServer(version);
    } 
    return ret;
  }
  
  _securityHandShakingCallBack(List<int> data) {
    var ret = rfb.readSecurityType(data, currentReceivedData);
    if (ret[0] == true) {
      var type = rfb.writeSecurityType();
      if (type != null) {
        _sendMessageToServer(type);
      }
    }
    return ret;
  }
  
  _securityResult(data) {
    var ret = rfb.readSecurityResult(data, currentReceivedData);
    if (ret[0] == true) {
      //send clientInit message
      var clientIn = rfb.clientInit();
      _sendMessageToServer(clientIn);
    }
    return ret;
  }
  
  _serverInit(data) {
    var result = rfb.serverInit(data, null);
    //send frameupdate
    _viewer.initializeScreen(rfb.frameBufferWidth, rfb.frameBufferHeight);
    _sendMessageToServer(rfb.createFrameBufferUpdateRequest(0,0,0,
      rfb.frameBufferWidth, rfb.frameBufferHeight));
    return result;
  }
  
  _readyStateCallBack(data) {
    var result = rfb.processServerMessage(data, currentReceivedData);
    if (result[0] == true) {
      RFBFrameBufferUpdate update = result[1];
      for(int i = 0; i < update.Rects.length; i++) {
        RFBFrameRectUpdate rect = update.Rects[i];
        _viewer.drawFrame(rect.pixelData, rect.x, rect.y, rect.width, rect.height );
      }
    }
    return result;
  }
  
  RfbClient() {
    rfb = new RfbProtocol(_processDataFromClient);
    currentReceivedData = null;
  }
  
  _initialize(ServerInfo) {
    //connect to server  
    
    bool _isConnected = false;

    _ws = new WebSocket("ws://" + ServerInfo[0] + ':' + ServerInfo[1] + "/ws");
    _ws.on.open.add((a) {
     });
      
     _ws.on.close.add((c) {
        
     });
      
     _ws.on.message.add((m){
       _processDataFromServer(m.data);
     });
  }
  
  _processDataFromServer(String data) {
    List<int> decoded = Base64.decode(data);
    RFBInternalMessage message = new RFBInternalMessage(
      RFBInternalMessage.READFROMSERVER, 
      decoded);
    rfb.processMessage(message);
  }
  
  _processDataFromClient(List<int> data) {
    if (data == null) {
      return;
    }
    String encoded = Base64.encode(data);
    _ws.send(encoded);
  }
  
  //initialize/dataFromServer/dataFromClient
  ProcessMessage(message) {
    if (message.type == "initialize") {
      _initialize(message.data);
    } else if (message.type == "dataFromServer") {
      _processDataFromServer(message.data);
    } else if (message.type == "dataFromClient") {
      _processDataFromClient(message.data);
    } else {
      
    }
  }
}
