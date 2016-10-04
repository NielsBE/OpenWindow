package processing.test.diyma;

import processing.core.*; 
import processing.data.*; 
import processing.opengl.*; 

import android.content.Context; 

import android.view.MotionEvent; 
import android.view.KeyEvent; 
import android.graphics.Bitmap; 
import java.io.*; 
import java.util.*; 

public class DIYMA extends PApplet {



String  _familyId = "aba04";
String  _inputTxt = "";
String  _inputMtd = "keyboard";

boolean _isTyping = true;
int     _fontSize = 80;
int   _colorTxt = color(255, 0, 0);

PFont   _renderFont;
Logger  _logger;

public void setup() {
 
  background(0);
  
  try {
    _renderFont = loadFont("BPdots-160.vlw");
    _logger = new Logger(_familyId, _inputMtd);
  } catch (Exception e) {
    e.printStackTrace();
  }
  
  println(loadStrings("http://nwt.rs"));
  // we should listen for signal here
  //  - isAlive? --> pingback to URL
  //  - content? --> pingback to URL
  
  smooth();
  noStroke();

}

public void draw() {
  background(0);
  textFont(_renderFont, _fontSize);
  textAlign(LEFT, CENTER);
  fill(_colorTxt);
  text(_inputTxt + (_isTyping && frameCount / 20 % 2 == 0 ? "_" : ""), width / 2 - textWidth(_inputTxt) / 2, height / 2);
}

public void keyPressed() {
  if (keyCode == 67) {
    _isTyping = true;
    _inputTxt = _inputTxt.substring(0, max(0, _inputTxt.length()-1));
  } else if (key != CODED) {
    switch (key) {
      case BACKSPACE:
      case DELETE:
        _inputTxt = _inputTxt.substring(0, max(0, _inputTxt.length()-1));
        break;
      case ENTER:
      case RETURN:
        _inputTxt = trim(_inputTxt);
        _isTyping = false;
        boolean isValid = (_inputTxt.length() == 0) ? false : true;
        if (isValid) {
          try {
            _logger.add(_inputTxt);
          } catch (Exception e) {
            e.printStackTrace();
          }
        }
        break;
      case TAB:
        _inputTxt += " ";
        break;
      default:
        _isTyping = true;
        if (textWidth(_inputTxt + key) > width * .9f) {
          StringBuilder b = new StringBuilder(_inputTxt);
          b.replace(_inputTxt.lastIndexOf(" "), _inputTxt.lastIndexOf(" ") + 1, "\n");
          _inputTxt = b.toString();
          _inputTxt += key;
        } else {
          _inputTxt += key;
        }
        break;
    }
  }
}
class Logger {
  private String _fileName;
  private String _inputMethod;
  private String _conn;
  
  public Logger(String file, String inputMethod) throws IOException { 
    this._fileName = file;
    this._inputMethod = inputMethod;
    
    Date d = new Date();
    java.text.SimpleDateFormat sdf; 
    String date = new java.text.SimpleDateFormat("yyyy-MM-dd kk:mm:ss").format(d);
    
    android.net.ConnectivityManager conMan = (android.net.ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
    android.net.NetworkInfo.State mobile = conMan.getNetworkInfo(0).getState(); // mobile
    android.net.NetworkInfo.State wifi = conMan.getNetworkInfo(1).getState(); //wifi

    if (mobile == android.net.NetworkInfo.State.CONNECTED) {
      this._conn = "3G";
    } else if (wifi == android.net.NetworkInfo.State.CONNECTED) {
      this._conn = "WiFi";
    } else {
      this._conn = "none";
    }

    File localStorage = new File(android.os.Environment.getExternalStorageDirectory().toString() + "/log_" + this._fileName +  ".txt");
    localStorage.createNewFile();
    FileOutputStream fos = new FileOutputStream(localStorage, true);
    fos.write(("[" + this._fileName + "][" + this._conn + "][" + date.toString() + "][STATUS] ----------------------------------------" + "\n").getBytes());
    fos.close();
  }
  
  public void add(String message) throws IOException {
    Date d = new Date();
    java.text.SimpleDateFormat sdf; 
    String date = new java.text.SimpleDateFormat("yyyy-MM-dd kk:mm:ss").format(d);
    
    android.net.ConnectivityManager conMan = (android.net.ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
    android.net.NetworkInfo.State mobile = conMan.getNetworkInfo(0).getState(); // mobile
    android.net.NetworkInfo.State wifi = conMan.getNetworkInfo(1).getState(); //wifi

    if (mobile == android.net.NetworkInfo.State.CONNECTED) {
      this._conn = "3G";
    } else if (wifi == android.net.NetworkInfo.State.CONNECTED) {
      this._conn = "WiFi";
    } else {
      this._conn = "none";
    }

    File localStorage = new File(android.os.Environment.getExternalStorageDirectory().toString() + "/log_" + this._fileName +  ".txt");
    localStorage.createNewFile();
    FileOutputStream fos = new FileOutputStream(localStorage, true);
    fos.write(("[" + this._fileName + "][" + this._conn + "][" + date.toString() + "][" + this._inputMethod + "] " + message.replace("\n", " ") + "\n").getBytes());
    fos.close();
  }
}

  public int sketchWidth() { return 800; }
  public int sketchHeight() { return 600; }
}
