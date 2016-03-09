MapImg mapImg;
boolean control = false, live = true, map = false, viewing = false, greyScale = true;
PImage src, view, currentI, srcMin, grad,gradInvert;
int viewX, viewY,h,w, off, offX, offY, viewSize=100 ;
String lastPath ;
PFont font;
color[] C = new color[26];

Parameters params = new Parameters();
ArrayList<GuiElement> elements = new ArrayList<GuiElement>();

void setup() {
  size(1350, 720); //frame.setIconImage( getToolkit().getImage("icone.ico") ); //size(displayWidth, displayHeight);
  //if (frame != null) { frame.setResizable(true) ;}
  frameRate(60);
  for (int i = 0; i<=25; i++){ colorMode(HSB); C[i] = color(122,270-i*13,100+i*5); } // create UI color shades
  background(C[25]); noStroke();
  grad = loadImage("gradient.png"); gradInvert=loadImage("gradInvert.png");
  font = loadFont("FedraTwelve-Normal-12.vlw");  textFont(font, 12); fontColor();

  elements.add(new Button(new Rect( d    , d, 100+5, 20       ), "new file"));
  elements.add(new Button(new Rect( d+110, d, 100+5, 20       ), "export"));
  elements.add(new Button(new Rect( d+220, d, 100+5, 20       ), "load"));
  elements.add(new Button(new Rect( d+330, d, 95,    20       ), "save"));
  elements.add(new Button(new Rect( d+430, d, a/2-b, 20       ), "specimen"));
  elements.add(new Button(new Rect( d+a+a+a/2+30, d, a/2-b, 20), "render"));
  elements.add(new   Slider(new Rect( gauche,  haut+a+c+15, a+20, 20), "iterations", 2000));  
  elements.add(new   Slider(new Rect( gauche,  haut+a+c+65, a+20, 20), "threshold", 255));  
  elements.add(new BiSlider(new Rect( gauche-10, haut+a+c+150, a+20 , 60), "reaction"));
  elements.add(new BiSlider(new Rect( gauche-10, haut+a+c+a+a/2-60, a+20, 60), "diffusion"));
  elements.add(new DiSlider(new Rect( gauche+a+80+b, haut+a+c+10, a+20, a+20), "thickness", "brightness"));
  for (int i = 0; i<6; i++) {  
    elements.add(new Snap( new Rect( d+i%6*(a/2+b), height-d-a/2+floor(i/6)*(a/2+b), a/2, a/2 ) , "snap"+i ));  
  }

  // TODO (GUI) inclure un switch pour un export en greyScale
  mapImg = new MapImg(gauche, haut);
  
  params.loadFile( new File(dataPath("default.texturing")) );
  fileSelected( new File(dataPath("wiki.png")) );                        // file selected at TexTuring launch
  //selectInput("Select a file to process:", "fileSelected"); noLoop();  // file selector at TexTuring launch
}

void draw() {
  //if (frameCount%1==0) viewSize = (int)map(Slider[0],0,1000,a,50);//int(frameRate*20) ;
  if (viewing && srcMin != null) preview() ;
}

class Parameters {
  float[] b = {0 ,0 ,0 ,0} ; // R&D black handle
  float[] w = {0 ,0 ,0 ,0} ; // R&D white handle
  int[]   o = {0, 0, 0} ; // iterations, threshold, resolution
  Parameters() {  }

  void save(String _filePath){
    String[] saveData = new String[7];

    for (int i = 0; i<7; i++){ 
      if (i<4) saveData[i] = b[i]+" "+w[i] ; 
      if (i>3) saveData[i] = o[i-4]+"" ; 
    } 
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
    updateGui();
  }
  void loadParameters( Parameters other ) {
    arrayCopy(other.b, b) ;
    arrayCopy(other.w, w) ;
    arrayCopy(other.o, o) ;
  }
  void updateGui(){
    for (GuiElement elem : elements) {
      elem.update();
    }
    updateDiSliderImage();
    viewing = true ;
  }
}
void loadFile( File _file ){ params.loadFile( _file ); }
void saveFile( File _file ){ params.saveFile( _file ); }

