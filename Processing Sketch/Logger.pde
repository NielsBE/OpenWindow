class Logger {
  private String _fileName;
  private String _inputMethod;
  private String _conn;
  
  public Logger(String file, String inputMethod) throws IOException { 
    this._fileName = file;
    this._inputMethod = inputMethod;
  }
  
  public void addError(Exception e, String source) {
    try {
      String date = getDateTime();

      loadStrings(_apiSrc + "/log_error.php?family=" + this._fileName + "&source=" + this.urlEncode(source) + "&text=" + this.urlEncode(e.toString()) + "&create_date=" + this.urlEncode(date));
  
    } catch (Exception ex) {
//      ex.printStackTrace();
    }
  }
  
  private String urlEncode(String string) {
    try { 
      return java.net.URLEncoder.encode(string, "ISO-8859-1");
    } catch (Exception e) {
//      e.printStackTrace();
    }
    return "";
  }
}
