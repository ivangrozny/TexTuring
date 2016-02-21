int frames = 30;
float[] slider = {0 ,40 ,20 ,0 ,20 ,20 ,20 ,20}; float[] knob = {60 ,0 ,0 ,0 ,0 ,0 ,0 ,0};
DiSlider di ; CheckBox checkbox; MapImg mapImg;
PFont font;
boolean control = false, live = true, map = false, viewing = false, seuilVisible=true, greyScale = true;
String[] saved ; 
String lastPath ;
PImage src, view, currentI, srcMin, grad,gradInvert;
int viewX, viewY,h,w, off, offX, offY, viewSize=100 ;
color[] C = new color[26];

ArrayList<GuiElement> elements;

void setup() {
  size(1350, 720); //frame.setIconImage( getToolkit().getImage("icone.ico") ); //size(displayWidth, displayHeight);
  //if (frame != null) { frame.setResizable(true) ;}
  frameRate(60);
  for (int i = 0; i<=25; i++){ colorMode(HSB); C[i] = color(122,270-i*13,100+i*5); } // create UI color shades
  background(C[25]); noStroke();
  src=loadImage("wiki.png");
  grad=loadImage("gradient.png"); gradInvert=loadImage("gradInvert.png");
  font = loadFont("FedraTwelve-Normal-12.vlw");  textFont(font, 12); fontColor();

  elements = new ArrayList<GuiElement>();
  elements.add(new Button(new Rect( d    , d, 100+5, 20       ), "new file"));
  elements.add(new Button(new Rect( d+110, d, 100+5, 20       ), "export"));
  elements.add(new Button(new Rect( d+220, d, 100+5, 20       ), "load"));
  elements.add(new Button(new Rect( d+330, d, 95,    20       ), "save"));
  elements.add(new Button(new Rect( d+430, d, a/2-b, 20       ), "specimen"));
  elements.add(new Button(new Rect( d+a+a+a/2+30, d, a/2-b, 20), "render"));

  elements.add(new Slider(new Rect( gauche,  haut+a+c+15, a+20, 20), "iterations", 2000));  
  for (int i = 0; i<6; i++) {  
    elements.add(new Snap( new Rect( d+i%6*(a/2+b), height-d-a/2+floor(i/6)*(a/2+b), a/2, a/2 ) , "snap"+i ));  
  }
  elements.add(new BiSlider(new Rect( gauche-10, haut+a+c+150, a+20 , 60), "reaction"));
  elements.add(new BiSlider(new Rect( gauche-10, haut+a+c+a+a/2-60, a+20, 60), "diffusion"));

  elements.add(new DiSlider(new Rect( gauche+a+80+b, haut+a+c+10, a+20, a+20), "thickness", "brightness"));

  // TODO (GUI) inclure un switch pour un export en greyScale
  if(seuilVisible) text("threshold", gauche+20, haut+a+c+55); 

  mapImg = new MapImg(gauche, haut);
  
  saved = loadStrings("default.trm");
  setParam(saved);

  //selectInput("Select a file to process:", "fileSelected"); noLoop();  // File selector at TexTuring-launch
  File file = new File( dataPath("wiki.png") ); fileSelected(file);      // File selected at TexTuring-launch

}
void draw() {
  //if (frameCount%1==0) viewSize = (int)map(slider[0],0,1000,a,50);//int(frameRate*20) ;
  if (viewing && srcMin!=null) preview() ;
}


void preview(){
  //fill(C[25]); rect(a+b+d, d+haut, a/2, a/2); 
  view = src.get( viewX,viewY, viewSize, viewSize); turing2(view); 
  viewing = false ;
  imageMode(CENTER); image(view, gauche+srcMin.width+(a-srcMin.width+a+a/2)/2, haut+a/2); imageMode(CORNER);
}
void controlEvent (ControlEvent theEvent) {
  println("got a control event from controller with name " + theEvent.getName() );

  if ( theEvent.getName() == "new file" ) { }  
  if ( theEvent.getName() == "renderControl" ) render(); 
  if ( theEvent.getName() == "export" )   {  }
  if ( theEvent.getName() == "specimen" ) {  }

  if ( theEvent.getName() == "load" ) {  }
  if ( theEvent.getName() == "save" ) {   }
}

