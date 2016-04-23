import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import javax.swing.*; 
import java.awt.event.*; 
import java.awt.BorderLayout; 
import java.awt.image.BufferedImage; 
import java.awt.*; 
import java.awt.event.ActionEvent; 
import java.awt.event.ActionListener; 
import java.awt.geom.GeneralPath; 
import java.awt.geom.Point2D; 
import java.awt.image.BufferedImage; 
import java.awt.image.WritableRaster; 
import java.io.*; 
import java.io.Writer; 
import java.io.OutputStreamWriter; 
import java.io.File; 
import java.io.IOException; 
import java.util.*; 
import org.apache.batik.svggen.SVGGraphics2D; 
import org.apache.batik.dom.GenericDOMImplementation; 
import org.w3c.dom.Document; 
import org.w3c.dom.DOMImplementation; 

import org.imgscalr.*; 
import compat.*; 
import potracej.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TexTuring extends PApplet {






boolean control = false, live = true, updateDiSliderImage = false, viewing = false, threshold = true;
boolean synchroScroll = false;
PImage src ;
int h,w, off, offX, offY, viewSize=100 ;
float lastRenderTime;

String lastPath ;
File lastDirectory = null;

GuiWindow gui ;
Parameters params ;

public void setup() {
   //size(displayWidth, displayHeight);
  frameRate(20);
  gui = new GuiWindow();
  params = new Parameters();
  gui.setupGui();
  fileSelected( new File(dataPath("wiki.png")) );                        // file selected at TexTuring launch
  //selectInput("Select a file to process:", "fileSelected");            // file selector at TexTuring launch
  params.loadFile( new File(dataPath("default.texturing")) );
  
  //frame.setIconImage( getToolkit().getImage("icone.ico") ); 
  //if (frame != null) { frame.setResizable(true) ;}
}

public void draw() {
 if ( viewing )       gui.elements.get(0).update() ;
 if ( synchroScroll ) gui.elements.get(0).dragged();

 if (pmouseX!=mouseX || pmouseY!=mouseY) gui.injectMouseMoved  ();
 if ((pmouseX!=mouseX || pmouseY!=mouseY) && mousePressed) gui.injectMouseDragged ();
}

public void mousePressed (){ gui.injectMousePressed (); }
public void mouseReleased(){ gui.injectMouseReleased(); }
public void mouseWheel(processing.event.MouseEvent event) { gui.injectMouseWheel(event.getCount()); }

public PImage render(PImage imageIn, int widthOut ){
  PImage image = imageIn.get();
  int imgWidth = (int)params.o[2]*image.width/100; if (imgWidth<5) imgWidth = 5;
  image.resize(imgWidth, 0 );
  turing2(image);
  
  //image.resize( widthOut, 0 );  // may be faster but uglyer (blobs not perfectly round)
  BufferedImage scaledImg = Scalr.resize( (BufferedImage) image.getNative(), widthOut);  // load PImage to bufferImage
  image = new PImage(scaledImg);

  if (threshold) image.filter(THRESHOLD, map(params.o[1],0,255,0,1) );
  return image ;
}

public void exportImage() {
  JTextField nameField = new JTextField(12); nameField.setText( "export-"+PApplet.parseInt(random(9999)) );
  JTextField sizeField = new JTextField(5); sizeField.setText( ""+(int) params.o[2]*src.width/100 );
  JComboBox extField = new JComboBox( new DefaultComboBoxModel(new String[]{".png",".svg",".gif"}) );
  JFileChooser pathField = new JFileChooser();

  if (lastDirectory != null) pathField.setCurrentDirectory( lastDirectory ); 
  pathField.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);

  JPanel p1 = new JPanel(); p1.add(pathField);
  JPanel p2 = new JPanel(); 
  p2.add(new JLabel("Image name : ")); p2.add(nameField);
  p2.add(extField);
  p2.add(Box.createHorizontalStrut(30)); p2.add(new JLabel("Image width: ")); p2.add(sizeField); p2.add(new JLabel(" pixels"));
  JPanel outer = new JPanel(new BorderLayout());
  outer.add(p1, BorderLayout.NORTH);
  outer.add(p2, BorderLayout.CENTER);

  int result = JOptionPane.showConfirmDialog(null, outer, "Select export options", JOptionPane.OK_CANCEL_OPTION);
  if (result == JOptionPane.OK_OPTION) {
    println( pathField.getCurrentDirectory()  );

    lastDirectory = pathField.getCurrentDirectory();
    String path = pathField.getCurrentDirectory() + File.separator + nameField.getText() + extField.getSelectedItem() ;  
    println("path: "+ path );

    // (kevin) open a new thread to start render when options pop ?
    switch ( extField.getSelectedItem()+"" ) {
      case ".png" : 
      //image(render(src, int(sizeField.getText()) ),0,0);
      render(src, PApplet.parseInt(sizeField.getText()) ).save( path ); 
      break;
      case ".svg" : svgConverter( render(src, PApplet.parseInt(sizeField.getText()) ), 1, path ); break;  
    }

  }
}

