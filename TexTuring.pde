int frames = 30;
import controlP5.*; ControlP5 cp5;
//import ddf.minim.*; Minim minim; AudioPlayer player;
float[] slider = {0 ,40 ,20 ,0 ,20 ,20 ,20 ,20}; float[] knob = {60 ,0 ,0 ,0 ,0 ,0 ,0 ,0}; boolean[] button = {true ,true ,true ,true ,true ,true ,true ,true,true,true,true,true,true,true,true,true};
BiSlider[] bi ; DiSlider di ; Snap snaps ; CheckBox checkbox; MapImg mapImg;
PFont font;
boolean control = false, live = true, map = false, viewing = false, seuilVisible=true;
String[] saved ; 
String lastPath ;
PImage src, view, currentI, srcMin, grad,gradInvert;
int viewX, viewY,h,w, off, offX, offY, viewSize=100 ;
color[] C = new color[26];

void setup() {
  size(1350, 720); //frame.setIconImage( getToolkit().getImage("icone.ico") ); //size(displayWidth, displayHeight);
  //if (frame != null) { frame.setResizable(true) ;}
  frameRate(60);
  for (int i = 0; i<=25; i++){   colorMode(HSB); C[i] = color(122,270-i*13,100+i*5); } // create palette
  background(C[25]); noStroke();
  //minim = new Minim(this); player = minim.loadFile("lake-waves-01.wav");
  src=loadImage("wiki.png");
  grad=loadImage("gradient.png"); gradInvert=loadImage("gradInvert.png");
  selectInput("Select a file to process:", "fileSelected"); noLoop(); 
  
  font = loadFont("FedraTwelve-Normal-12.vlw");  textFont(font, 12); fontColor();
  cp5 = new ControlP5(this); 

  cp5.addButton("new file",0, d,     d, 100+5, 20 ).setCaptionLabel("import image");    style1("new file");
  cp5.addButton("export",0,   d+110, d, 100+5, 20 ).setCaptionLabel("export image");    style1("export");
  cp5.addButton("load",0,     d+220, d, 100+5, 20 ).setCaptionLabel("load");    style1("load");
  cp5.addButton("save",0,     d+330 ,d, 95,   20 ).setCaptionLabel("save");  style1("save"); 

  cp5.addButton("specimen",0,  d+430, d, a/2-b, 20).setCaptionLabel("specimen");         style1("specimen");
  cp5.addButton("renderControl",0,   d+a+a+a/2+30, d, a/2-b, 20).setCaptionLabel("render     >>");         style1("renderControl");
  
  text("growing time", gauche+20, haut+a+c+10); if(seuilVisible) text("threshold", gauche+20, haut+a+c+55); 
  cp5.addSlider("iterations", 1,1000,gauche,  haut+a+c+15, a+20, 20).setDecimalPrecision(0).setCaptionLabel("");         style1("iterations"); 
  if(seuilVisible){ cp5.addSlider("threshold", 0,255, gauche+20, haut+a+c+60, a, 15).setDecimalPrecision(0).setCaptionLabel("");    style1("threshold");  }
  if(seuilVisible){ checkbox = cp5.addCheckBox("thresholdButton",gauche,  haut+a+c+60).setSize(15, 15).addItem("50", 50).hideLabels();  style2(); }

  mapImg = new MapImg(gauche, haut);
  snaps = new Snap( d,  height-d-a/2 );
  bi = new BiSlider[2]; 
  bi[0] = new BiSlider(6, "reaction", gauche-10, haut+a+c+150, a+20);
  bi[1] = new BiSlider(7, "diffusion", gauche-10, haut+a+c+a+a/2-60, a+20);
  di = new DiSlider(gauche+a+80+b, haut+a+c+10, a+20);
  
  saved = loadStrings("default.trm");
  setParam(saved);
  di.setup();
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
  if ( theEvent.getName() == "iterations" )    { slider[0] = theEvent.getController().getValue(); viewing = true ;}
  if ( theEvent.getName() == "threshold" )     { slider[1] = theEvent.getController().getValue(); viewing = true ;}
  if ( theEvent.isFrom(checkbox) )             { button[0] = !button[0] ;                         viewing = true ;}

  if ( theEvent.getName() == "new file" ) { noLoop(); selectInput("Select your image", "fileSelected"); viewing = true ;}  
  if ( theEvent.getName() == "renderControl" )     render(); 
  if ( theEvent.getName() == "export" )   { render(); currentI.save("testFinalz_"+frameCount+"_test.png"); }
  if ( theEvent.getName() == "specimen" ) { }//noLoop(); selectOutput("Nomez votre spécimen", "saveSpecimen"); }

  if ( theEvent.getName() == "load" ) {  noLoop();  selectInput( "Select TexTuring settings file", "loadParameters"); viewing = true ;}
  if ( theEvent.getName() == "save" ) {  noLoop();  selectOutput("Name your TexTuring settings file", "saveParameters"); }
  
  for (int i = 0; i<8; i++) {  
    if ( theEvent.getId() == i+16 ) { snaps.pressed(i); viewing = true ; }
  }
}
void render(){
  currentI = src.get();
  turing2(currentI); 
  image(currentI, 3*a+35+d, d ); // ,(currentI.width*(height-d))/currentI.height, height-d); 
}
float[][] videoCtrl = new float[4][8] ; // iniSlider, iniKnob, finSlider, finKnob
int name = 0;
String instanceVideoFolder = ""+random(0, 1);
void saveVideo(){
  for (int i = 1; i<=frames; i++){ name++;
    currentI = src.get();
    for (int j = 0; j<8; j++){
      slider[j] = map(i,0,frames,videoCtrl[0][j],videoCtrl[2][j]);
      knob  [j] = map(i,0,frames,videoCtrl[1][j],videoCtrl[3][j]);
    }
    turing2(currentI); 
    image(currentI, 3*a+35+d, d );
    currentI.save("video/animation_"+instanceVideoFolder+"/"+name+".png");
  }
}
void keyPressed(){
  if ( keyCode == CONTROL) control = true;
  if (key == 'i') src.filter(INVERT);
  if (key == '+') src.resize(int(src.width+100),0);  if (key == '-') src.resize(int(src.width-100),0);
  if (key == 'v') { for (int i = 0; i<8; i++){ videoCtrl[0][i]=slider[i];  videoCtrl[1][i]=knob[i];  saved[i]=slider[i]+" "+knob[i] ; }              saveStrings( "video/animation_"+instanceVideoFolder+"/"+name+"-V.trm", saved); }
  if (key == 'b') { for (int i = 0; i<8; i++){ videoCtrl[2][i]=slider[i];  videoCtrl[3][i]=knob[i];  saved[i]=slider[i]+" "+knob[i] ; } saveVideo(); saveStrings( "video/animation_"+instanceVideoFolder+"/"+name+"-B.trm", saved); }
  if (key == 'a') {  selectFolder("Select a folder to process:", "folderSelected");  } 
}
ArrayList<File> filesList = new ArrayList<File>();

