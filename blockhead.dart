#import('dart:html');
#import('dart:json');
#source('GameField.dart');
#source('Player.dart');
#source('XHR.dart');
#source('Dict.dart');
#source('Countdown.dart');
#resource('style.css');

class blockhead {
  final int size = 5;
  final int roundTime = 60;
  Dict dict;
  GameField table;
  Countdown countdown;
  List<Player> players; 
  int currentPlayerIdx = -1;
  String startWord;

  blockhead() {
    players = new List(); 
    players.add( new Player('#player1', 'Player 1') );
    players.add( new Player('#player2', 'Player 2') );
    table = new GameField(size);
    
    table.onEnterWord = analyzeTurn;
    table.onFieldFull = finishGame;
    
    countdown = new Countdown(document.body.query('#countdown'), roundTime);
    countdown.onEndCount = _nextPlayer;
   
    dict = new Dict();
    dict.onReady = startGame;
    dict.init();
  }
    
  void _nextPlayer([num idx = -1]) {
    if (currentPlayerIdx >= 0) {
      players[currentPlayerIdx].onEndTurn();
    }
    
    countdown.restart();

    currentPlayerIdx = ( idx >= 0 ) ? idx : (currentPlayerIdx + 1) % players.length;
    players[currentPlayerIdx].onStartTurn();   
  }
  
  void analyzeTurn(String word) {
    bool approve = dict.isValidWord(word);
    
    if (approve) {
      if(word == startWord) { approve = false; }
      
      players.forEach((Player player) {
        if (player.hasWord(word)) {
          approve = false;
        }
      });
      
      if (!approve) {
        window.alert('Это слово было уже использовано');
      }
    } else if (window.confirm('Неизвестное слово. Добавить его на поле?')) {
      dict.addUserWord(word);
      approve = true;
    }

    if (approve) {
      table.applyWord(); 
      players[currentPlayerIdx].addWord(word);
      _nextPlayer();
    }
    table.makeTurn();
  }
    
  void startGame() {
    startWord = dict.getRandomWord(size);
    
    _nextPlayer();
    table.reset(startWord);
    table.makeTurn();
  }
  
  void finishGame() {
    int maxScore = 0;
    Player winner;
    
    countdown.reset();
    
    players.forEach((p) {
      int score = p.calcScore();
      if (score >= maxScore) {
        winner = p;
        maxScore = score;
      }
    });
    
    window.alert('Победитель - ${winner.name} с результатом ${maxScore}');
    if (window.confirm('Играем еще раз?')) {
      startWord = dict.getRandomWord(size);
      
      table.reset(startWord);
      _nextPlayer(0);
      table.makeTurn();
    }
  }
  
}

void main() {
  new blockhead();
}