public void fileSelected(File selection) { 
  lastPath = selection.getAbsolutePath(); 
  PImage tmp = loadImage(lastPath);
  tmp.filter(GRAY);
  src = createImage(tmp.width, tmp.height, ALPHA);
  src.copy(tmp,0,0,src.width, src.height,0,0,src.width, src.height);
  w = src.width;
  h = src.height;
  gui.update();
  viewing = true ; 
}

public void saveSpecimen(File selection){ 
  //for (int i = 0; i<8; i++){ saved[i] = Slider[i]+" "+wb[i] ; } 
  //saveStrings( selection.getAbsolutePath()+".trm", saved) ;
  //render(); 
  //currentI.save(selection.getAbsolutePath()+".png"); 
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
}

public void keyReleased()  { 
  control = false; 
}
//////////////////////////////////////////////// reaction - diffusion /////////////// TURING
//////////////////////////////////////////////// reaction - diffusion /////////////// TURING

public PImage turing2(PImage img) {
surface.setTitle ("TexTuring - computing ..." );  
float time = millis();
int left, right, up, down, W = img.width, H = img.height;  float uvv, u, v;
float diffU, diffV, F, K; 
int[][] offsetW = new int[W][2], offsetH = new int[H][2];
float[][]  U = new float[W][H],  V = new float[W][H];
float[][] dU = new float[W][H], dV = new float[W][H];
float lapU, lapV;

    //  INITIALISATION

    float noiseZoom = 0.20f;
    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {        
        U[i][j] = 0.15f * noise( i*noiseZoom, j*noiseZoom, i*0.06f) ;
        V[i][j] = 0.7f *  noise( i*noiseZoom, j*noiseZoom, i*0.06f) ;
      }
    }  
  
  //Set up offsets
  for (int i=1; i < W-1; i++) { offsetW[i][0] = i-1; offsetW[i][1] = i+1; }
  for (int i=1; i < H-1; i++) { offsetH[i][0] = i-1; offsetH[i][1] = i+1; }
  offsetW[0][0] = W-1; offsetW[0][1] = 1; offsetW[W-1][0] = W-2; offsetW[W-1][1] = 0;
  offsetH[0][0] = H-1; offsetH[0][1] = 1; offsetH[H-1][0] = H-2; offsetH[H-1][1] = 0;

  //diffU = 0.16; diffV = 0.08; F = 0.035;  K = 0.06;

  float[][][] fkuv = new float[W][H][4];  // init param grid
  float[] maxi = { 0.18f, 0.07f, 0.1f, 0.1f };  // F, K, diffU, diffV
  int[] controlSize = { a, a, a, a };
  for (int i = 0; i<W; i++){
    for (int j = 0; j<H; j++){

      for (int k = 0; k<4; k++){
        if ( updateDiSliderImage == false ) {
          fkuv[i][j][k] = map( brightness(img.pixels[j*W+i]),0,255, 
            map(params.b[k],0,controlSize[k],0,maxi[k]), 
            map(params.w[k],0,controlSize[k],0,maxi[k]));
        } 
      }
      if ( updateDiSliderImage == true) {
        fkuv[i][j][0] = map( i, 0, W, 0, maxi[0] );
        fkuv[i][j][1] = map( j, 0, W, maxi[1], 0);  
        fkuv[i][j][2] = map(params.b[2],0,controlSize[2],0,maxi[2]);
        fkuv[i][j][3] = map(params.w[3],0,controlSize[3],0,maxi[3]);
      }
    }
  }


  for (int n = 0; n< params.o[0] ; ++n){ 
    for (int i = 0; i < W; ++i) {
      for (int j = 0; j < H; ++j) {

        F = fkuv[i][j][0] ;
        K = fkuv[i][j][1] ;

        u = U[i][j];  
        v = V[i][j]; 
        //left  = offsetW[i][0]; right = offsetW[i][1];
        //up    = offsetH[j][0]; down  = offsetH[j][1];

        uvv = u*v*v;
        dU[i][j] = fkuv[i][j][2]*(U[offsetW[i][0]][j]+U[offsetW[i][1]][j]+U[i][offsetH[j][0]]+U[i][offsetH[j][1]] -4*u) - uvv + F*(1 - u);
        dV[i][j] = fkuv[i][j][3]*(V[offsetW[i][0]][j]+V[offsetW[i][1]][j]+V[i][offsetH[j][0]]+V[i][offsetH[j][1]] -4*v) + uvv - (K+F)*v;
      }
    }
    for (int i = 0; i < W; ++i) {
      for (int j = 0; j < H; ++j) {
        U[i][j] += dU[i][j] * 1.38f ;
        V[i][j] += dV[i][j] * 0.63f ;
      }
    }
    surface.setTitle ("TexTuring - computing ["+PApplet.parseInt( (100*n)/(params.o[0]+1))+"%]" );
  }

  img.loadPixels();
    int pShift,pShift2;
    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {
        pShift = PApplet.parseInt( U[i][j]*255 ) ;

        img.pixels[j*W+i] = 0xff000000 | (pShift << 16) | (pShift << 8) | pShift  ;

        if( updateDiSliderImage && pShift<params.o[1] ) { img.pixels[j*W+i] = C[18]; } 
        else if ( updateDiSliderImage ) { img.pixels[j*W+i] = color(255); }

      }
    }
  img.updatePixels();

  lastRenderTime = ( millis()-time ) /1000 ; 
  surface.setTitle ( "TexTuring - " + lastRenderTime + " sec");
  return img;
}
class GuiWindow {
  ArrayList<GuiElement> elements;

