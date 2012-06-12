
class RFBClientMessage {
  String _t;
  var _d;
  String get type() => _t;
  set type(t) => _t = t; 
  get data() => _d;
  set data(d) => _d = d;
}

class RfbClient {
  RfbProtocol rfb;
  WebSocket _ws;
  rdViewer _viewer;
  UsKeyBoardMap _keyMap;
  
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
  
  notify(RFBServerMessage msg) {
    if (msg.type == RFBServerMessage.SCREENINIT) {
      RFBScreenInitMessage screen = msg.message;
      _viewer.initializeScreen(screen.width, screen.height);
    } else if (msg.type == RFBServerMessage.FRAMEBUFFERUPDATE) {
      RFBFrameBufferUpdate update = msg.message;
      for(int i = 0; i < update.Rects.length; i++) {
        RFBFrameRectUpdate rect = update.Rects[i];
        _viewer.drawFrame(rect.pixelData, rect.x, rect.y, rect.width, rect.height );
      }
    }
  }
  
  RfbClient() {
    rfb = new RfbProtocol(_processDataFromClient, notify);
    _keyMap = new UsKeyBoardMap();
  }
  
  _initialize(ServerInfo) {
    //connect to server 

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
  
  SendKeyEventToServer(BrowserKeyEvent event) {
    RFBKeyEventMessage msg = new  RFBKeyEventMessage(event.keyDown, 
      _keyMap.getKeySyms(event.keyCode));
    _sendMessageToServer(msg.toData());
  }
}
