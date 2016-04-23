class GuiWindow {
  ArrayList<GuiElement> elements;

  GuiWindow() { 
    elements = new ArrayList<GuiElement>();
  }

  void setupGui(){  
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
}

void loadFile( File _file ){ params.loadFile( _file ); }
void saveFile( File _file ){ params.saveFile( _file ); }

void buttonPressed( GuiElement _elem ){
    if ( _elem.name == "image file" ) { selectInput("Select your image", "fileSelected"); viewing = true ; } 
    if ( _elem.name == "export" ) { exportImage(); }       
    if ( _elem.name == "load" ) {     selectInput( "Select TexTuring settings file", "loadFile"); viewing = true ; } 
    if ( _elem.name == "save" ) {     selectOutput("Name your TexTuring settings file", "saveFile"); } 
    if ( _elem.name == "specimen" ) {  }
    if ( _elem.name == "check threshold" ) { threshold = !threshold ; viewing=true; }
    if ( _elem.name == "render" ) {  gui.elements.get(0).renderView(); }
}

color[] C = new color[26];
color bg = #EDEDED;
color colorElemBg = color(210);
//color colorOver = color();
color colorActive = #ff7f09; //#fc3011; //fc622a;
color colorFont = #002645;
int a = 200, b = 5, c = 20, d = 10, haut = 60, gauche = 65;
void styleSelecStroke(){ stroke(C[15]); noFill(); }
void styleSelec(){ fill(C[15]); noStroke(); }
void fontColor(){ fill(#002666); }