  GuiWindow() { 
    elements = new ArrayList<GuiElement>();
  }

  public void setupGui(){  
    try { UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName()); } catch (Exception e) { e.printStackTrace(); }  //  platform specific UI
    for (int i = 0; i<=25; i++){ colorMode(HSB); C[i] = color(122,270-i*13,100+i*5); } // create UI color shades
    background(C[25]); noStroke();
    PFont font = loadFont("FedraTwelve-Normal-12.vlw"); textFont(font, 12);
    
    elements.add(0, new ViewPort(new Rect( width/2+b, b, width/2 -2*b, height -2*b )));
    elements.add(new Menu(new Rect( d    , d, 100+5, 20       ), new String[]{ "open", "image file", "images folder" } ));
    elements.add(new Button(new Rect( d+110, d, 100+5, 20       ), "export"));
    elements.add(new Button(new Rect( d+220, d, 100+5, 20       ), "load"));
    elements.add(new Button(new Rect( d+330, d, 95,    20       ), "save"));
    elements.add(new Button(new Rect( d+430, d, a/2-b, 20       ), "specimen"));
    elements.add(new Button(new Rect( d+a+a+a/2+30, d, a/2-b, 20), "render"));
    elements.add(new   Slider(new Rect( gauche,  haut+a+c+15, a+20, 20), "iterations", 5000));  
    elements.add(new CheckBox(new Rect( gauche,  haut+a+c+65, 20, 20), "check threshold"));  
    elements.add(new   Slider(new Rect( gauche+25,  haut+a+c+65, a-5, 20), "threshold", 255));  
    elements.add(new   Slider(new Rect( gauche,  haut+a+c+100, a+20, 20), "resolution", 255));

