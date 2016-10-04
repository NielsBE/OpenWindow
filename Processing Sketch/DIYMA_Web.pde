import android.content.*;
import android.net.*;

import com.justinschultz.pusherclient.*;
import com.justinschultz.pusherclient.Pusher.*;
import org.json.JSONObject;
import org.json.JSONArray;

String   _familyId = "bdee3";
String   _inputTxt = "";
String   _inputMtd = "web";

String   _apiSrc = "http://www.mediascherm.be/assets/p";

String   _lastLog = "";
String   _lastSpeed = "";
boolean  _isTyping = true;
boolean  _hasChanged = false;
boolean  tryConnect = true;
boolean  _lastConnectionStatus = false;

String   _wifiIP;
String   _lastJavaIP;

int      _fontSize = 200;
int      _tryReconnect = 0;
int      _tryReconnectSince = 0;
int      _colorSet = 0;
color    _colorTxt = color(0, 0, 0);
color    _colorBgd = color(255, 255, 0);
float    _maxTxtWd = .9;
PImage   _blob;

int      _reconnectRun = 3;

PFont    _renderFontDefault;
PFont    _renderFontClassic;
PFont    _renderFontHandwriting;
Logger   _logger;
Pusher   _pusher;
Animator _anim;

void setup() {
  frameRate(30);
  size(800, 600);
  background(0);
  
  _maxTxtWd = width * _maxTxtWd;
  
  try {
    _renderFontDefault = createFont("Default.ttf", _fontSize, true);
    _renderFontClassic = createFont("Classic.otf", _fontSize, true);
    _renderFontHandwriting = createFont("Handwriting.ttf", _fontSize, true);
    
    _logger = new Logger(_familyId, _inputMtd);
  } catch (Exception e) {
    e.printStackTrace();
  }
  
//  _blob = loadImage("blobs_web.jpg");
  
  connectPusher();
  
  smooth();
  noStroke();

  textFont(_renderFontDefault, _fontSize);
  textAlign(LEFT);
  fill(_colorTxt);
  
  try {
    loadStrings(_apiSrc + "/setSystemAlive.php?family=" + _familyId + "&date=" + java.net.URLEncoder.encode(getDateTime(), "ISO-8859-1"));
    
    String[] _lastMsg = loadStrings(_apiSrc + "/getLatestMessage.php?family=" + _familyId);
      
    JSONObject jsonObj = new JSONObject(_lastMsg[0]);
  
    jsonObj = new JSONObject(jsonObj.get("meta").toString());
    String _content = trim(jsonObj.getString("content"));
    int _speed = jsonObj.getInt("speed");
    int _appearance = jsonObj.getInt("appearance");
    int _font = jsonObj.getInt("font");
    int _size = jsonObj.getInt("size");
    _colorSet = jsonObj.getInt("colorFamily");
  
    JSONArray jsonArr = jsonObj.getJSONArray("colors");
    _colorTxt = color(jsonArr.getInt(0), jsonArr.getInt(1), jsonArr.getInt(2));
    _colorBgd = color(jsonArr.getInt(3), jsonArr.getInt(4), jsonArr.getInt(5));
  
    _isTyping = false;
    boolean isValid = (_content.length() == 0) ? false : true;
    if (isValid) {
      try {
        _font = (_font > 2) ? 2 : _font;
        _speed = _speed;
        _appearance = (_appearance > 3) ? 3 : _appearance;
        _anim = new Animator(_content, _speed, _appearance, _font, _size);
        
        fill(_colorTxt);
          
        loadStrings(_apiSrc + "/setSystemAlive.php?family=" + _familyId + "&date=" + java.net.URLEncoder.encode(getDateTime(), "ISO-8859-1"));
      } catch (Exception e) {
        _logger.addError(e, "Pusher message set-text-" + _familyId + " Animator");
        e.printStackTrace();
      }
    }
  } catch (Exception e) {
    _logger.addError(e, "Application restart " + _familyId);
  }
}

void draw() {
  background(_colorBgd);

  if (_anim != null) {
    _anim.draw();
  }
}
