class Dict {
  final int version = 1;
  var _onReady;
  bool ready = false;
  List<String> words;
  List<String> userWords;
  
  void set onReady(void callback()) {
    _onReady = callback;
  }
  
  Dict() {
    onReady = () {};
    words = new List();
    userWords = new List();
  }
  
  void init() {
    _load();
  }
  
  void _load() {
    int storedVersion;
    
    try {
      storedVersion = Math.parseInt(window.localStorage.getItem('dictVersion'));
    } catch (BadNumberFormatException e) {
      storedVersion = 0;
    }
 
    String dictStr = window.localStorage.getItem('dict');
    
    if (version < storedVersion || dictStr == null) {
      new XHR('dict').success(_storeDict);
    } else {
      words = JSON.parse(window.localStorage.getItem('dict'));
      window.setTimeout(_fireReady, 0);
    }
    
    String userDictStr = window.localStorage.getItem('userDict');
    if (userDictStr != null) {
      userWords = JSON.parse(userDictStr);
    }
  }
  
  _fireReady() {
    ready = true;
    _onReady();
  }
  
  void _storeDict(String str) {
    List parsedWords = str.split('\n');
    words.clear();
    parsedWords.forEach((word) => words.add(word));

    window.localStorage.setItem('dictVersion', version.toString());
    window.localStorage.setItem('dict', JSON.stringify(words));
    _fireReady();
  }
  
  bool isValidWord(String word) {
    return _isCorrectString(word) && ( userWords.indexOf(word) >= 0 || words.indexOf(word) >= 0);
  }
  
  void addUserWord(String word) {
    if (_isCorrectString(word)) {
      userWords.add(word);
      window.setTimeout(() { window.localStorage.setItem('userDict', JSON.stringify(userWords)); }, 0);
    }
  }
  
  bool _isCorrectString(String word) {
    return !(new RegExp('[^а-я]', ignoreCase: true).hasMatch(word));
  }
  
  String getRandomWord(int size) {
    var filter = (word) => word.length == size;
    List<String> filtered = words.filter(filter);
    List<String> userFiltered =  userWords.filter(filter);

    filtered.addAll(userFiltered);
    return filtered[ (Math.random() * (filtered.length - 1)).floor().toInt() ];
  }
}