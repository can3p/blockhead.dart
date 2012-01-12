class GameField {
  static final String STATE_INITIAL = 'initial';
  static final String STATE_ADDLETTER = 'addletter';
  static final String STATE_SELECTWORD = 'selectword';
  static final String STATE_ENDTURN = 'endturn';

  int size;
  String _state;
  bool _fieldFull = false;
  DivElement container;
  DivElement selectedWord;
  
  List<DivElement> cells;
  DivElement newLetterCell;
  
  bool selStarted = false;
  List<DivElement> selList;
  
  var _onEnterWord;
  var _onFieldFull;
  
  GameField(this.size) {
    cells = [];
    selList = [];   
  }
  
  void set onEnterWord(void callback(String word)) {
    _onEnterWord = callback;
  }
  
  void set onFieldFull(void callback()) {
    _onFieldFull = callback;
  }
  
  void set state(String state) {
    container.classes.remove('container-${_state}');
    _state = state;
    container.classes.add('container-${_state}');
    
    switch(state) {
    case STATE_ADDLETTER:
      _resetWord();
      _clearSelection();
      break;
    case STATE_SELECTWORD:
      _clearSelection();
      updateSelectedWord();
      break;
    }
  }
  
  String get state() => _state;
  
  void reset(String word) {
    if (container == null) {
      container  = document.query('#field');
      buildTable();
      bindEvents();
    } else {
      clearTable();
    }
    
    _fieldFull = false;
    state = STATE_INITIAL;
    setInitialWord(word);
  }
  
  void clearTable() {
    cells.forEach((el) => el.innerHTML = '');
  }
  
  void buildTable() {
    var table = new Element.tag('div');
    table.classes.add('field-container');
    container.nodes.add(table);
    
    num count = size * size + 1;
    Element element;
    while (count-- > 1) {
      element = new Element.html('<div class="field-cell"></div>');
      
      if (count % size == 0) {
        element.classes.add('field-cell-newrow');
      }
      
      table.nodes.add(element);
      cells.add(element);
    }
    
    selectedWord = new Element.html('<div class="field-selectedword" />');
    container.nodes.add(selectedWord);
  }

  void bindEvents() {
    var dragStartEvent = (ev) => dragStart(ev.target);
    var dragProcessEvent = (ev) => dragProcess(ev.target);
    var dragStopEvent = (ev) => dragStop();
    

    cells.forEach( (cell) {
      cell.on.mouseDown.add(dragStartEvent);
      cell.on.mouseOver.add(dragProcessEvent);
    });
    
    container.on.selectStart.add( (ev) => ev.preventDefault() );
    document.body.on.mouseUp.add(dragStopEvent);
    
    selectedWord.on.click.add( (ev) {
      var cell = ev.target;
      if (cell.classes.contains('field-selectedword-incorrect')) { return; }
      state = STATE_ENDTURN;
      _onEnterWord(_getSelectedWord());
    });
  }

  void setInitialWord(String word) {
    if (state != STATE_INITIAL) {
      throw new Exception('Game field was not reset before setting new word');
    }
    
    if (word.length != size) {
      throw new Exception("Only words with length ${size} are allowed");
    }
    
    num y = (size / 2).floor();
    for(int x = 0; x < word.length; ++x) {
      putLetter(x, y, word[x]);
    }
    
    _recalcAccessible();
  }

  void putLetter(int x, int y, String letter, [bool isNew = false]) {
    Element cell = getCell(x, y);
    if (cell.innerHTML.length > 0) {
      throw new Exception('The letter at this position x:${x}, y:${y} was already set');
    }
    
    cell.innerHTML = letter;
    if (isNew) {
      _resetWord();
      cell.classes.add('field-new');
      newLetterCell = cell;
    }
  }
  
  Element getCell(int x, int y) {
    if( x < 0 || y < 0 || x >= size || y >= size ) {
      throw new Exception('Coordinates out of bounds');
    }
    
    return cells[x + y * size];
    
  }
  
  int _getCellPosition(cell) {
    for(int idx = 0; idx < cells.length; ++idx) {
      if (cell == cells[idx]) {
        return idx;
      }
    }
    
    return -1;
  }
  
  Dynamic _getCellCoords(cell) {
    int idx = _getCellPosition(cell);
    if (idx == -1) { return {}; }
    
    return {
      'x': idx % size,
      'y':  (idx / size).floor()
    };
  }
  
  List getAdjacentCells(cell) {
    var idx = _getCellPosition(cell);
    List idxes = [ idx - 1, idx + 1, idx - size, idx + size ];
    List resultCells = new List();
    
    idxes.forEach((el) {
      if (el >= 0 && el < cells.length) {
        resultCells.add(cells[el]);
      }
    });

    return resultCells;
  }
  
  void _recalcAccessible() {
    String hoverableClass = 'field-hoverable';
    var hoverableFilter = (cell) => !cell.classes.contains(hoverableClass);
    List newFilled = cells.filter((cell) => cell.innerHTML.length > 0);
    
    newFilled.forEach((cell) {
      getAdjacentCells(cell)
        .filter(hoverableFilter)
        .filter((testCell) => testCell.innerHTML.length == 0)
        .forEach((Element el) => el.classes.add(hoverableClass));
    });
  }
  
  void makeTurn() {
    if (_fieldFull) {
//       _onFieldFull();
      return;
    }

    state = STATE_ADDLETTER;
  }
  
  void dragStart(cell) {
    if (cell.innerHTML.length == 0) {
      if (!cell.classes.contains('field-hoverable')) { return; }
      if (state == STATE_ADDLETTER || state == STATE_SELECTWORD) {
        String newLetter = window.prompt('Введите букву, которая должна появиться в поле', '');
        if(newLetter == null || newLetter.length == 0 || newLetter.length > 1) { return; }
        newLetter = newLetter.toLowerCase();
        if (new RegExp('[^а-я]', ignoreCase: true).hasMatch(newLetter)) {
          window.alert('Для ввода допускается только кириллица');
          return;
        }
        var coords = _getCellCoords(cell);
        if (coords.isEmpty()) { return; }
        
        
        putLetter(coords['x'], coords['y'], newLetter, true);
        state = STATE_SELECTWORD;
      }

      return;
    }
    
    if (state != STATE_SELECTWORD) { return; }

    _clearSelection();
    selStarted = true;  
    dragProcess(cell);
  }
  
  void dragProcess(cell) {
    if (!selStarted) { return; }
    if (cell.innerHTML.length == 0) { return; }
    if (selList.length > 0 && getAdjacentCells(selList.last()).indexOf(cell) == -1) { return; }
    if (selList.length > 1 && cell == selList[selList.length - 2]) {
      selList.removeLast().classes.remove('field-selected');
    }
    if (selList.indexOf(cell) >= 0) { return; }
    
    cell.classes.add('field-selected');
    selList.add(cell);
    updateSelectedWord();
  }
  
  void dragStop() {
    selStarted = false;
  }
  
  String _getSelectedWord() {
    String word = '';
    if (selList.length != 0) {
      for(Element cell in selList) {
        word += cell.innerHTML;
      }
    }
    
    return word;
  }
  
  void _clearSelection() {
    selList.forEach((el) => el.classes.remove('field-selected'));
    selList.clear();
  }
  
  void updateSelectedWord() {
    selectedWord.innerHTML = _getSelectedWord();

    if (selList.length != 0) {
      if(selList.indexOf(newLetterCell) == -1) {
        selectedWord.classes.add('field-selectedword-incorrect');
      } else {
        selectedWord.classes.remove('field-selectedword-incorrect');
      }
    }
  }
  
  void applyWord() {
    if( state != STATE_ENDTURN) { return; }
    state = STATE_INITIAL;
    
    if (newLetterCell !== null) {
      newLetterCell.classes.remove('field-new');
      newLetterCell = null;
      _recalcAccessible();
      
      if (cells.every( (el) => el.innerHTML.length > 0 )) {
        _fieldFull = true;
        _onFieldFull();
      }
    }
  }
  
  void _resetWord() {
    if (newLetterCell != null && newLetterCell.classes.contains('field-new')) {
      newLetterCell.classes.remove('field-new');
      newLetterCell.innerHTML = '';
    }
  }
}