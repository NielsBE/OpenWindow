class Animator {
  private float _textWidth;
  private float _scrollPos;
  private String _text;
  private ArrayList _textAL;
  
  private int _speed;
  private int _appearance;
  private int _size;
  
  private int _runs = 0;
  
  public Animator(String txt) {
    _textWidth = textWidth(txt);
    _scrollPos = width;
    _text = txt;
  }
  
  public Animator(String txt, int speed, int appearance, int fontType, int fontSize) {
    _fontSize = fontSize;

    switch (fontType) {
      case 0:
        textFont(_renderFontDefault, _fontSize);
        break;
      case 1:
        textFont(_renderFontClassic, _fontSize);
        break;
      case 2:
        textFont(_renderFontHandwriting, _fontSize);
        break;
      default:
        textFont(_renderFontDefault, _fontSize);
        break;
    }

    _textWidth = textWidth(txt);
    _scrollPos = width;
    _text = txt;
    
    _speed = speed;
    _appearance = appearance;
    
    if (_appearance >= 2) {
      _textAL = wordWrap(txt, width * .9);
      _textWidth = 0;
      _scrollPos = height;
    }
  }
  
  public void setSpeed(int speed) { _speed = speed; }
  
  public void setSize(int fontSize) { 
    _fontSize = fontSize; 
    textSize(fontSize); 
    if (_appearance >= 2) {
      _textAL = wordWrap(_text, width * .9);
      _textWidth = 0;
    }
  }
  
  public void setTimeout(int timeout) { _runs = 0; _reconnectRun = timeout; }
  
  public void draw() {
    switch (_appearance) {
      case 0: 
        // left > right
        _scrollPos += _speed;
        if (_scrollPos > width) {
          _runs++;
          _scrollPos = - _textWidth;
          if (_runs == _reconnectRun) {
            try {
              _pusher.disconnect();
              connectPusher();
              _runs = 0;
            } catch (Exception e) { }
          }
        }
        text(this._text, _scrollPos, _fontSize);
        break;
      case 1:
        // right > left
        _scrollPos -= _speed;
        if (_scrollPos < (- _textWidth)) {
          _runs++;
          _scrollPos = width;
          if (_runs == _reconnectRun) {
            try {
              _pusher.disconnect();
              connectPusher();
              _runs = 0;
            } catch (Exception e) { }
          }
        }
        text(this._text, _scrollPos, _fontSize);
        break;
      case 2:
        // down > up
        _scrollPos -= _speed;
        for (int i = 0; i < this._textAL.size(); i++) {
          text(this._textAL.get(i).toString(), (width - textWidth(this._textAL.get(i).toString())) / 2, (i + 1) * _fontSize + _scrollPos);
        }
        if (_scrollPos <= (this._textAL.size() * (- _fontSize))) {
          _runs++;
          _scrollPos = height;
          if (_runs == _reconnectRun) {
            try {
              _pusher.disconnect();
              connectPusher();
              _runs = 0;
            } catch (Exception e) { }
          }
        }
        break;
      case 3:
        // up > down
        _scrollPos += _speed;
        for (int i = 0; i < this._textAL.size(); i++) {
          text(this._textAL.get(i).toString(), (width - textWidth(this._textAL.get(i).toString())) / 2, (i + 1) * _fontSize + _scrollPos);
        }
        if (_scrollPos >= height) { //this._textAL.size() * _fontSize) {
          _runs++;
          _scrollPos = - (this._textAL.size() * _fontSize);
          if (_runs == _reconnectRun) {
            try {
              _pusher.disconnect();
              connectPusher();
              _runs = 0;
            } catch (Exception e) { }
          }

        }
        break;
    }
  }
}
