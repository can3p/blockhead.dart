class JSBridge {
  
  Map _callbacks;
  
  JSBridge() {
    window.on.message.add(processMessage);
    
    _callbacks = new Map();
  }
  
  void rpcCall(String name, [List args]) {
    if (args == null) {
      args = [];
    }
    var message = {
        'name': name,
        'args': args,
        'sender': 'dart'
    };
    
    String jsonMessage = JSON.stringify(message);
    window.postMessage(jsonMessage, '*');
  }
  
  void processMessage(ev) {
    Map<String, String> message = JSON.parse(ev.data);
    String name = message['name'];

    if (message['sender'] != 'dart') {
      if(_callbacks.containsKey(name)) {
        _callbacks[name].forEach((void fun([List args])) => fun(message['args']));
      }
    }
  }
  
  void addListener(String name, var callback) {
    if (!_callbacks.containsKey(name)) {
      _callbacks[name] = new List();
    }
    
    _callbacks[name].add(callback);
  }
}
