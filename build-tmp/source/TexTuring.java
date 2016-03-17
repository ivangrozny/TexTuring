import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import javax.swing.*; 
import java.awt.event.*; 
import java.awt.BorderLayout; 

import controlP5.*; 
import com.ibm.icu.impl.*; 
import com.ibm.icu.impl.data.*; 
import com.ibm.icu.lang.*; 
import com.ibm.icu.text.*; 
import com.ibm.icu.util.*; 
import org.doubletype.ossa.*; 
import org.doubletype.ossa.action.*; 
import org.doubletype.ossa.adapter.*; 
import org.doubletype.ossa.module.*; 
import org.doubletype.ossa.property.*; 
import org.doubletype.ossa.truetype.*; 
import org.doubletype.ossa.xml.*; 
import fontastic.*; 
import org.opencv.calib3d.*; 
import org.opencv.contrib.*; 
import org.opencv.core.*; 
import org.opencv.features2d.*; 
import org.opencv.highgui.*; 
import org.opencv.imgproc.*; 
import org.opencv.ml.*; 
import org.opencv.objdetect.*; 
import org.opencv.photo.*; 
import org.opencv.utils.*; 
import org.opencv.video.*; 
import gab.opencv.*; 
import com.google.typography.font.sfntly.data.*; 
import com.google.typography.font.sfntly.*; 
import com.google.typography.font.sfntly.math.*; 
import com.google.typography.font.sfntly.sample.sflint.*; 
import com.google.typography.font.sfntly.sample.sfntdump.*; 
import com.google.typography.font.sfntly.table.bitmap.*; 
import com.google.typography.font.sfntly.table.*; 
import com.google.typography.font.sfntly.table.core.*; 
import com.google.typography.font.sfntly.table.truetype.*; 
import com.google.typography.font.tools.conversion.eot.*; 
import com.google.typography.font.tools.conversion.woff.*; 
import com.google.typography.font.tools.fontinfo.*; 
import com.google.typography.font.tools.sfnttool.*; 
import com.google.typography.font.tools.subsetter.*; 
import themidibus.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TexTuring extends PApplet {




MapImg mapImg;
boolean control = false, live = true, map = false, viewing = false, greyScale = false;
PImage src, view, currentI, srcMin ;
int viewX, viewY,h,w, off, offX, offY, viewSize=100 ;
String lastPath ;

Parameters params = new Parameters();
ArrayList<GuiElement> elements = new ArrayList<GuiElement>();

public void setup() {
   //size(displayWidth, displayHeight);
  frameRate(15);
  setupGUI();
  
  params.loadFile( new File(dataPath("default.texturing")) );
  fileSelected( new File(dataPath("wiki.png")) );                        // file selected at TexTuring launch
  //selectInput("Select a file to process:", "fileSelected"); noLoop();  // file selector at TexTuring launch
}

public void draw() {
  if ( viewing ) preview() ;
}

class Parameters {
  float[] b = {0 ,0 ,0 ,0} ; // R&D black handle
  float[] w = {0 ,0 ,0 ,0} ; // R&D white handle
  int[]   o = {0, 0, 0} ; // iterations, threshold, resolution
  Parameters() {  }

  public void save(String _filePath){
    String[] saveData = new String[7];

    for (int i = 0; i<7; i++){ 
      if (i<4) saveData[i] = b[i]+" "+w[i] ; 
      if (i>3) saveData[i] = o[i-4]+"" ; 
    } 
    if ( match(_filePath, ".TexTuring") == null ) _filePath += ".TexTuring" ;
    saveStrings( _filePath, saveData) ;
  }

  public void loadFile( File _file ){ if(_file != null) load( loadStrings(_file.getAbsolutePath()) ); }
  public void saveFile( File _file ){ if(_file != null) save( _file.getAbsolutePath() ); }

  public void load( String[] _data ){
    for (int i = 0; i<4; i++) { 
      String[] tmp = split(_data[i]," "); 
      b[i] = PApplet.parseFloat( tmp[0] ); 
      w[i] = PApplet.parseFloat( tmp[1] ); 
    }
    o[0] = PApplet.parseInt(_data[4] );
    o[1] = PApplet.parseInt(_data[5] );
    o[2] = PApplet.parseInt(_data[6] );
    updateGui();
  }
  public void loadParameters( Parameters other ) {
    arrayCopy(other.b, b) ;
    arrayCopy(other.w, w) ;
    arrayCopy(other.o, o) ;
  }
  public void updateGui(){
    for (GuiElement elem : elements) {
      elem.update();
    }
    updateDiSliderImage();
    viewing = true ;
  }
}

public void buttonPressed( GuiElement _elem ){
    if ( _elem.name == "image file" ) { selectInput("Select your image", "fileSelected"); viewing = true ; } 
    if ( _elem.name == "export" ) { exportImage(); }       
    if ( _elem.name == "load" ) {     selectInput( "Select TexTuring settings file", "loadFile"); viewing = true ; } 
    if ( _elem.name == "save" ) {     selectOutput("Name your TexTuring settings file", "saveFile"); } 
    if ( _elem.name == "specimen" ) {  }
    if ( _elem.name == "render" ) { render(); }
    if ( _elem.name == "check threshold" ) { greyScale = !greyScale ; preview() ; }
}
public void loadFile( File _file ){ params.loadFile( _file ); }
public void saveFile( File _file ){ params.saveFile( _file ); }

public void preview(){
  //fill(C[25]); rect(a+b+d, d+haut, a/2, a/2); 
  view = src.get( viewX,viewY, viewSize, viewSize); turing2(view); 
  viewing = false ;
  imageMode(CENTER); image(view, gauche+srcMin.width+(a-srcMin.width+a+a/2)/2, haut+a/2); imageMode(CORNER);
}
public void render(){
  currentI = src.get();
  turing2(currentI); 
  image(currentI, 3*a+35+d, d ); // ,(currentI.width*(height-d))/currentI.height, height-d); 
}

public void exportImage() {
  JTextField wField = new JTextField(5); wField.setText(src.width+"");
  JTextField hField = new JTextField(5); hField.setText(src.height+"");
  JComboBox extField = new JComboBox( new DefaultComboBoxModel(new String[]{"PNG","SVG","GIF"}) );
  JFileChooser pathField = new JFileChooser(); 
  //pathField.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
//pathField.setFileFilter(new FileNameExtensionFilter("description", "png")); //  Cannot find a class or type named "FileNameExtensionFilter" ???

  JPanel p1 = new JPanel();
  p1.add(pathField);
  JPanel p2 = new JPanel();
  p2.add(extField);
  p2.add(Box.createHorizontalStrut(25)); p2.add(new JLabel("Pixels size :     width")); p2.add(wField);
  p2.add(Box.createHorizontalStrut(15)); p2.add(new JLabel("height")); p2.add(hField);
  JPanel outer = new JPanel(new BorderLayout());
  outer.add(p1, BorderLayout.NORTH);
  outer.add(p2, BorderLayout.CENTER);

  int result = JOptionPane.showConfirmDialog(null, outer, "Select export options", JOptionPane.OK_CANCEL_OPTION);
  if (result == JOptionPane.OK_OPTION) {
    System.out.println("x : " + wField.getText());
    System.out.println("y : " + hField.getText());
    System.out.println("ext: "+ extField.getSelectedItem());

    File file = pathField.getSelectedFile();
    String path = file.getAbsolutePath();
    if ( extField.getSelectedItem() == "PNG" ){
      render();  // (kevin) open a new thread to start render when options pop ?
      currentI.save( path + ".png" );
    }
  }
}
public void fileSelected(File selection) { lastPath=selection.getAbsolutePath(); 
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
public void saveSpecimen(File selection){ 
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

public void saveVideo(){
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
public void keyPressed(){
  if ( keyCode == CONTROL) control = true;
  if (key == 'i') src.filter(INVERT);
  if (key == '+') src.resize(PApplet.parseInt(src.width+100),0);  if (key == '-') src.resize(PApplet.parseInt(src.width-100),0);
//  if (key == 'v') { for (int i = 0; i<8; i++){ videoCtrl[0][i]=Slider[i];  videoCtrl[1][i]=wb[i];  saved[i]=Slider[i]+" "+wb[i] ; }              saveStrings( "video/animation_"+instanceVideoFolder+"/"+videoName+"-V.trm", saved); }
//  if (key == 'b') { for (int i = 0; i<8; i++){ videoCtrl[2][i]=Slider[i];  videoCtrl[3][i]=wb[i];  saved[i]=Slider[i]+" "+wb[i] ; } saveVideo(); saveStrings( "video/animation_"+instanceVideoFolder+"/"+videoName+"-B.trm", saved); }
  if (key == 'a') {  selectFolder("Select a folder to process:", "folderSelected");  } 
  if (key == 't') {for (int i = 0; i<3; i++){
    println("o[]: "+params.o[i]);
    println("b[]: "+params.b[i]);
  }}
}
public void keyReleased()  { 
  control = false; 
}
public void mousePressed() {
  for (GuiElement elem : elements) {
    if ( elem.isOver() ) {
      elem.pressed();
      return;
    }
  }
}
public void mouseDragged(){  mapImg.dragged(); 
  for (GuiElement elem : elements) {
    elem.dragged();
  }
}
public void mouseMoved(){   mapImg.mouved(); 
  for (GuiElement elem : elements) {
    elem.mouved();
  }
}
public void mouseReleased(){
  for (GuiElement elem : elements) {
    elem.released();
  }
}
public void updateDiSliderImage() {
  for (GuiElement elem : elements) {
    map=true; elem.updateImg(); map=false;
  }
}
//////////////////////////////////////////////// reaction - diffusion /////////////// TURING

public PImage turing2(PImage img) {
surface.setTitle ("TexTuring - computing ..." );  

int left, right, up, down, W = img.width, H = img.height;  float uvv, u, v;
float diffU, diffV, F, K; 
int[][] offsetW = new int[W][2], offsetH = new int[H][2];
float[][]  U = new float[W][H],  V = new float[W][H];
float[][] dU = new float[W][H], dV = new float[W][H];
float lapU, lapV;

  for (int i = 0; i < W; i++) {
    for (int j = 0; j < H; j++) {
      U[i][j] = 1.0f;
      V[i][j] = 0.0f;
    }
  }
  img.loadPixels();                  //  INITIALISATION
    float noiseZoom = 0.01f;

    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {        
        U[i][j] = 0.8f *( noise(i*noiseZoom,j*noiseZoom) );
        V[i][j] = 0.45f*( noise(i*noiseZoom,j*noiseZoom) );
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
  float[] maxi = { 0.15f, 0.07f, 0.1f, 0.1f };
  int[] controlSize = { a, a, a, a };
  for (int i = 0; i<W; i++){
    for (int j = 0; j<H; j++){
      for (int k = 0; k<4; k++){
        if(map==false) {
          fkuv[i][j][k] = map( brightness(img.pixels[j*W+i]),0,255, 
            map(params.b[k],0,controlSize[k],0,maxi[k]), 
            map(params.w[k],0,controlSize[k],0,maxi[k]));
            //map(Slider[k+4],0,controlSize[k],0,maxi[k]) + map(wb[k+4],0,controlSize[k],0,maxi[k]));
        } 
      }
      if(map==true) {
        fkuv[i][j][0] = map( i, 0, W, 0, maxi[0]);
        fkuv[i][j][1] = map( j, 0, W, maxi[1], 0);  
        fkuv[i][j][2] = map(params.b[2],0,controlSize[2],0,maxi[2]);
        fkuv[i][j][3] = map(params.w[3],0,controlSize[3],0,maxi[3]);
      }
    }
  }

  for (int n = 0; n< params.o[0] * 6 +1 ; n++){  // reaction diffusion
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
    surface.setTitle ("TexTuring - computing ["+PApplet.parseInt( (100*n)/(params.o[0]*7+1))+"%]" );
  }
  
  img.loadPixels();
    int pShift,pShift2;
    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {
        pShift = PApplet.parseInt( U[i][j]*255 ) ;

        if( !greyScale && pShift<params.o[1] ) { img.pixels[j*W+i] = color(0); } else { img.pixels[j*W+i] = color(255); }
        if( greyScale ) img.pixels[j*W+i] =  0xff000000 | (pShift << 16) | (pShift << 8) | pShift  ;
        if( map && pShift<params.o[1] ) { img.pixels[j*W+i] = C[18]; } else if(map){ img.pixels[j*W+i] = color(255); }

      }
    }
  img.updatePixels();
  //console.setText("").setColor(colorFont);
  surface.setTitle ("TexTuring" );
  return img;
}
class GuiElement {
  Rect coords;
  String name;
  int ref;
  boolean isOver = false;
  boolean isVisible = true;

  GuiElement(){
    coords = new Rect();
  }
  GuiElement(Rect _coords, String _name){
    coords = _coords;
    name = _name;
    if (name=="iterations") ref = 0 ;
    if (name=="threshold") ref = 1 ;
    if (name=="reaction") ref = 2 ;
    if (name=="diffusion") ref = 3 ;
  }

  public boolean isOver() {
    return coords.isOver(mouseX, mouseY);
  }

  public void update() {  }
  //callbacks for injecting events
  public void updateImg() {  }   //// only for DiSlider
  public void mouved() { update(); }
  public void pressed() {  }
  public void released() {  }
  public void dragged() {  }
  //helpers to uniformize ways of drawings things
  public void drawRect( Rect r) {
     rect(r.pos.x, r.pos.y,r.size.x,r.size.y); 
  }
  public void drawText( Rect r, String text) {
     text(text, coords.pos.x + 5, coords.pos.y);
  }
}

class Menu extends GuiElement {

String[] names;
Rect zone;
  Menu(Rect _coords, String[] _names) { 
    super(_coords, _names[0]);
    names = new String[_names.length];
    arrayCopy( _names, names );
    for (int i = 1; i<names.length; i++){
      Rect _rect = new Rect( coords );
      _rect.pos.y += coords.size.y * i ;
      elements.add(new Button(_rect, names[i] ));
    }
    zone = new Rect( coords );
    zone.size.y = coords.size.y * names.length ;
    update();
  }
  public void update(){ 
    fill( isOver() ? C[14] : C[15] ); 
    drawRect(coords);
    fill(colorFont); 
    text(name, coords.pos.x + 5, coords.pos.y + 15);
    for (int i = 1; i<names.length; i++){
      for (GuiElement _elem : elements) {
        if ( _elem.name == names[i] ){
          if ( isOver() ) _elem.isVisible = true ;
          if ( !zone.isOver() ) _elem.isVisible = false ;
        }
      }
    }
  }
  public void pressed() {
    buttonPressed( this );
  }
}

class Button extends GuiElement {
  
  Button(Rect _coords, String _name) { 
    super(_coords, _name);
    update();
  }
  public void update(){
    if (isVisible){
      fill( isOver() ? C[12] : C[17] ); 
      drawRect(coords);
      fill(colorFont); 
      text(name, coords.pos.x + 5, coords.pos.y + 15);
    }else{      
      fill(C[25]); 
      drawRect(coords);
    }
  }
  public void pressed() {
    buttonPressed( this );
  }
}

class CheckBox extends GuiElement {
  boolean b = false;
  CheckBox(Rect _coords, String _name) { 
    super(_coords, _name);
    update();
  }
  public void update(){
    fill( isOver() ? C[12] : C[17] ); 
    drawRect(coords);
    fill( b ? C[0] : C[10] ); 
    rect(coords.pos.x+3, coords.pos.y+3, coords.size.x-6, coords.size.y-6);
  }
  public void pressed() {
    buttonPressed( this );
    b = !b ;
  }
}

class Slider extends GuiElement {
  int range; 
  float pos; 
  boolean press = false;
  
  Slider(Rect _coords, String _name, int _range){ 
    super(_coords, _name);
    range = _range;
    update();
  }
  public void pressed (){
    press = true; 
    pos = mouseX;
  }
  public void released (){ 
    if (press) updateDiSliderImage();
    press = false;  
  }
  public void dragged () {
    if ( press ) {
      int off = (control) ? 20 : 1 ;
      int m = mouseX ;
      params.o[ref] = (int)constrain(params.o[ref] + map(m-pos,0,w,0,range)/off , 0, range);
      pos = m; 
      update(); 
      viewing = true ; 
    }
  }
  public void update(){
    float b = params.o[ref]*w/range;
    Vector2 s = new Vector2(coords.size);

    fill( isOver() ? C[12] : C[17] ); 
    drawRect(coords);
    pushMatrix(); translate(coords.pos.x, coords.pos.y);
        fill(C[15]); rect(0, 3, b, s.y-6); // Slider
        fill(colorFont); 
        text(name, 0 , -10);
        text(nfs(b,0,1), b, s.y-3-4);  // number display
    popMatrix();
  }  
}

class MapImg {
  char over = 'n'; int x,y,mX,mY;
  MapImg (int tx, int ty){ y=ty; x=tx; mX=x+40; mY=y+40;}
  public void mouved(){ 
    if ( isOver(x, y, srcMin.width, srcMin.height) ){ 
      over='a'; update(); 
    }else if (over=='a') { 
      over='n'; update(); 
      }  
    }
  public void dragged(){
    if ( mouseX>x && mouseX<a+x && mouseY>y && mouseY<a+y ) {  // pre-view position
      viewX = constrain( (mouseX-x)*w/srcMin.width -viewSize/2 ,0,w-viewSize-1) ; 
      viewY = constrain( (mouseY-y)*h/srcMin.height-viewSize/2 ,0,h-viewSize-1) ;
      mX = mouseX ; 
      mY = mouseY ;
      update();
      viewing = true ;
    } 
  }
  public void update(){
    image(srcMin, x, y);
    styleSelecStroke(); if(over=='a') stroke(colorActive); strokeWeight(2.5f);
    rect(constrain( mX-viewSize*srcMin.width/w/2, x+1, x+srcMin.width-viewSize*srcMin.width/w -2), 
         constrain( mY-viewSize*srcMin.width/w/2,   y+1,   y+srcMin.height-viewSize*srcMin.width/w -2), 
        viewSize*srcMin.width/w, viewSize*srcMin.width/w
    ); strokeWeight(1); noStroke();
  }
}

class Snap extends GuiElement {
  PImage snap, tmp1, tmp2;
  Parameters savedParams = new Parameters();

  Snap (Rect _coords, String _name) { 
    super(_coords, _name);
    update();
  }
  public void pressed (){
    if(snap==null && currentI!=null) {  // save snap
      savedParams.loadParameters( params );

      snap = currentI.get(); 
      tmp1 = snap.get();
      tmp1.resize( srcMin.width/2, srcMin.height/2 );
      tmp2 = snap.get( snap.width/2, snap.height/2, srcMin.width/2, srcMin.height/2 );
      fill(C[25]); drawRect(coords);
    }
    if (snap!=null) {  // load snap
      params.loadParameters( savedParams );
      params.updateGui();
      currentI = snap;
      image(currentI, 3*a+35+d, d ); // draw view
    }      
    viewing = true ;
    // TODO : delete snap function
  }
  public void update(){
    if(snap==null){
      fill( isOver() ? C[12] : C[17] ); 
      drawRect(coords);
    }else{
      PImage off = isOver() ? tmp2 : tmp1 ; 
      image(off, coords.pos.x, coords.pos.y);
    }
  }
}

class BiSlider extends GuiElement {
  int m, sh=20; 
  float pos1, pos2, pos3, zone; 
  Rect handle[] = new Rect[3];
  PImage grad, gradInvert;

  BiSlider(Rect _coords, String _name){
    super(_coords, _name);
    grad = loadImage("gradient.png"); gradInvert = loadImage("gradInvert.png");
    update();
  }

  public void pressed (){
    if ( handle[0].isOver() ) { zone=1; pos1=mouseX; } // top
    if ( handle[1].isOver() ) { zone=2; pos2=mouseX; } // bottom
    if ( handle[2].isOver() ) { zone=3; pos3=mouseX; } // center
  }
  public void released (){ 
    if ( zone!=0 ) updateDiSliderImage();
    zone = 0;  
  }
  public void dragged () {
    if ( zone!=0 ) {
      m   = mouseX ;
      off = (control) ? 20 : 1 ;
      if ( zone==1 ) { // top
        params.b[ref] += (m-pos1)/off;    pos1=m; 
        params.b[ref] = constrain(params.b[ref], 0, coords.size.x-10);
      }
      if ( zone==2 ) { // bottom
        params.w[ref] += (m-pos2)/off;  pos2=m; 
        params.w[ref] = constrain(params.w[ref], 0, coords.size.x-10);
      }
      if ( zone==3 ) { // center
        params.b[ref] += (m-pos3)/off ;
        params.w[ref] += (m-pos3)/off ;
        params.b[ref] = constrain(params.b[ref], 0, coords.size.x-10);
        params.w[ref] = constrain(params.w[ref], 0, coords.size.x-10);
        pos3 = m;
      }
      update(); 
      viewing = true ;
    }
  } 
  public void update(){
    float b = params.b[ref]; 
    float w = params.w[ref];
    handle[0] = new Rect( coords.pos.x+b-18, coords.pos.y+0,  36, sh-3 );
    handle[1] = new Rect( coords.pos.x+w-18, coords.pos.y+2*sh+3, 36, sh-3 );
    handle[2] = new Rect( coords.pos.x, coords.pos.y+sh+3, coords.size.x-10, sh-6 );
    fill(colorElemBg); rect(coords.pos.x-18,coords.pos.y,coords.size.x+26,3*sh);  //bg
    fill(handle[2].isOver() ? C[18] : C[20] ); drawRect(handle[2]); // bg bde
    fill(C[15]); if (handle[0].isOver() || handle[2].isOver()) fill(colorActive); drawRect(handle[0]); // top cursor box
    fill(C[15]); if (handle[1].isOver() || handle[2].isOver()) fill(colorActive); drawRect(handle[1]); // bottom
    pushMatrix(); translate(coords.pos.x, coords.pos.y); 
        fontColor(); text(name, 0 , -10); textAlign(CENTER);
        fill(0); triangle(b-18, sh-3, b+18, sh-3, b, sh+3); // top
        fill(255); triangle(w-18, 2*sh+3, w+18, 2*sh+3, w, 2*sh-3); // bottom
        fontColor(); 
        text(nfs(b,0,1), b, sh-3-4);
        text(nfs(w,0,1), w, 3*sh-4);
          fill(C[15]);
        if(b<w) image(gradInvert, b, sh+3, w-b, sh-6);  
        if(b>=w)image(grad,       w, sh+3, b-w, sh-6); 
    popMatrix(); textAlign(LEFT);
  }  
}

class DiSlider extends GuiElement { 
  Rect handle[] = new Rect[2];
  float pos1, pos2, pos3, pos11, pos22, pos33, zone ; 
  PImage mapImg = createImage(100, 100, ARGB); 
  PImage grad, gradInvert;
  String name2;

  DiSlider(Rect _coords, String _name, String _name2){ 
    super(_coords, _name);
    name2 = _name2;
    grad = loadImage("gradient.png"); gradInvert = loadImage("gradInvert.png");
    updateImg();
  }
  public void pressed (){
    if ( coords.isOver() )    { zone=3; pos1=mouseX; pos11=mouseY; pos2=mouseX; pos22=mouseY; } // center
    if ( handle[0].isOver() ) { zone=1; pos1=mouseX; pos11=mouseY; } // top
    if ( handle[1].isOver() ) { zone=2; pos2=mouseX; pos22=mouseY; } // bottom
  }  
  public void released () { 
    zone = 0; 
  }
  public void dragged () {
    float b5 = coords.size.x-params.b[1]; float w5 = coords.size.x-params.w[1];
    off = (control) ? 20 : 1 ;
    if ( zone==1 || zone==3 ) { // top black
      params.b[0] += (mouseX-pos1)/off;    pos1=mouseX; 
      params.b[1] -= (mouseY-pos11)/off;   pos11=mouseY; 
      params.b[0] = constrain(params.b[0], 0, coords.size.x-20);
      params.b[1] = constrain(params.b[1], 0, coords.size.x-20);
    }
    if ( zone==2 || zone==3 ) { // bottom white
      params.w[0] += (mouseX-pos2)/off;  pos2=mouseX; 
      params.w[1] -= (mouseY-pos22)/off; pos22=mouseY; 
      params.w[0] = constrain(params.w[0], 0, coords.size.x-20);
      params.w[1] = constrain(params.w[1], 0, coords.size.x-20);
    }
    if ( zone!=0 ) update();
    viewing = true ;
  }
  public void updateImg () { map=true; turing2(mapImg); map=false; update();}
  public void update () {
    float x=coords.pos.x, y=coords.pos.y, s=coords.size.x, sh=coords.size.y ;
    
    handle[0] = new Rect( x+params.b[0]-10, y+map(params.b[1],0,s,s,0)-10, 20, 20 );
    handle[1] = new Rect( x+  params.w[0]-10, y+map(  params.w[1],0,s,s,0)-10, 20, 20 );
    float b5 = s-params.b[1]; float w5 = s-params.w[1];  // invert 0->200 to 200->0

    pushMatrix(); translate(x, y);
      fill(C[25]); rect(-36,s,50,50 ); //bg cleaner //// utile?
      fill(colorElemBg); rect(-20,0,s+40,s+40 ); //bg
      image(mapImg, 0,20,s-20,s-20);
      strokeWeight(5);
        stroke(C[12]); if (handle[0].isOver() && coords.isOver()) stroke(colorActive); ellipse(params.b[0], b5, 15, 15);  // top
        stroke(C[12]); if (handle[1].isOver() && coords.isOver()) stroke(colorActive); ellipse(params.w[0], w5, 15, 15);  // bottom
      strokeWeight(1); noStroke();
      for (int i = 0; i<=20; i++){
        fill(255/20*i);
        ellipse(params.b[0]+i*(params.w[0]-params.b[0])/20, b5+i*(w5-b5)/20, 10,10);
      }
    popMatrix();
    setupSlider(0, name, x, y+s+10, s-10);
    setupSlider(1, name2, x+s-10, y+s, s-10);
  } 
  public void setupSlider(int ref, String name, float xx, float yy, float s){ 
    int sh=15;
    float b = params.b[ref]; float w = params.w[ref];
    pushMatrix(); translate(xx, yy); 
    if(ref==1)rotate(-PI/2);
    fontColor(); text(name, 0 , 50); 
    fill(C[18]); rect(0,0,s-10,sh-6); // bg bde
    if ( abs(b-w)<36 ) {
      float mid = (b<w) ? b+(w-b)/2 : w+(b-w)/2 ;
      if (b<w) { fill(0); triangle(mid, sh, mid-36, sh, b, sh-6); fill(255); triangle(mid, sh, mid+36, sh, w, sh-6); }
      if (b>=w) {fill(0); triangle(mid, sh, mid+36, sh, b, sh-6); fill(255); triangle(mid, sh, mid-36, sh, w, sh-6); }
        fill(C[18]);
      rect(mid, sh, -36,sh); rect(mid, sh, 36,sh); // cursor box

        fontColor(); textAlign(CENTER); 
      if(b<w){ text(nfs(b,0,1), mid-18, 2*sh-4); text(nfs(w,0,1), mid+18, 2*sh-4);
      } else {     text(nfs(b,0,1), mid+18, 2*sh-4); text(nfs(w,0,1), mid-18, 2*sh-4); }
      if(b<w) image (gradInvert, b, 0, w-b, sh-6);  
      if(b>=w)image (grad,       w, 0, b-w, sh-6); 
    } else {
      fill (0);   triangle ( b-18, sh, b+18, sh, b, sh-6); // top
      fill (255); triangle ( w-18, sh, w+18, sh, w, sh-6); // bottom
        fill(C[18]);
      rect ( b-18, sh, 36,sh ); // cursor box
      rect ( w-18, sh, 36,sh );
        fontColor(); textAlign(CENTER);
      text ( nfs(b,0,1), b, 2*sh-4);
      text ( nfs(w,0,1), w, 2*sh-4);
      if(b<w) image(gradInvert, b, 0, w-b, sh-6);  
      if(b>=w)image(grad,       w, 0, b-w, sh-6);        
    }
    popMatrix(); textAlign(LEFT);
  } 
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
PFont font;
int[] C = new int[26];
int bg = 0xffEDEDED;
int colorElemBg = color(210);
//color colorOver = color();
int colorActive = 0xffff7f09; //#fc3011; //fc622a;
int colorFont = 0xff002645;
int a = 200, b = 5, c = 20, d = 10, haut = 60, gauche = 65;
public void styleSelecStroke(){ stroke(C[15]); noFill(); }
public void styleSelec(){ fill(C[15]); noStroke(); }
public void fontColor(){ fill(0xff002666); }

public void setupGUI(){
  try { UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
  } catch (Exception e) { e.printStackTrace(); }
  for (int i = 0; i<=25; i++){ colorMode(HSB); C[i] = color(122,270-i*13,100+i*5); } // create UI color shades
  background(C[25]); noStroke();
  font = loadFont("FedraTwelve-Normal-12.vlw");  textFont(font, 12);

  //frame.setIconImage( getToolkit().getImage("icone.ico") ); 
  //if (frame != null) { frame.setResizable(true) ;}
  
  elements.add(new Menu(new Rect( d    , d, 100+5, 20       ), new String[]{ "open", "image file", "images folder" } ));
  elements.add(new Button(new Rect( d+110, d, 100+5, 20       ), "export"));
  elements.add(new Button(new Rect( d+220, d, 100+5, 20       ), "load"));
  elements.add(new Button(new Rect( d+330, d, 95,    20       ), "save"));
  elements.add(new Button(new Rect( d+430, d, a/2-b, 20       ), "specimen"));
  elements.add(new Button(new Rect( d+a+a+a/2+30, d, a/2-b, 20), "render"));
  elements.add(new   Slider(new Rect( gauche,  haut+a+c+15, a+20, 20), "iterations", 2000));  

  elements.add(new CheckBox(new Rect( gauche,  haut+a+c+65, 20, 20), "check threshold"));  
  elements.add(new   Slider(new Rect( gauche+25,  haut+a+c+65, a-5, 20), "threshold", 255));  
  elements.add(new BiSlider(new Rect( gauche-10, haut+a+c+150, a+20 , 60), "reaction"));
  elements.add(new BiSlider(new Rect( gauche-10, haut+a+c+a+a/2-60, a+20, 60), "diffusion"));
  elements.add(new DiSlider(new Rect( gauche+a+80+b, haut+a+c+10, a+20, a+20), "thickness", "brightness"));
  for (int i = 0; i<6; i++) {  
    elements.add(new Snap( new Rect( d+i%6*(a/2+b), height-d-a/2+floor(i/6)*(a/2+b), a/2, a/2 ) , "snap"+i ));  
  }

  mapImg = new MapImg(gauche, haut);
}


class Vector2
{
  float x, y;
  Vector2(float _x, float _y) {
    x=_x;
    y=_y;
  }
  Vector2() {
    x=0;
    y=0;
  }
  Vector2(Vector2 other) {
    this(other.x, other.y);
  }
}

class Rect
{
  Vector2 pos;
  Vector2 size;
  Rect() {
    pos = new Vector2();
    size = new Vector2();
  }
  Rect(Rect other) {
   this(other.pos, other.size);
  }
  Rect(Vector2 _pos, Vector2 _size) {
    pos = new Vector2(_pos);
    size = new Vector2(_size);
  }
  Rect(float posX, float posY, float sizeX, float sizeY) {
    pos = new Vector2(posX, posY);
    size = new Vector2(sizeX, sizeY);
  }
  public boolean isOver() {
   return isOver(new Vector2(mouseX,mouseY));
  }
  public boolean isOver(float x, float y) {
   return isOver(new Vector2(x,y));
  }
  public boolean isOver(Vector2 in) {
    if (in.x >= pos.x && in.x <= pos.x+size.x && in.y >= pos.y && in.y <= pos.y+size.y) {
      return true ;
    } else {
      return false ;
    }
  }
}


/////////////////////////////////////////////////////////////////////////////////

public boolean isOver (float x, float y, float w, float h) {
  if (mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h) { return true ; }
  else { return false ; }
}
  public void settings() {  size(1350, 720); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TexTuring" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
