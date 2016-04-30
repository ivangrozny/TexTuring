
class Parameters {
  float[] b = {0 ,0 ,0 ,0} ; // R&D black handle
  float[] w = {0 ,0 ,0 ,0} ; // R&D white handle
  int[]   o = {0, 0, 200} ; // iterations, threshold, resolution
  int iniState = 0 ;
  Parameters() {  }

  void save(String _filePath){
    String[] saveData = new String[8];

    for (int i = 0; i<7; i++){ 
      if (i<4) saveData[i] = b[i]+" "+w[i] ; 
      if (i>3) saveData[i] = o[i-4]+"" ; 
    } 
    saveData[7] = iniState+"";

    if ( match(_filePath, ".TexTuring") == null ) _filePath += ".TexTuring" ;
    saveStrings( _filePath, saveData) ;
  }

  void loadFile( File _file ){ if(_file != null) load( loadStrings(_file.getAbsolutePath()) ); }
  void saveFile( File _file ){ if(_file != null) save( _file.getAbsolutePath() ); }

  void load( String[] _data ){
    for (int i = 0; i<4; i++) { 
      String[] tmp = split(_data[i]," "); 
      b[i] = float( tmp[0] ); 
      w[i] = float( tmp[1] ); 
    }
    o[0] = int(_data[4] );
    o[1] = int(_data[5] );
    o[2] = int(_data[6] );
    iniState = int(_data[7]) ;
    gui.update();
  }
  void loadParameters( Parameters other ) {
    arrayCopy(other.b, b) ;
    arrayCopy(other.w, w) ;
    arrayCopy(other.o, o) ;
    iniState = other.iniState ;
  }
}


  