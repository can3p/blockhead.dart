class XHR {
  
  var _onSuccess;
  var _onError;
  XMLHttpRequest _request;
  
  XHR(url) {
    success((String result) {});
    error((String message) {});
    
    _request = new XMLHttpRequest();
    _request.on.readyStateChange.add(_stateChange);
    _request.open("GET", url, true, null, null);
    _request.setRequestHeader("Content-type", "text/plain");
    _request.send();
  }
  
  XHR success(void callback(String result)) {
    _onSuccess = callback;
    
    return this;
  }

  XHR error(void callback(String result)) {
    _onError = callback;
    
    return this;
  }

  void _stateChange(Event e) {
    if (_request.readyState == XMLHttpRequest.DONE) {
      if (_request.status == 200) {
        _onSuccess(_request.responseText);
      } else {
        _onError("Error " + _request.status);
      }
    }
  }

}
