class Player {
  DivElement container;
  String _name;
  List<String> words;
  
  DivElement _list;
  DivElement _overall;
  
  String get name() => _name;

  Player(cont, this._name) {
    container = document.query(cont);
    words = new List();
    buildDOM();
  }
  
  void buildDOM() {
    container.classes.add('player-scorelist');
    container.classes.add('player-noscore');
    container.nodes.add( new Element.html('<div class="player-name">${name}</div>') );
    
    _list = new Element.html('<ol class="player-list"></ol>');
    _overall = new Element.html('<div class="player-overall"></div>');

    container.nodes.add(_list);
    container.nodes.add(_overall);
    container.nodes.add(new Element.html('<div class="player-noscore-message">Слов еще не добавил</div>'));
  }
  
  void addWord(String word){
    words.add(word);
    
    container.classes.remove('player-noscore');
    _list.nodes.add( new Element.html('<li>${word} - ${word.length}</li>') );
    _overall.innerHTML = 'Общий балл: ' + calcScore();
  }
  
  void reset() {
    words.clear();
    _list.nodes.clear();
    container.classes.add('player-noscore');
  }
  
  bool hasWord(String word) {
    return words.indexOf(word) >= 0;
  }
  
  int calcScore() {
    int score = 0;
    words.forEach((word) => score += word.length);
    
    return score;
  }
  
  void onStartTurn() {
    container.classes.add('player-myturn');
  }
  
  void onEndTurn() {
    container.classes.remove('player-myturn');
  }
}
