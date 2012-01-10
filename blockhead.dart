#import('dart:html');
#source('GameField.dart');
#source('Player.dart');
#resource('style.css');

class blockhead {
  GameField table;
  List<Player> players; 
  int currentPlayerIdx = 0;

  blockhead() { 
    table = new GameField(); 
    players = new List();
    players.add( new Player('#player1', 'Player 1') );
    players.add( new Player('#player2', 'Player 2') );
    
    table.onEnterWord = (String word) {
      bool approve = window.confirm('Подходит слово?');
      if (approve) {
        table.applyWord(); 
        players[currentPlayerIdx].addWord(word);
        players[currentPlayerIdx].onEndTurn();
        currentPlayerIdx = (currentPlayerIdx + 1) % players.length;
        players[currentPlayerIdx].onStartTurn();
      }
      table.makeTurn();
    };
    
    table.onFieldFull = () {
      int maxScore = 0;
      Player winner;
      
      players.forEach((p) {
        int score = p.calcScore();
        if (score >= maxScore) {
          winner = p;
          maxScore = score;
        }
      });
      
      window.alert('Победитель - ${winner.name} с результатом ${maxScore}');
      if (window.confirm('Играем еще раз?')) {
        table.reset('болдо');
        table.makeTurn();
      }
    };

    table.reset('балда');
    players[currentPlayerIdx].onStartTurn();
    table.makeTurn();
  }
}

void main() {
  new blockhead();
}
