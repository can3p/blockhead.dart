class Countdown {
  
  int _timer;
  
  var _onEndCount;
  int _roundTime;
  int _count;
  Element _node;
  
  Countdown(this._node, this._roundTime) {
    onEndCount = () {};
  }
  
  void set onEndCount (void callback()) {
    _onEndCount = callback;
  }
  
  void _tick() {
    _count--;
    _node.innerHTML = _count.toString();
    
    if(_count == 0) {
      _onEndCount();
    } else {
      _timer = window.setTimeout(_tick, 1000);
    }
  }
  
  void start() {
    _count = _roundTime + 1;
    _tick();
  }
  
  void restart() {
    reset();
    start();
  }
  
  void reset() {
    if(_timer != null) {
      window.clearTimeout(_timer);
    }
    
    _node.innerHTML = _roundTime.toString();
  }

}
