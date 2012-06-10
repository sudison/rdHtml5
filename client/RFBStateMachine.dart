class StateMachine {
  var _states;
  var _currentState;
  StateMachine() {
    _states = new Map();
  }
  
  registerState(state, event, nextState, func) {
    if (_states.containsKey(state) == false) {
      var events = new Map();
      events[event] = [nextState, func];
      _states[state] = events;
    } else {
      var events = _states[state];
      events[event] = [nextState, func];
    }
  }
  
  setInitialState(state) {
    _currentState = state;
  }
  
  transit(event) {
    if (_states.containsKey(_currentState) == true) {
      var events = _states[_currentState];
      if (events.containsKey(event) == true) {
      
      var nextState = events[event][0];
      var func = events[event][1];
      var nextEvent = func();
      _currentState = nextState;
      if (nextEvent != null) {
        transit(nextEvent);
      }
    }
  }
  }
}

class RFBStates {
  static final int START = 0;
  static final int TERMINATED = 1;
  static final int HANDSHAKING_PROTOCOLVERSION = 2;
  static final int HANDSHAKING_SECURITY = 3;
  static final int HANDSHAKING_SECURITY_RESULT = 4;
  static final int HANDSHAKING_FINISHED = 5;
  static final int READY = 6;
  
  //events
  static final int STARTEVENT = 0;
  static final int DATARECEIVED = 1;
  static final int MOVEON = 2;
  static final int HANDSHAKING_FAILED = 3;
  
}