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
  
    colorMode(HSB); for (int i=0;i<=25;i++) C[i] = color(123,270-i*13,100+i*5); // create UI color shades

    background( bg );
    noStroke();
    PFont font = loadFont("PixelOperator-16.vlw"); textFont(font, 16);

    Rect guiRect = new Rect(d, d, 100, 22 );
                          elements.add(new Menu  (new Rect(guiRect), new String[]{ "Parameters", "Save settings ", "Load settings" } ));
    guiRect.pos.x += 190; elements.add(new Menu  (new Rect(guiRect), new String[]{ "Input  image", "Select file", "Select folder" } ));
    guiRect.pos.x += 105; elements.add(new Button(new Rect(guiRect), "Export  image"));
    guiRect.pos.x += 145; elements.add(new Menu  (new Rect(guiRect), new String[]{ "Seeding mode", "noise", "monochrome", "regular" } ));
    guiRect.pos.x += 130; elements.add(1,new StatusBar(new Rect(guiRect), "status"));

                          elements.add(0,new ViewPort(new Rect( width/2, b+35, width/2 -2*b, height -3*b-35 )));

    guiRect.pos.x = int( width/2 ); elements.add(new Button(new Rect(guiRect) , "render"));
    guiRect.size.x = 22; guiRect.size.y = 22;
    guiRect.pos.x +=100; elements.add(new Button(new Rect(guiRect), " +"));
    guiRect.pos.x += 25; elements.add(new Button(new Rect(guiRect), " -"));
    guiRect.size.x=45;
    guiRect.pos.x = width-d-45; elements.add(new Button(new Rect(guiRect), "about"));

    int guiWidth = 350;
    guiRect = new Rect( 200, d, guiWidth, 23);
    guiRect.pos.y += 100; elements.add(new   Slider(new Rect(guiRect), "iterations","Growing time", 5000));  
    guiRect.pos.y += 55; elements.add(new   Slider(new Rect(guiRect), "resolution","Size", 255));
    guiRect.pos.y += 55; 
    guiRect.size.x-= 30; elements.add(new   Slider(new Rect(guiRect), "threshold","Threshold", 255));
    guiRect.pos.x += guiRect.size.x+10; 
    guiRect.size.x = 22; elements.add(new CheckBox(new Rect(guiRect), "check threshold"));  

    guiRect = new Rect( 200+50, guiRect.pos.y, 250, 250 );
    guiRect.pos.y += 50; elements.add(new DiSlider(new Rect(guiRect), "From Growing bay to shade of greys"));
    
    guiRect.size.x = guiWidth+10; guiRect.size.y = 60; guiRect.pos.x= 200;
    guiRect.pos.y += 300; elements.add(new BiSlider(new Rect(guiRect), "reaction","Feed"));
    guiRect.pos.y += 65;          elements.add(new BiSlider(new Rect(guiRect), "diffusion", "Kill"));

    for (int i = 0; i<7; i++) {  
      elements.add(new Snap( new Rect( d , d+100+ i*(80+b)  , 100, 80 ) , "snap" ));  
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
    fill(colorFont); text("Samples", d, d+100 -10 );

  }
  void resize(){
    for (GuiElement elem : elements) { elem.resize(); }  
  }
  void message(String msg){
    elements.get(1).message(msg);
  }
  void about(){ 
    String txt = "TexTuring software :\n\nDithering tool based on natural patterns.\nTexTuring ease the use of reaction-diffusion model.\n\n\nProject initiated by Ivan Murit\nand developed with the help of Kevin Silliam.\n\n\nSpecial thanks to the Kickstarter community for the initial support ! ";
    fill(bg);
    Rect coords = new Rect( gui.elements.get(0).coords ) ;
    rect( coords.pos.x, coords.pos.y, coords.size.x, coords.size.y );
    fill(colorFont);
    text( txt, coords.pos.x+50, coords.pos.y+60, coords.size.x, int(coords.size.y/2)  );
  }
}

void loadFile( File _file ){ params.loadFile( _file ); }
void saveFile( File _file ){ params.saveFile( _file ); }


void buttonPressed( GuiElement _elem ){
    if ( _elem.name == "Select file" ) { selectInput("Select a new image", "fileSelected"); viewing = true ; } 
    if ( _elem.name == "Select folder" ) { selectFolder("Select a folder to process:", "folderSelected");} 
    if ( _elem.name == "Export  image" ) { exportImage(); }       
    if ( _elem.name == "Load settings" ) {     selectInput( "Select TexTuring settings file", "loadFile"); viewing = true ; } 
    if ( _elem.name == "Save settings" ) {     selectOutput("Name your TexTuring settings file", "saveFile"); } 
    if ( _elem.name == "specimen" ) {  }
    if ( _elem.name == "check threshold" ) { threshold = !threshold ; viewing=true; }
    if ( _elem.name == "render"){ gui.elements.get(0).renderView(); }
    if ( _elem.name == " +" ) {  gui.elements.get(0).scroll(-1); }
    if ( _elem.name == " -" ) {  gui.elements.get(0).scroll(1); }
    if ( _elem.name == "about" ) { gui.about(); }
    
    if ( _elem.name == "noise" ) {      params.iniState = 0; viewing=true; synchroScroll = true ; gui.update(); }
    if ( _elem.name == "regular" ) {    params.iniState = 1; viewing=true; synchroScroll = true ; gui.update(); }
    if ( _elem.name == "monochrome" ) { params.iniState = 2; viewing=true; synchroScroll = true ; gui.update(); }
}

color[] C = new color[26];
color bg = color(225);
//color colorOver = color();
color colorActive = #ff8e09; // #ff7f09; //#fc3011; //fc622a;
color colorFont = #002645;
int a = 200, b = 5, c = 20, d = 10, haut = 60, gauche = 65;
void styleSelecStroke(){ stroke(C[15]); noFill(); }
void styleSelec(){ fill(C[15]); noStroke(); }
void fontColor(){ fill(#002666); }

