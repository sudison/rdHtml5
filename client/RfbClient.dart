
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
  var currentReceivedData;
  RfbProtocol rfb;
  
  _initialStateCallBack(data) {
    
  }

  _getVersionStateCallBack(data){
    return rfb.readProtocolVersion(data, currentReceivedData);
  }
  
  RfbClient() {
    states =  {"initial":[_initialStateCallBack, "getVersion"], 
               "getVersion":[_getVersionStateCallBack, "Ready"]};
    currentState = "initial";
    rfb = new RfbProtocol();
    currentReceivedData = null;
  }
  
  _initialize(ServerInfo) {
    //connect to server  
    WebSocket _ws;
    bool _isConnected = false;

    _ws = new WebSocket("ws://" + ServerInfo[0] + ':' + ServerInfo[1] + "/ws");
    _ws.on.open.add((a) {
      states[currentState][0](null);
      currentState = states[currentState][1];
     });
      
     _ws.on.close.add((c) {
        currentState = "closed";
     });
      
     _ws.on.message.add((m){
       _processDataFromServer(m.data);
     });
  }
  
  _processDataFromServer(data) {
    var callBack = states[currentState];
    if (callBack == null) {
      return null;
    }
    
    var rets = callBack[0](data);
    if (rets[0] == true) {
      currentReceivedData = null;
      currentState = states[currentState][1];
      return;
    } else {
      currentReceivedData = rets[1];
    }
    
  }
  
  _processDataFromClient(inputInfo) {
    
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