void folderSelected(File selection) {
  if (selection!=null) {

    File file = new File(selection.getAbsolutePath());
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
    currentI.save("video/video_"+folder+"/"+count+".png");

  }
}
void keyReleased()  { control = false; }
void mousePressed() { for (BiSlider o : bi){ o.pressed(); } di.pressed(); }
void mouseReleased(){ for (BiSlider o : bi){ o.released();} di.released(); }
void mouseMoved(){ di.mouved();  bi[0].mouved(); bi[1].mouved(); mapImg.mouved(); }
void mouseDragged(){ for (BiSlider o : bi) { o.dragged(); } di.dragged(); mapImg.dragged(); }

void fileSelected(File selection) { lastPath=selection.getAbsolutePath(); 
  src=loadImage(lastPath); 
  src.filter(GRAY);
  w=src.width;
  h=src.height;
  if(w>h) { srcMin = src.get(); srcMin.resize(a,0); }
  if(w<=h) { srcMin = src.get(); srcMin.resize(0,a); }
  //cp5.getController("largeur (px)").setText(src.width+"");
  fill(colorElemBg); rect(gauche,haut,2*a+a/2+b,a); // setup view
  mapImg.setup();
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
  for (BiSlider o : bi) { o.setup(); } di.setup();
  cp5.getController("iterations").setValue(slider[0]);
  if(seuilVisible) cp5.getController("threshold").setValue(slider[1]);
  map=true; turing2(di.mapImg); map=false;
  viewing = true ;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
boolean isOver ( float left, float right, float top, float bottom ) {
  if (mouseX > left && mouseX < right && mouseY > top && mouseY < bottom ) { return true; } else { return false; }
}
class MapImg {
  char over = 'n'; int x,y,mX,mY;
  MapImg (int tx, int ty){ y=ty; x=tx; mX=x+40; mY=y+40;}
  void mouved(){ 
    if ( isOver(x,x+srcMin.width,y,y+srcMin.height) ){ 
      over='a'; setup(); 
    }else if (over=='a') { 
      over='n'; setup(); 
      }  
    }
  void dragged(){
    if ( mouseX>x && mouseX<a+x && mouseY>y && mouseY<a+y && di.zone == 0 ) {  // pre-view position
      viewX = constrain( (mouseX-x)*w/srcMin.width -viewSize/2 ,0,w-viewSize-1) ; 
      viewY = constrain( (mouseY-y  )*h/srcMin.height-viewSize/2 ,0,h-viewSize-1) ;
      mX = mouseX ; 
      mY = mouseY ;
      setup();
      viewing = true ;
    } 
  }
  void setup(){
    image(srcMin, x, y);
    styleSelecStroke(); if(over=='a') stroke(colorActive); strokeWeight(2.5);
    rect(constrain( mX-viewSize*srcMin.width/w/2, x+1, x+srcMin.width-viewSize*srcMin.width/w -2), 
         constrain( mY-viewSize*srcMin.width/w/2,   y+1,   y+srcMin.height-viewSize*srcMin.width/w -2), 
        viewSize*srcMin.width/w, viewSize*srcMin.width/w
    );strokeWeight(1); noStroke();
  }
}

class Snap {
  String name; int ref, x, y, s, m, sh=20; float pos1, pos2, pos3, zone;
  String[][] snapVar = new String[20][8];
  PImage[] snap = new  PImage[6];
  Button[] snapButton = new Button[snap.length];
  Snap (int tx,int ty){ 
    x=tx; y=ty;
    for (int i = 0; i<snap.length; i++) {  
      snapButton[i] = cp5.addButton("snap"+i, 0, x+i%6*(a/2+b), y+floor(i/6)*(a/2+b), a/2, a/2).setId(i+16).setCaptionLabel(""); style1("snap" +i);
    }
  }
  void pressed (int off){
 // d+a/2+b,   a+a+a/2 +c+c+d 
    if(snap[off]==null && currentI!=null) {  // save snap
      snap[off] = currentI.get(); 
      for (int i = 0; i<8; i++){ snapVar[off][i] = slider[i]+" "+knob[i] ; } 
      PImage tmp1 = snap[off].get();
      tmp1.resize( srcMin.width/2, srcMin.height/2 );
      PImage tmp2 = snap[off].get( snap[off].width/2, snap[off].height/2, srcMin.width/2, srcMin.height/2 );
      snapButton[off].setImages(tmp1,tmp2,tmp1).hide().setSize(srcMin.width/2, srcMin.height/2).show() ;  
      fill(C[25]); rect( x+off%6*(a/2+b) , y+floor(off/6)*(a/2+b), a/2, a/2); 
    }
    if (snap[off]!=null) {  // load snap
      currentI = snap[off];
      image(currentI, 3*a+35+d, d ); // ,(currentI.width*(height-d))/currentI.height, height-d); 
      setParam(snapVar[off]);
    }      
  }
}
class BiSlider {
  String name; int ref, x, y, s, m, sh=20; float pos1, pos2, pos3, zone; char over;
  BiSlider(int tref, String tname,int tx,int ty, int ts){ 
    ref=tref; name=tname; x=tx+10; y=ty; s=ts-10;
    setup();
  }
    void mouved(){
    if      ( isOver(x+slider[ref]-18, x+slider[ref]+18, y, y+sh ) ) { over = 'b' ; setup(); }
    else if ( isOver(x+  knob[ref]-18, x+  knob[ref]+18, y+2*sh, y+3*sh ) ) { over = 'w' ; setup(); }
    else if ( isOver(x, x+s, y+sh, y+2*sh ) ) { over = 'a' ; setup(); }
    else { over= 'n'; setup(); }
  }
  void pressed (){
    if ( mouseX>x+slider[ref]-18 && mouseY>y                && mouseX<x+slider[ref]+18 && mouseY<y+sh              ) { zone=1; pos1=mouseX; }
    if ( mouseX>x+ knob [ref]-18 && mouseY>y+2*sh           && mouseX<x+ knob [ref]+18 && mouseY<y+3*sh            ) { zone=2; pos2=mouseX; }
    if ( mouseX>x                && mouseY>y+sh             && mouseX<x+s              && mouseY<y+2*sh            ) { zone=3; pos3=mouseX; }
  }  
  void released (){ 
    if (zone!=0) di.setupImg();
    zone=0;  
  }
  void dragged () {
    if ( zone!=0 ) {
      m   = mouseX ;
      off = (control) ? 20 : 1 ;
      if ( zone==1 ) { // top
        slider[ref] += (m-pos1)/off;    pos1=m; 
        slider[ref] = constrain(slider[ref], 0, s-10);
      }
      if ( zone==2 ) { // bottom
        knob[ref] += (m-pos2)/off;  pos2=m; 
        knob[ref] = constrain(knob[ref], 0, s-10);
      }
      if ( zone==3 ) { // center
        slider[ref] += (m-pos3)/off ;
        knob  [ref] += (m-pos3)/off ;
        slider[ref] = constrain(slider[ref], 0, s-10);
        knob  [ref] = constrain(knob  [ref], 0, s-10);
        pos3=m;
      }
      setup(); 
      viewing = true ;
    }
  } 
  void setup(){
    float sli = slider[ref]; float kno = knob[ref];
    pushMatrix(); translate(x, y); 
        fontColor(); text(name, 0 , -10); textAlign(CENTER);
        fill(colorElemBg); rect(-18,0,s+26,3*sh);  //bg
        fill(C[18]); rect(0,sh+3,s-10,sh-6); // bg slide
        fill(0); triangle(sli-18, sh-3, sli+18, sh-3, sli, sh+3); // top
        fill(255); triangle(kno-18, 2*sh+3, kno+18, 2*sh+3, kno, 2*sh-3); // bottom
        fill(C[15]); if(over=='b' || over=='a') fill(colorActive); rect(sli-18, 0,  36,sh-3); // top cursor box
        fill(C[15]); if(over=='w' || over=='a') fill(colorActive); rect(kno-18, 2*sh+3, 36,sh-3); // bottom
          fontColor(); 
        text(nfs(sli,0,1), sli, sh-3-4);
        text(nfs(kno,0,1), kno, 3*sh-4);
          fill(C[15]);
        if(sli<kno) image(gradInvert, sli, sh+3, kno-sli, sh-6);  
        if(sli>=kno)image(grad,       kno, sh+3, sli-kno, sh-6); 
    popMatrix(); textAlign(LEFT);
  }  
}

class DiSlider {
  int x, y, s; float pos1, pos2, pos3, pos11, pos22, pos33, zone ; PImage mapImg = createImage(100, 100, ARGB); char over = 'n' ;
  DiSlider(int tx,int ty, int ts){ 
    x=tx; y=ty; s=ts;
    setupImg();
  }
  void mouved(){
    if      ( isOver(x+slider[4]-10, x+slider[4]+10, y+map(slider[5],0,s,s,0)-10, y+map(slider[5],0,s,s,0)+10 ) ) { over = 'b' ; setup(); }
    else if ( isOver(x+  knob[4]-10, x+  knob[4]+10, y+map(  knob[5],0,s,s,0)-10, y+map(  knob[5],0,s,s,0)+10 ) ) { over = 'w' ; setup(); }
    else if ( isOver(x, x+s, y, y+s ) ) { over = 'a' ; setup(); }
    else { over= 'n'; setup(); }
  }
  void pressed (){
    if (      mouseX>x+slider[4]-10 && mouseY>y+map(slider[5],0,s,s,0)-10 && mouseX<x+slider[4]+10 && mouseY<y+map(slider[5],0,s,s,0)+10 ) { zone=1; pos1=mouseX; pos11=mouseY; }
    else if ( mouseX>x+ knob [4]-10 && mouseY>y+map( knob [5],0,s,s,0)-10 && mouseX<x+ knob [4]+10 && mouseY<y+map( knob [5],0,s,s,0)+10 ) { zone=2; pos2=mouseX; pos22=mouseY; }
    else if ( mouseX>x              && mouseY>y              && mouseX<x+s            && mouseY<y+s            ) { zone=3; pos1=mouseX; pos11=mouseY; pos2=mouseX; pos22=mouseY; }
  }  
  void released () { zone=0; 
  }
  void dragged () {
    float sli5 = s-slider[5]; float kno5 = s-knob[5];
    off = (control) ? 20 : 1 ;
    if ( zone==1 || zone==3 ) { // top black
      slider[4] += (mouseX-pos1)/off;    pos1=mouseX; 
      slider[5] -= (mouseY-pos11)/off;   pos11=mouseY; 
      slider[4] = constrain(slider[4], 0, s-20);
      slider[5] = constrain(slider[5], 0, s-20);
    }
    if ( zone==2 || zone==3 ) { // bottom white
      knob[4] += (mouseX-pos2)/off;  pos2=mouseX; 
      knob[5] -= (mouseY-pos22)/off; pos22=mouseY; 
      knob[4] = constrain(knob[4], 0, s-20);
      knob[5] = constrain(knob[5], 0, s-20);
    }
    if ( zone!=0 ) setup();
    viewing = true ;
  }
  void setupImg () { map=true; turing2(mapImg); map=false; setup();}
  void setup () {
    float sli5 = s-slider[5]; float kno5 = s-knob[5];  // invert 0->200 to 200->0
    pushMatrix(); translate(x, y);
      fill(C[25]); rect(-36,s,50,50 ); //bg clean
      fill(colorElemBg); rect(-20,0,s+40,s+40 ); //bg
      image(mapImg, 0,20,s-20,s-20);
      strokeWeight(5);
        stroke(C[12]); if(over=='b' || over=='a') stroke(colorActive); ellipse(slider[4], sli5, 15, 15);  // top
        stroke(C[12]); if(over=='w' || over=='a') stroke(colorActive); ellipse(knob  [4], kno5, 15, 15);  // bottom
      strokeWeight(1); noStroke();
      for (int i = 0; i<=20; i++){
        fill(255/20*i);
        ellipse(slider[4]+i*(knob[4]-slider[4])/20, sli5+i*(kno5-sli5)/20, 10,10);
      }
    popMatrix();
    setupSlider(4, "thickness", x, y+s+10, s-10);
    setupSlider(5, "brightness", x+s-10, y+s, s-10);
  } 
  void setupSlider(int ref, String name, int xx, int yy, int s){ int sh=15;
    float sli = slider[ref]; float kno = knob[ref];
    pushMatrix(); translate(xx, yy); if(ref==5)rotate(-PI/2);
    fontColor(); text(name, 0 , 50); 
    fill(C[18]); rect(0,0,s-10,sh-6); // bg slide
    if ( abs(sli-kno)<36 ) {
      float mid = (sli<kno) ? sli+(kno-sli)/2 : kno+(sli-kno)/2 ;
      if (sli<kno) { fill(0); triangle(mid, sh, mid-36, sh, sli, sh-6); fill(255); triangle(mid, sh, mid+36, sh, kno, sh-6); }
      if (sli>=kno) {fill(0); triangle(mid, sh, mid+36, sh, sli, sh-6); fill(255); triangle(mid, sh, mid-36, sh, kno, sh-6); }
        fill(C[18]);
      rect(mid, sh, -36,sh); rect(mid, sh, 36,sh); // cursor box

        fontColor(); textAlign(CENTER); 
      if(sli<kno){ text(nfs(sli,0,1), mid-18, 2*sh-4); text(nfs(kno,0,1), mid+18, 2*sh-4);
      } else {     text(nfs(sli,0,1), mid+18, 2*sh-4); text(nfs(kno,0,1), mid-18, 2*sh-4); }
      if(sli<kno) image (gradInvert, sli, 0, kno-sli, sh-6);  
      if(sli>=kno)image (grad,       kno, 0, sli-kno, sh-6); 
    } else {
      fill (0);   triangle ( sli-18, sh, sli+18, sh, sli, sh-6); // top
      fill (255); triangle ( kno-18, sh, kno+18, sh, kno, sh-6); // bottom
        fill(C[18]);
      rect ( sli-18, sh, 36,sh ); // cursor box
      rect ( kno-18, sh, 36,sh );
        fontColor(); textAlign(CENTER);
      text ( nfs(sli,0,1), sli, 2*sh-4);
      text ( nfs(kno,0,1), kno, 2*sh-4);
      if(sli<kno) image(gradInvert, sli, 0, kno-sli, sh-6);  
      if(sli>=kno)image(grad,       kno, 0, sli-kno, sh-6);        
    }
    popMatrix(); textAlign(LEFT);
  } 
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
color bg = #EDEDED;
color colorElemBg = color(210);
//color colorOver = color();
color colorActive = #ff7f09; //#fc3011; //fc622a;
color colorFont = #002645;
int a = 200, b = 5, c = 20, d = 10, haut = 60, gauche = 65;
void styleSelecStroke(){ stroke(C[15]); noFill(); }
void styleSelec(){ fill(C[15]); noStroke(); }
void fontColor(){ fill(#002666); }

void style1 (String theControllerName) { 
    println(theControllerName);
  ControlFont cFont = new ControlFont(font,12);
  cp5.getController(theControllerName).getCaptionLabel().setFont(cFont).toUpperCase(false);
  cp5.setControlFont(cFont);
  cp5.setColorValue(colorFont); 
  cp5.getController(theControllerName).setColorBackground(C[17]);
  if(theControllerName=="load"||theControllerName=="save"||theControllerName=="render") cp5.getController(theControllerName).setColorBackground(C[20]);
  cp5.getController(theControllerName).setColorCaptionLabel(colorFont);
  cp5.getController(theControllerName).setColorForeground(C[12]);
  cp5.getController(theControllerName).setColorActive(colorActive);
}

void style2 () {
  ControlFont cFont = new ControlFont(font,12);
  checkbox.getCaptionLabel().setFont(cFont).toUpperCase(false);
  checkbox.setColorBackground(C[18]);
  checkbox.setColorForeground(C[12]);
  checkbox.setColorActive(C[15]);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void fileToPrinter(String fileName) {
  try {
    ProcessBuilder pb = new ProcessBuilder("lpr", fileName);
    Process p = pb.start();
  } catch (IOException e) { println(e); }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////// reaction - diffusion /////////////// TURING

PImage turing2(PImage img) {
frame.setTitle ("TexTuring - computing ..." );  

int left, right, up, down, W = img.width, H = img.height;  float uvv, u, v;
float diffU, diffV, F, K; 
int[][] offsetW = new int[W][2], offsetH = new int[H][2];
float[][]  U = new float[W][H],  V = new float[W][H];
float[][] dU = new float[W][H], dV = new float[W][H];
float lapU, lapV;

  for (int i = 0; i < W; i++) {
    for (int j = 0; j < H; j++) {
      U[i][j] = 1.0;
      V[i][j] = 0.0;
    }
  }
  img.loadPixels();                  //  INITIALISATION
    float noiseZoom = 0.01;

    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {        
        U[i][j] = 0.8*(noise(i*noiseZoom,j*noiseZoom));
        V[i][j] = 0.45*(noise(i*noiseZoom,j*noiseZoom));
        //U[i][j] = random(0,0.5);
        //V[i][j] = random(0,0.25);
      }
    }  
  img.updatePixels();
  //Set up offsets
  for (int i=1; i < W-1; i++) { offsetW[i][0] = i-1; offsetW[i][1] = i+1; }
  for (int i=1; i < H-1; i++) { offsetH[i][0] = i-1; offsetH[i][1] = i+1; }
  offsetW[0][0] = W-1; offsetW[0][1] = 1; offsetW[W-1][0] = W-2; offsetW[W-1][1] = 0;
  offsetH[0][0] = H-1; offsetH[0][1] = 1; offsetH[H-1][0] = H-2; offsetH[H-1][1] = 0;

  //diffU = 0.16; diffV = 0.08; F = 0.035;  K = 0.06;

  float[][][] fkuv = new float[W][H][4];  // init param grid
  float[] maxi = { 0.15, 0.07, 0.1, 0.1 };
  int[] controlSize = { a, a, a, a };
  for (int i = 0; i<W; i++){
    for (int j = 0; j<H; j++){
      for (int k = 0; k<4; k++){
        if(map==false) {
          fkuv[i][j][k] = map( brightness(img.pixels[j*W+i]),0,255, 
            map(slider[k+4],0,controlSize[k],0,maxi[k]), 
            map(knob[k+4],0,controlSize[k],0,maxi[k]));
            //map(slider[k+4],0,controlSize[k],0,maxi[k]) + map(knob[k+4],0,controlSize[k],0,maxi[k]));
        } 
      }
      if(map==true) {
        fkuv[i][j][0] = map( i, 0, W, 0, maxi[0]);
        fkuv[i][j][1] = map( j, 0, W, maxi[1], 0);  
        fkuv[i][j][2] = map(slider[6],0,controlSize[2],0,maxi[2]);
        fkuv[i][j][3] = map(slider[7],0,controlSize[3],0,maxi[3]);
      }
    }
  }

  for (int n = 0; n<slider[0]*6+1; n++){  // reaction diffusion
    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {

        F = fkuv[i][j][0] ;
        K = fkuv[i][j][1] ;
        diffU = fkuv[i][j][2] ;
        diffV = fkuv[i][j][3] ;

        u = U[i][j];  
        v = V[i][j]; 
        left  = offsetW[i][0]; right = offsetW[i][1];
        up    = offsetH[j][0]; down  = offsetH[j][1];

        lapU = U[left][j] + U[right][j] + U[i][up] + U[i][down] - (u+u+u+u);
        lapV = V[left][j] + V[right][j] + V[i][up] + V[i][down] - (v+v+v+v);

        uvv = u*v*v;
        dU[i][j] = diffU*lapU  - uvv + F*(1 - u);
        dV[i][j] = diffV*lapV + uvv - (K+F)*v;
      }
    }
    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {
        U[i][j] += dU[i][j];
        V[i][j] += dV[i][j];
      }
    }
    frame.setTitle ("TexTuring - computing ["+int( (100*n)/(slider[0]*7))+"%]" );
  }
  
  img.loadPixels();
    int pShift,pShift2;
    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {
        pShift = int( U[i][j]*255 ) ;

        if(button[0] && pShift<slider[1]) { img.pixels[j*W+i] = color(0); } else { img.pixels[j*W+i] = color(255); }
        if(!button[0]) img.pixels[j*W+i] =  0xff000000 | (pShift << 16) | (pShift << 8) | pShift  ;
        if(map && pShift<slider[1]) { img.pixels[j*W+i] = C[18]; } else if(map){ img.pixels[j*W+i] = color(255); }

      }
    }
  img.updatePixels();
  //console.setText("").setColor(colorFont);
  frame.setTitle ("TexTuring" );
  return img;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 /*
void turing1() {
  generateInitialState();

  for (int i = 1; i < N-1; i++) {  //Set up offsets
    offset[i][0] = i-1;
    offset[i][1] = i+1;
  }
  offset[0][0] = N-1;   offset[0][1] = 1;  
  offset[N-1][0] = N-2; offset[N-1][1] = 0;

  diffU = map(slider[4],0,127,0,0.1); diffV = map(slider[5],0,127,0,0.1); F = map(slider[6],0,127,0,0.1); K = map(slider[7],0,127,0,0.1);
  diffU = 0.16; diffV = 0.08; 

  for (int n = 0; n<slider[0]*4+1; n++){
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
         
        u = U[i][j];  
        v = V[i][j]; 
        left  = offset[i][0];
        right = offset[i][1];
        up    = offset[j][0];
        down  = offset[j][1];
         
        uvv = u*v*v;    
        double lapU = (U[left][j] + U[right][j] + U[i][up] + U[i][down] - 4*u);
        double lapV = (V[left][j] + V[right][j] + V[i][up] + V[i][down] - 4*v);
         
        dU[i][j] = diffU*lapU  - uvv + F*(1 - u);
        dV[i][j] = diffV*lapV + uvv - (K+F)*v;
      }
    }
              
    for (int i= 0; i < N; i++) {
      for (int j = 0; j < N; j++){
          U[i][j] += dU[i][j];
          V[i][j] += dV[i][j];
      }
    }
  }

  loadPixels();
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        pixels[i*N+j] = color( (float)(U[i][j]*255) ) ;
      }
    }
  updatePixels();
}
 
void generateInitialState() {
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      U[i][j] = 1.0;
      V[i][j] = 0.0;
    }
  }
  src.loadPixels();
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {    
      switch (init) {
        case 0:    
          U[i][j] = 0.5*(1 + random(-1, 1));
          V[i][j] = 0.25*( 1 + random(-1, 1));
        break;
        case 1:
          U[i][j] = map(brightness(src.pixels[i*N+j]),0,255,1,0.5);
          V[i][j] = map(brightness(src.pixels[i*N+j]),0,255,0,0.25);
        break;
      }
    }
  }  
  src.updatePixels();
}
 
*/