    elements.add(new BiSlider(new Rect( gauche-10, haut+a+c+150, a+20 , 60), "reaction"));
    elements.add(new BiSlider(new Rect( gauche-10, haut+a+c+a+a/2-60, a+20, 60), "diffusion"));
    elements.add(new DiSlider(new Rect( gauche+a+80+b, haut+a+c+10, a+20, a+20), "thickness", "brightness"));
    for (int i = 0; i<6; i++) {  
      elements.add(new Snap( new Rect( d+i%6*(a/2+b), height-d-a/2+floor(i/6)*(a/2+b), a/2, a/2 ) , "snap"+i ));  
    }
  }

  public void injectMouseDragged()  { for (GuiElement elem : elements) { elem.dragged(); } }
  public void injectMouseMoved()    { for (GuiElement elem : elements) { elem.mouved();  } } 
  public void injectMouseReleased() { for (GuiElement elem : elements) { elem.released(); } }
  public void injectMousePressed()  { for (GuiElement elem : elements) { if ( elem.isOver() ) { elem.pressed(); return; } } }
  public void injectMouseWheel(int scroll){for (GuiElement elem : elements) { if( elem.isOver() ) { elem.scroll(scroll); return; } } }

  public void update(){    
    updateDiSliderImage = true ;
    viewing = true ;
    for (GuiElement elem : elements) { elem.update(); } 
  }
}

public void loadFile( File _file ){ params.loadFile( _file ); }
public void saveFile( File _file ){ params.saveFile( _file ); }

public void buttonPressed( GuiElement _elem ){
    if ( _elem.name == "image file" ) { selectInput("Select your image", "fileSelected"); viewing = true ; } 
    if ( _elem.name == "export" ) { exportImage(); }       
    if ( _elem.name == "load" ) {     selectInput( "Select TexTuring settings file", "loadFile"); viewing = true ; } 
    if ( _elem.name == "save" ) {     selectOutput("Name your TexTuring settings file", "saveFile"); } 
    if ( _elem.name == "specimen" ) {  }
    if ( _elem.name == "check threshold" ) { threshold = !threshold ; viewing=true; }
    if ( _elem.name == "render" ) {  gui.elements.get(0).renderView(); }
}

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
    if (name=="resolution") ref = 2 ;
    if (name=="reaction") ref = 2 ;
    if (name=="diffusion") ref = 3 ;
  }

  public boolean isOver() {
    return coords.isOver(mouseX, mouseY);
  }

  public void update() {  }
  //callbacks for injecting events
  public void mouved() { update(); }
  public void pressed() {  }
  public void released() {  }
  public void dragged() {  }
  //helpers to uniformize ways of drawings things
  public void drawRect( Rect r) {
     rect(r.pos.x, r.pos.y,r.size.x,r.size.y); 
  }
  public void drawImage(PImage i, Rect r) {
     image(i, r.pos.x, r.pos.y,r.size.x,r.size.y); 
  }
  public void drawText( Rect r, String text) {
     text(text, coords.pos.x + 5, coords.pos.y);
  }
  PImage viewImg;
  public void renderView() {}
  public void scroll(int scroll) {}
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
      gui.elements.add( new Button(_rect, names[i] ) );
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
      for (GuiElement _elem : gui.elements) {
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
  boolean press = false;
  
  Slider(Rect _coords, String _name, int _range){ 
    super(_coords, _name);
    range = _range;
    update();
  }
  public void pressed (){
    press = true; 
  }
  public void released (){ 
    if (press) updateDiSliderImage = true;
    press = false;  
  }
  public void dragged () {
    if ( press ) {
      int off = (control) ? 20 : 1 ;
      params.o[ref] = (int)constrain(  params.o[ref] + map(mouseX-pmouseX,0,coords.size.x,0,range) , 1, range);
      update(); 
      viewing = true; 
    }
  }

  public void update(){
    //float b = params.o[ref]*w/range;
    float b = map( params.o[ref], 0,range, 0,coords.size.x ) ;
    Vector2 s = new Vector2(coords.size);

    fill( isOver() ? C[12] : C[17] ); 
    drawRect(coords);
    pushMatrix(); translate(coords.pos.x, coords.pos.y);
        fill(C[15]); rect(0, 3, b, s.y-6); // Slider
        fill(colorFont); 
        text(name, 0 , -10);
        text((int)b, b, s.y-3-4);  // number display
    popMatrix();
  }  
}

