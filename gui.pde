class GuiWindow {
  ArrayList<GuiElement> elements;
  String state = "";
  ArrayList<File> listOfFiles;
  GuiWindow() { 
    elements = new ArrayList<GuiElement>();
    listOfFiles = new ArrayList<File>();
  }

  void setupGui(){  
    try { UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName()); } catch (Exception e) { e.printStackTrace(); }  //  platform specific UI
    for (int i = 0; i<=25; i++){ colorMode(HSB); C[i] = color(122,270-i*13,100+i*5); } // create UI color shades
    background( bg );
    noStroke();
    PFont font = loadFont("PixelOperator-16.vlw"); textFont(font, 16);

    Rect guiRect = new Rect(d, d, 95, 22 );

                          elements.add(new Menu  (new Rect(guiRect), new String[]{ "open", "image file", "images folder" } ));
    guiRect.pos.x += 100; elements.add(new Button(new Rect(guiRect), "export ..."));
    guiRect.pos.x += 100; elements.add(new Button(new Rect(guiRect), "specimen"));
    guiRect.pos.x += 150; elements.add(new Menu  (new Rect(guiRect), new String[]{ "seeding mode", "noise", "regular", "monochrome" } ));
    guiRect.pos.x += 150; elements.add(new Menu  (new Rect(guiRect), new String[]{ "file settings", "load", "save" } ));
    guiRect.pos.x += 130; elements.add(1,new StatusBar(new Rect(guiRect), "status"));
    
                          elements.add(0,new ViewPort(new Rect( width/2, b+35, width/2 -2*b, height -3*b-35 )));

    guiRect.pos.x = int( width/2 ); elements.add(new Button(new Rect(guiRect) , "render"));
    guiRect.size.x = 22; guiRect.size.y = 22;
    guiRect.pos.x +=100; elements.add(new Button(new Rect(guiRect), " +"));
    guiRect.pos.x += 30; elements.add(new Button(new Rect(guiRect), " -"));


    guiRect = new Rect( d, d, 300, 22);
    guiRect.pos.y += 80; elements.add(new   Slider(new Rect(guiRect), "iterations", 5000));  
    guiRect.pos.y += 50; elements.add(new   Slider(new Rect(guiRect), "resolution", 255));
    guiRect.pos.y += 50; 
    guiRect.size.x-= 30; elements.add(new   Slider(new Rect(guiRect), "threshold", 255));
    guiRect.pos.x += guiRect.size.x+10; 
    guiRect.size.x = 22; elements.add(new CheckBox(new Rect(guiRect), "check threshold"));  

    guiRect = new Rect( d+20, guiRect.pos.y, 300-20, 60 );
    guiRect.pos.y += 50; elements.add(new BiSlider(new Rect(guiRect), "reaction"));
    guiRect.pos.y +=100; elements.add(new BiSlider(new Rect(guiRect), "diffusion"));

    guiRect.size.x = 255; guiRect.size.y = 255;
    guiRect.pos.y += 100; elements.add(new DiSlider(new Rect(guiRect), "thickness", "brightness"));

    for (int i = 0; i<6; i++) {  
      elements.add(new Snap( new Rect( d+i%6*(a/2+b), height-d-a/2+floor(i/6)*(a/2+b), a/2, a/2 ) , "snap"+i ));  
    }
  }

  void injectMouseDragged()  { for (GuiElement elem : elements) { elem.dragged(); } }
  void injectMouseMoved()    { for (GuiElement elem : elements) { elem.mouved();  } } 
  void injectMouseReleased() { for (GuiElement elem : elements) { elem.released(); } }
  void injectMousePressed()  { for (GuiElement elem : elements) { if ( elem.isOver() ) { elem.pressed(); return; } } }
  void injectMouseWheel(int scroll){for (GuiElement elem : elements) { if( elem.isOver() ) { elem.scroll(scroll); return; } } }

  void update(){     
    updateDiSliderImage = true ;
    viewing = true ;
    for (GuiElement elem : elements) { elem.update(); } 
  }
  void resize(){
    for (GuiElement elem : elements) { elem.resize(); }  
  }
  void message(String msg){
    elements.get(1).message(msg);
  }
}

void loadFile( File _file ){ params.loadFile( _file ); }
void saveFile( File _file ){ params.saveFile( _file ); }

void buttonPressed( GuiElement _elem ){
    if ( _elem.name == "image file" ) { selectInput("Select a new image", "fileSelected"); viewing = true ; } 
    if ( _elem.name == "images folder" ) { selectFolder("Select a folder to process:", "folderSelected");} 
    if ( _elem.name == "export ..." ) { exportImage(); }       
    if ( _elem.name == "load" ) {     selectInput( "Select TexTuring settings file", "loadFile"); viewing = true ; } 
    if ( _elem.name == "save" ) {     selectOutput("Name your TexTuring settings file", "saveFile"); } 
    if ( _elem.name == "specimen" ) {  }
    if ( _elem.name == "check threshold" ) { threshold = !threshold ; viewing=true; }
    if ( _elem.name == "render"){ gui.elements.get(0).renderView(); }
    if ( _elem.name == " +" ) {  gui.elements.get(0).scroll(-1); }
    if ( _elem.name == " -" ) {  gui.elements.get(0).scroll(1); }
    
    if ( _elem.name == "noise" ) {      params.iniState = 0; viewing=true; synchroScroll = true ; gui.update(); }
    if ( _elem.name == "regular" ) {    params.iniState = 1; viewing=true; synchroScroll = true ; gui.update(); }
    if ( _elem.name == "monochrome" ) { params.iniState = 2; viewing=true; synchroScroll = true ; gui.update(); }
}

color[] C = new color[26];
color bg = color(225);
//color colorOver = color();
color colorActive = #ff7f09; //#fc3011; //fc622a;
color colorFont = #002645;
int a = 200, b = 5, c = 20, d = 10, haut = 60, gauche = 65;
void styleSelecStroke(){ stroke(C[15]); noFill(); }
void styleSelec(){ fill(C[15]); noStroke(); }
void fontColor(){ fill(#002666); }