void preview(){
  //fill(C[25]); rect(a+b+d, d+haut, a/2, a/2); 
  view = src.get( viewX,viewY, viewSize, viewSize); turing2(view); 
  viewing = false ;
  imageMode(CENTER); image(view, gauche+srcMin.width+(a-srcMin.width+a+a/2)/2, haut+a/2); imageMode(CORNER);
}

void render(){
  currentI = src.get();
  turing2(currentI); 
  image(currentI, 3*a+35+d, d ); // ,(currentI.width*(height-d))/currentI.height, height-d); 
}

 // export PNG
void folderSelected(File selection) {
  if (selection!=null) {
  render(); 
  currentI.save(selection.getAbsolutePath()+"/"+frameCount+"_test.png");
  }
}
void fileSelected(File selection) { lastPath=selection.getAbsolutePath(); 
  src=loadImage(lastPath); 
  src.filter(GRAY);
  w=src.width;
  h=src.height;
  if(w>h) { srcMin = src.get(); srcMin.resize(a,0); }
  if(w<=h) { srcMin = src.get(); srcMin.resize(0,a); }
  //cp5.getController("largeur (px)").setText(src.width+"");
  fill(colorElemBg); rect(gauche,haut,2*a+a/2+b,a); // setup view
  mapImg.update();
  viewing = true ;
  loop(); 
}
void saveSpecimen(File selection){ 
  //for (int i = 0; i<8; i++){ saved[i] = Slider[i]+" "+wb[i] ; } 
  //saveStrings( selection.getAbsolutePath()+".trm", saved) ;
  render(); //currentI.save(selection.getAbsolutePath()+".png");
  loop(); 
}

float[][] videoCtrl = new float[4][8] ; // iniSlider, iniwb, finSlider, finwb
int videoName = 0;
int frames = 30;
String instanceVideoFolder = ""+random(0, 1);
ArrayList<File> filebst = new ArrayList<File>();

void saveVideo(){
/*  for (int i = 1; i<=frames; i++){ videoName++;
    currentI = src.get();
    for (int j = 0; j<8; j++){
      Slider[j] = map(i,0,frames,videoCtrl[0][j],videoCtrl[2][j]);
      wb  [j] = map(i,0,frames,videoCtrl[1][j],videoCtrl[3][j]);
    }
    turing2(currentI); 
    image(currentI, 3*a+35+d, d );
    currentI.save("video/animation_"+instanceVideoFolder+"/"+videoName+".png");
  }*/
}
void keyPressed(){
  if ( keyCode == CONTROL) control = true;
  if (key == 'i') src.filter(INVERT);
  if (key == '+') src.resize(int(src.width+100),0);  if (key == '-') src.resize(int(src.width-100),0);
//  if (key == 'v') { for (int i = 0; i<8; i++){ videoCtrl[0][i]=Slider[i];  videoCtrl[1][i]=wb[i];  saved[i]=Slider[i]+" "+wb[i] ; }              saveStrings( "video/animation_"+instanceVideoFolder+"/"+videoName+"-V.trm", saved); }
//  if (key == 'b') { for (int i = 0; i<8; i++){ videoCtrl[2][i]=Slider[i];  videoCtrl[3][i]=wb[i];  saved[i]=Slider[i]+" "+wb[i] ; } saveVideo(); saveStrings( "video/animation_"+instanceVideoFolder+"/"+videoName+"-B.trm", saved); }
  if (key == 'a') {  selectFolder("Select a folder to process:", "folderSelected");  } 
  if (key == 't') {for (int i = 0; i<3; i++){
    println("o[]: "+params.o[i]);
    println("b[]: "+params.b[i]);
  }}
}
void keyReleased()  { 
  control = false; 
}
void mousePressed() {
  for (GuiElement elem : elements) {
    if ( elem.isOver() ) {
      elem.pressed();
      return;
    }
  }
}
void mouseDragged(){  mapImg.dragged(); 
  for (GuiElement elem : elements) {
    elem.dragged();
  }
}
void mouseMoved(){   mapImg.mouved(); 
  for (GuiElement elem : elements) {
    elem.mouved();
  }
}
void mouseReleased(){
  for (GuiElement elem : elements) {
    elem.released();
  }
}
void updateDiSliderImage() {
  for (GuiElement elem : elements) {
    map=true; elem.updateImg(); map=false;
  }
}