class ViewPort extends GuiElement { 
  Rect viewZone ;
  Rect renderZone ;
  PImage srcMin ;
  PImage viewImg ;
  float zoom = 1 ;
  float centerRectX, centerRectY ;
  ViewPort (Rect _coords) { 
    super(_coords, "preview");
    viewZone   = new Rect(0,0,coords.size.x, coords.size.y); // from top left of input src
    renderZone = new Rect(coords.pos.x, coords.pos.y, 100, 100); 
    srcMin  = createImage(100, 100, ALPHA);
    viewImg = createImage(PApplet.parseInt(coords.size.x), PApplet.parseInt(coords.size.y), ALPHA);
  }
  public void released() { //viewing = true; 
    }

  public void dragged() {
    synchroScroll = false ;
    if ( isOver() ) {
      viewZone.pos.x = constrain( viewZone.pos.x+pmouseX-mouseX, 0, (src.width -viewZone.size.x > 0) ? src.width -viewZone.size.x : 0 ) ;
      viewZone.pos.y = constrain( viewZone.pos.y+pmouseY-mouseY, 0, (src.height-viewZone.size.y > 0) ? src.height-viewZone.size.y : 0 ) ;
      updateView();
      
      viewing = true ;
    }
  }
  public void scroll(int scroll){
    if(src.width/src.height<= 1) zoom = constrain(zoom +0.05f*scroll, 0.1f, src.height/coords.size.y);  // src image = paysage
    if(src.width/src.height > 1) zoom = constrain(zoom +0.05f*scroll, 0.1f, src.width/coords.size.x);  // src image = portrait
    viewZone.size.x = coords.size.x*zoom ;
    viewZone.size.y = coords.size.y*zoom ;
    
    println("zoom : "+zoom);
    synchroScroll = true ;
  }

  public void renderView(){
    updateView();
    viewImg = render(viewImg, (viewZone.size.x > src.width ) ? PApplet.parseInt(src.width/zoom) : (int)coords.size.x );
    viewing = true ;
  }

  // setup viewImg as the viewZone from src
  public void updateView(){
    viewImg  = createImage( (int)viewZone.size.x, (int)viewZone.size.y, ALPHA );
    viewImg.set(-(int)viewZone.pos.x, -(int)viewZone.pos.y, src );
  }

