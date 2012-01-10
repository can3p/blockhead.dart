#import('dart:html');
#source('GameField.dart');
#resource('style.css');

class blockhead {
  GameField table;

  blockhead() {
    table = new GameField();
    table.onEnterWord = (String word) {
      bool approve = window.confirm('Подходит слово?');
      if (approve) {
        table.applyWord(); 
      }
      table.makeTurn();
    };
    
    table.onFieldFull = () => window.console.log('game over');
    table.reset('балда');
    table.makeTurn();
  }

  void run() {
    
  }
}

void main() {
  new blockhead().run();
}