void render(){
  currentI = src.get();
  turing2(currentI); 
  image(currentI, 3*a+35+d, d ); // ,(currentI.width*(height-d))/currentI.height, height-d); 
}
float[][] videoCtrl = new float[4][8] ; // iniSlider, iniKnob, finSlider, finKnob
int videoName = 0;
String instanceVideoFolder = ""+random(0, 1);
void saveVideo(){
  for (int i = 1; i<=frames; i++){ videoName++;
    currentI = src.get();
    for (int j = 0; j<8; j++){
      slider[j] = map(i,0,frames,videoCtrl[0][j],videoCtrl[2][j]);
      knob  [j] = map(i,0,frames,videoCtrl[1][j],videoCtrl[3][j]);
    }
    turing2(currentI); 
    image(currentI, 3*a+35+d, d );
    currentI.save("video/animation_"+instanceVideoFolder+"/"+videoName+".png");
  }
}
void keyPressed(){
  if ( keyCode == CONTROL) control = true;
  if (key == 'i') src.filter(INVERT);
  if (key == '+') src.resize(int(src.width+100),0);  if (key == '-') src.resize(int(src.width-100),0);
  if (key == 'v') { for (int i = 0; i<8; i++){ videoCtrl[0][i]=slider[i];  videoCtrl[1][i]=knob[i];  saved[i]=slider[i]+" "+knob[i] ; }              saveStrings( "video/animation_"+instanceVideoFolder+"/"+videoName+"-V.trm", saved); }
  if (key == 'b') { for (int i = 0; i<8; i++){ videoCtrl[2][i]=slider[i];  videoCtrl[3][i]=knob[i];  saved[i]=slider[i]+" "+knob[i] ; } saveVideo(); saveStrings( "video/animation_"+instanceVideoFolder+"/"+videoName+"-B.trm", saved); }
  if (key == 'a') {  selectFolder("Select a folder to process:", "folderSelected");  } 
}
ArrayList<File> filesList = new ArrayList<File>();

void folderSelected(File selection) {
  if (selection!=null) {
// export PNG
currentI.save(selection.getAbsolutePath()+"/"+frameCount+"_test.png");

// compute multi-frames for video txture
/*    File file = new File(selection.getAbsolutePath());
    File[] files = file.listFiles();
    for (int i = 0; i < files.length; i++) {
      filesList.add(files[i]);
    }
  }
  int count = 0;
  int folder = int(random(0, 100000));
  for(File f : filesList){ count++;
    src=loadImage(selection.getAbsolutePath()+"/"+f.getName()); 
    src.filter(GRAY);
    render(); 
    currentI.save("video/video_"+folder+"/"+count+".png");*/

  }
}
void keyReleased()  { control = false; }
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

/*  if ( theEvent.getName() == "iterations" )    { slider[0] = theEvent.getController().getValue(); viewing = true ;}
  if ( theEvent.getName() == "threshold" )     { slider[1] = theEvent.getController().getValue(); viewing = true ;}
  if ( theEvent.isFrom(checkbox) )             { button[0] = !button[0] ;     viewing = true ;}
*/
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
  for (int i = 0; i<8; i++){ saved[i] = slider[i]+" "+knob[i] ; } 
  //saveStrings( selection.getAbsolutePath()+".trm", saved) ;
  render(); //currentI.save(selection.getAbsolutePath()+".png");
  fileToPrinter("specimen.pdf");
  loop(); 
}
void saveParameters(File selection){ 
  for (int i = 0; i<8; i++){ saved[i] = slider[i]+" "+knob[i] ; } 
  saveStrings( selection.getAbsolutePath()+".trm", saved) ;
  loop(); 
}
void loadParameters(File selection){ setParam(loadStrings(selection.getAbsolutePath())); loop(); }
void setParam ( String data[] ) {           
  for (int i = 0; i<8; i++) { 
    String[] n = split(data[i]," "); 
    slider[i] = int(n[0]); 
    knob[i] = int(n[1]); 
  }

  for (GuiElement elem : elements) {
    elem.released();
    elem.update();
    map=true; elem.updateImg(); map=false;
  }
  // TODO slider[iterations].setValue(slider[0]);
  // TODO slider[ threshold].setValue(slider[1]);
  viewing = true ;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void fileToPrinter(String fileName) {
  try {
    ProcessBuilder pb = new ProcessBuilder("lpr", fileName);
    Process p = pb.start();
  } catch (IOException e) { println(e); }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