  public void update(){

    // original image display
    if(src.width/src.height <= 1) // src image = paysage
      image(viewImg, coords.pos.x, coords.pos.y,
          (viewZone.size.x > src.width ) ? src.width/zoom : coords.size.x ,
          (viewZone.size.x > src.width ) ? coords.size.y : coords.size.y );
    if(src.width/src.height > 1) // src image = portrait
      image(viewImg, coords.pos.x, coords.pos.y,
          (viewZone.size.x > src.height ) ? coords.size.y : coords.size.x ,
          (viewZone.size.x > src.height ) ? src.height/zoom : coords.size.y );

    // render renderZone
    if( viewing ){    
      viewing = false ;
      // set renderZone size
      if(lastRenderTime <0.05f) { renderZone.size.x+=10 ;} else if (lastRenderTime >0.08f) { renderZone.size.x-=10 ;};
      if(lastRenderTime <0.05f) { renderZone.size.y+=10 ;} else if (lastRenderTime >0.08f) { renderZone.size.y-=10 ;};
      renderZone.size.x = constrain( renderZone.size.x, 60, coords.size.x*zoom );
      renderZone.size.y = constrain( renderZone.size.y, 60, coords.size.y*zoom );

      centerRectX = ( coords.size.x - renderZone.size.x/zoom )/2 ; // position centrer du render dans le veiwport
      centerRectY = ( coords.size.y - renderZone.size.y/zoom )/2 ;
      
      srcMin = createImage( PApplet.parseInt(renderZone.size.x), PApplet.parseInt(renderZone.size.y), ALPHA );  
      srcMin.set( PApplet.parseInt(-centerRectX*zoom), PApplet.parseInt(-centerRectY*zoom), viewImg );
      srcMin = render(srcMin, PApplet.parseInt( renderZone.size.x/zoom ) );
    }
    image(srcMin,  PApplet.parseInt(coords.pos.x +centerRectX), PApplet.parseInt(coords.pos.y +centerRectY) ); 
    

    if ( isOver() ) { cursor(CROSS); } else { cursor(ARROW); }
  }
}

class Snap extends GuiElement {
  PImage snap;
  Parameters savedParams = new Parameters();
  Rect delete;
  PImage delImg;

