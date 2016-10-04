public void connectPusher() {
  PusherListener eventListener = new PusherListener() {  
    Channel channel;

    public void onConnect(String socketId) {
      channel = _pusher.subscribe("ma_diy");
      
      channel.bind("is-alive-" + _familyId, new ChannelListener() {
        public void onMessage(String message) {
          try {
            println("is alive?");
            loadStrings(_apiSrc + "/setSystemAlive.php?family=" + _familyId + "&date=" + java.net.URLEncoder.encode(getDateTime(), "ISO-8859-1"));
          } catch (Exception e) {
            _logger.addError(e, "Pusher message is-alive-" + _familyId);
          }
        }
      });
      
      channel.bind("reboot-" + _familyId, new ChannelListener() {
        public void onMessage(String message) {
          try {
            Runtime.getRuntime().exec(new String[]{"su","-c","reboot now"});
          } catch (Exception e) {
            _logger.addError(e, "Pusher message reboot-" + _familyId);
          }
        }
      });
      
      channel.bind("new-config-" + _familyId, new ChannelListener() {
        public void onMessage(String message) {
          try {
            JSONObject jsonObj = new JSONObject(message);
            jsonObj = new JSONObject(jsonObj.get("data").toString());
            int _speed = jsonObj.getInt("speed");
            int _size = jsonObj.getInt("size");
            int _reconnect = jsonObj.getInt("timeout");

            JSONArray jsonArr = jsonObj.getJSONArray("colors");
            
            for (int i = 0; i < jsonArr.length(); i++) {
              JSONObject row = jsonArr.getJSONObject(i);
              if (row.getInt("color_family") == _colorSet) {
                if (row.getString("target").equals("b")) {
                  int[] _c = int(split(row.getString("color"), ','));
                  _colorBgd = color(_c[0], _c[1], _c[2]);
                } else if (row.getString("target").equals("f")) {
                  int[] _c = int(split(row.getString("color"), ','));
                  _colorTxt = color(_c[0], _c[1], _c[2]);
                  fill(_colorTxt);
                }
              }
            }
            
            if (_anim != null) {
              _anim.setSpeed(_speed);
              _anim.setSize(_size);
              _anim.setTimeout(_reconnect);
            }
            
            loadStrings(_apiSrc + "/setSystemAlive.php?family=" + _familyId + "&date=" + java.net.URLEncoder.encode(getDateTime(), "ISO-8859-1"));

          } catch (Exception e) {
            _logger.addError(e, "Pusher message new-config-" + _familyId);
//            e.printStackTrace();
          }
        }
      });
      
      channel.bind("set-text-" + _familyId, new ChannelListener() {
        public void onMessage(String message) {
          try {
            JSONObject jsonObj = new JSONObject(message);
            jsonObj = new JSONObject(jsonObj.get("data").toString());
            String _id = jsonObj.getString("record");
            String _type = jsonObj.getString("type");

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
                  
                loadStrings(_apiSrc + "/acknowledge.php?family=" + _familyId + "&id=" + _id + "&publish_date=" + java.net.URLEncoder.encode(getDateTime(), "ISO-8859-1"));
                loadStrings(_apiSrc + "/setSystemAlive.php?family=" + _familyId + "&date=" + java.net.URLEncoder.encode(getDateTime(), "ISO-8859-1"));
              } catch (Exception e) {
                _logger.addError(e, "Pusher message set-text-" + _familyId + " Animator");
//                e.printStackTrace();
              }
            }

          } catch (Exception e) {
            _logger.addError(e, "Pusher message set-text-" + _familyId);
//            e.printStackTrace();
          }
        }
      });
    }

    public void onMessage(String message) {
      try {
//        println(getDateTime() + " " + message);
      } catch (Exception e) {
        _logger.addError(e, "Pusher message");
      } 
    }

    public void onDisconnect() {
      println("Pusher disconnected.");
    }
  };
  
  _pusher = new Pusher("262a988c45cf1be8210c");   
  _pusher.setPusherListener(eventListener);
  _pusher.connect();
}

public String getDateTime() {
  Date d = new Date();
  java.text.SimpleDateFormat sdf; 
  return new java.text.SimpleDateFormat("yyyy-MM-dd kk:mm:ss").format(d);
}

ArrayList wordWrap(String s, float maxWidth) {
  ArrayList a = new ArrayList();
  float w = 0;
  int i = 0;
  int rememberSpace = 0;
  
  while (i < s.length()) {
    char c = s.charAt(i);
    w += textWidth(c);
    if (c == ' ') rememberSpace = i;
    if (w > maxWidth) {
      String sub = s.substring(0,(rememberSpace > 0) ? rememberSpace : i);

      if (sub.length() > 0 && sub.charAt(0) == ' ') sub = sub.substring(1,sub.length());
      else if (sub.length() > 0 && sub.charAt(0) != ' ') sub = sub.substring(0, sub.length());

      a.add(sub);

      s = s.substring((rememberSpace > 0) ? rememberSpace : i,s.length());
      i = 0;
      w = 0;
    } else {
      i++;
    }
  }
 
  if (s.length() > 0 && s.charAt(0) == ' ') s = s.substring(1,s.length());
  else if (s.length() > 0 && s.charAt(0) != ' ') s = s.substring(0, s.length());
  a.add(s);
 
  return a;
}