  Snap (Rect _coords, String _name) { 
    super(_coords, _name);
    delete = new Rect(coords.pos.x, coords.pos.y, 20, 20);
    delImg = loadImage("delete.png");
    update();
  }
  public void pressed (){

    if( snap == null ) {  // save snap
      savedParams.loadParameters( params );

      snap = loadImage("gradVertical.png");
      snap.resize(100,100);
      snap = render(snap,100);

      fill(C[25]); drawRect(coords);
      update();
    }

    if ( snap!=null ) {  
      if ( delete.isOver() ) { snap = null ; } 
      else { // load snap
        params.loadParameters( savedParams );
        gui.update();
      }
    }      
    viewing = true ;
  }
  public void update(){
    println(snap);
    if ( snap == null ) {
      fill( isOver() ? C[12] : C[17] ); 
      drawRect(coords);
    } else {
      if ( !isOver() ) tint( C[17] );  image(snap, coords.pos.x, coords.pos.y);
      if ( !isOver() ) noTint();  
      if ( isOver() ) {
        fill( delete.isOver() ? C[12] : C[17] );
        drawRect(delete);
        image(delImg,coords.pos.x, coords.pos.y);
      }
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
    if ( zone!=0 ) updateDiSliderImage = true ;
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
    updateDiSliderImage = true;
    update();
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
    if ( zone!=0 ) {
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
      update();
      viewing = true ;
    }
  }

  public void update () {
    if ( updateDiSliderImage ) {
      turing2(mapImg); 
      updateDiSliderImage = false;
    }

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

class Parameters {
  float[] b = {0 ,0 ,0 ,0} ; // R&D black handle
  float[] w = {0 ,0 ,0 ,0} ; // R&D white handle
  int[]   o = {0, 0, 200} ; // iterations, threshold, resolution
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
    gui.update();
  }
  public void loadParameters( Parameters other ) {
    arrayCopy(other.b, b) ;
    arrayCopy(other.w, w) ;
    arrayCopy(other.o, o) ;
  }
}


  


















param_t param = new param_t();
Bitmap bmp;
PoTraceJ poTraceJ = new PoTraceJ(param);
BufferedImage result;


public void svgConverter( PImage input, float scale, String filePath ){

    bmp = new Bitmap( input.width, input.height );
    for(int y=0; y<input.height; y++) {
        for(int x=0; x<input.width; x++) {
            int c = input.get(x, y);
            
            if (brightness(c) < 100) {
                bmp.put(x, y, 255 );
            } else {
                bmp.put(x, y, 0 );
            }
        }
    } 

    PoTraceJ poTraceJ = new PoTraceJ(param);
    path_t trace = null;

    trace = poTraceJ.trace(bmp);
 Thread.yield();

    ArrayList<PathElement> al = new ArrayList<PathElement>();
    ConvertToJavaCurves.convert(trace, new HashSet<ConvertToJavaCurves.Point>(), al);

    DOMImplementation domImpl = GenericDOMImplementation.getDOMImplementation();
    String svgNS = "http://www.w3.org/2000/svg";
    Document document = domImpl.createDocument(svgNS, "svg", null);

    SVGGraphics2D g2 = new SVGGraphics2D(document);
        g2.scale(scale, scale);
        g2.setColor(Color.WHITE);
        g2.fillRect(0, 0, bmp.getWidth(), bmp.getHeight());
        g2.setColor(Color.BLACK);
        g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g2.setRenderingHint(RenderingHints.KEY_FRACTIONALMETRICS, RenderingHints.VALUE_FRACTIONALMETRICS_ON);
        g2.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        GeneralPath path = new GeneralPath();
        for (PathElement pathElement : al) {
            switch (pathElement.getType()) {
                case CLOSE_PATH:
                    path.closePath();
                    break;
                case LINE_TO:
                    path.lineTo(pathElement.getP0x(), pathElement.getP0y());
                    break;
                case MOVE_TO:
                    path.moveTo(pathElement.getP0x(), pathElement.getP0y());
                    break;
                case CURVE_TO:
                    path.curveTo(pathElement.getP0x(), pathElement.getP0y(), pathElement.getP1x(), pathElement.getP1y(), pathElement.getP2x(), pathElement.getP2y());
                    break;
            }
        }
        g2.setPaint(Color.black);
        g2.fill(path);

   try {
    Writer out = new FileWriter(filePath);
    g2.stream(out, false);
    out.close();
   } catch (Exception e) {
    println(e);
   }
}



/*
// processing path to svg - didn't work well ...

        beginRecord(SVG, "output.svg");
        background(255);
        stroke(0);
        int i = 0;

        PShape s = createShape();
        s.colorMode(HSB);
        

        for (PathElement pathElement : al) {
            println(" "+pathElement.getType());
            switch (pathElement.getType()) { 
                case CLOSE_PATH:
                    s.endShape(CLOSE);
                    break;

                case LINE_TO:
                    s.vertex((float)pathElement.getP0x(), (float)pathElement.getP0y());
                    break;

                case MOVE_TO:
                    s.beginShape();
                    s.fill(i,255,127);
                    s.vertex((float)pathElement.getP0x(), (float)pathElement.getP0y());
                    break;

                case CURVE_TO:
                    s.bezierVertex( (float)pathElement.getP0x(), (float)pathElement.getP0y(), 
                        (float)pathElement.getP1x(), (float)pathElement.getP1y(), 
                        (float)pathElement.getP2x(), (float)pathElement.getP2y() );
                    break;

                case POP_PARENT:
                    s.beginContour();
                    i+=50;
                    s.fill( color(i,255,127) );
                    break; 
                case PUSH_PARENT:
                    s.endContour();
                    i-=50;
                    break;
            }
        }
        stroke(0);
        shape(s, 25, 25);
        endRecord();
*/

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
