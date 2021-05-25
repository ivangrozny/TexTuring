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
    javax.swing.JFrame jframe = (javax.swing.JFrame)((processing.awt.PSurfaceAWT.SmoothCanvas)getSurface().getNative()).getFrame();
    jframe.setLocation(0, 0);
    jframe.setExtendedState(jframe.getExtendedState() | jframe.MAXIMIZED_BOTH);
    surface.setResizable(true);
    surface.setTitle ( "TexTuring" );
    surface.setIcon( loadImage("logo.png") );
    colorMode(HSB); for (int i=0;i<=25;i++) C[i] = color( 133, 270-i*13, 105+i*5 ); // create UI color shades
    colorActive = C[12]; //color(255, 142, 9);
    background( bg );
    noStroke();
    PFont font = loadFont("PixelOperator-16.vlw"); textFont(font, 16);
    initDrop();

    int guiWidth = 350;
    Rect guiRect = new Rect(d, d, 100, 22 );
                          elements.add(new Menu  (new Rect(guiRect), new String[]{ "Parameters", "Save settings", "Load settings" } ));
    guiRect.size.x = 113;
    guiRect.pos.x += 190; elements.add(new Menu  (new Rect(guiRect), new String[]{ "Input  image", "Select file", "Select folder" } ));
    guiRect.pos.x += 118; elements.add(new Menu  (new Rect(guiRect), new String[]{ "Seeding  mode", "random", "noise", "uniform" } ));
    guiRect.pos.x += 118; elements.add(new Button(new Rect(guiRect), "Save  image"));

                          elements.add(0,new ViewPort(new Rect( d+200+350+90 , b+35, width-200-350-90-d-d, height -3*b-35 )));

    guiRect.pos.x = d+200+350+90; elements.add(new Button(new Rect(guiRect) , "Render  preview"));
    guiRect.size.x = 22; guiRect.size.y = 22;
    guiRect.pos.x +=118;  elements.add(new Button(new Rect(guiRect), " +"));
    guiRect.pos.x += 22+5;elements.add(new Button(new Rect(guiRect), " -"));
    guiRect.pos.x += 22+6;
    guiRect.size.x=width-guiRect.pos.x-45-d; elements.add(1,new StatusBar(new Rect(guiRect), "status"));
    guiRect.size.x=45;
    guiRect.pos.x = width-d-45; elements.add(new Button(new Rect(guiRect), "About"));

    guiRect = new Rect( 200, d, guiWidth, 23);
    guiRect.pos.y += 100; elements.add(new Slider(new Rect(guiRect), "iterations","Growing time", 5000));
    guiRect.pos.y += 55; elements.add(new Slider(new Rect(guiRect), "resolution","Size", 255));
    guiRect.pos.y += 55;
    guiRect.size.x-= 30; elements.add(new Slider(new Rect(guiRect), "threshold","Threshold", 255));
    guiRect.pos.x += guiRect.size.x+10;
    guiRect.size.x = 22; elements.add(new CheckBox(new Rect(guiRect), "check threshold"));

    guiRect = new Rect( 200+50, guiRect.pos.y, 250, 250 );
    guiRect.pos.y += 55; elements.add(2,new DiSlider(new Rect(guiRect), "From Growing bay to shades of grey"));

    guiRect.size.x = guiWidth+10; guiRect.size.y = 60; guiRect.pos.x= 200;
    guiRect.pos.y += 304; elements.add(new BiSlider(new Rect(guiRect), "reaction","Feed rate"));
    guiRect.pos.y += 72;  elements.add(new BiSlider(new Rect(guiRect), "diffusion", "Kill rate"));

    for (int i = 0; i<7; i++) {
      elements.add( i+2, new Snap( new Rect( d , d+100+ i*(80+b)  , 100, 80 ) , "snap" ));
    }
    elements.get(7).flag = "beginAnimation";
    elements.get(8).flag = "endAnimation";
    elements.get(16).isSelected = true; // default seeding mode
    // debug : list elements position
    // for (int i = 0; i < gui.elements.size(); ++i) println(i + "---" + gui.elements.get(i).name );
  }

  void injectMouseMoved()   { for(GuiElement elem:elements){if(                !isRendering||elem.name.equals("Render  preview"))  elem.moved(); } }
  void injectMouseDragged() { for(GuiElement elem:elements){if(elem.isOver()&&(!isRendering||elem.name.equals("Render  preview"))){elem.dragged();return; }}}
  void injectMouseReleased(){ for(GuiElement elem:elements){if(elem.isOver()&&(!isRendering||elem.name.equals("Render  preview"))){elem.released();return;}}}
  void injectMousePressed() { for(GuiElement elem:elements){if(elem.isOver()&&(!isRendering||elem.name.equals("Render  preview"))){elem.pressed();return; }}}
  void injectMouseWheel(int scroll){ for (GuiElement elem : elements) { if(elem.isOver()&&!isRendering ) { elem.scroll(scroll); return; } } }

  void update(){
    gui.elements.get(9).updateMapImg();
    viewing = true ;
    for (GuiElement elem : elements)
      elem.update();
    fontColor(); text("Samples", d, d+100 -10 );
  }
  void resize(){ for (GuiElement elem:elements) elem.resize(); }
  void message(String msg){ elements.get(1).message(msg); updateMessage = true; }
  void about(){
    JPanel aboutPane = new JPanel(new BorderLayout());
    JLabel    p1 = new JLabel("<html><h2>TexTuring 2.3</h2>2015-2021 - General Public Licence - GNU GPL<br>Dithering tool based on natural patterns.<br><br> Concept & production :<br></html>");
    SwingLink p2 = new SwingLink("www.ivan-murit.fr", "www.ivan-murit.fr");
    JLabel    p3 = new JLabel("<html><br>Special thanks to the crowd-founders for the initial support !<br><br></html>");
    p1.setFont(new Font("SansSerif", Font.PLAIN, 14));
    p2.setFont(new Font("SansSerif", Font.PLAIN, 14));
    p3.setFont(new Font("SansSerif", Font.PLAIN, 14));
    aboutPane.add( p1 ,BorderLayout.NORTH ); aboutPane.add( p2 ,BorderLayout.CENTER ); aboutPane.add( p3 , BorderLayout.SOUTH );
    // link.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));

    int aboutResult = JOptionPane.showConfirmDialog(null, aboutPane, "About", JOptionPane.DEFAULT_OPTION, JOptionPane.PLAIN_MESSAGE);
  }
}

void keyPressed(){
  if (key=='+')  gui.elements.get(0).scroll(-1);
  if (key=='-')  gui.elements.get(0).scroll(1);
  if (key==' ')  gui.elements.get(0).renderView();
  if (key==ENTER)  gui.elements.get(0).renderView();
  if ( keyCode == CONTROL) control = true;
}

void buttonPressed( GuiElement e ){
    if ( e.name == "Select file" ) { selectInput("Select a new image", "fileSelected"); }
    if ( e.name == "Select folder" ) { selectFolder("Select a folder to process:", "folderSelected");}
    if ( e.name == "Save  image" ) { exportImage(); }
    if ( e.name == "Load settings" ) { selectInput( "Select TexTuring settings file", "loadFile"); viewing = true ; }
    if ( e.name == "Save settings" ) { selectOutput("Name your TexTuring settings file", "saveFile"); }
    if ( e.name == "specimen" ) {  }
    if ( e.name == "check threshold" ) { threshold = !threshold ; viewing=true; }
    if ( e.name == "Render  preview"){ gui.elements.get(0).renderView(); }
    if ( e.name == " +" ) {  gui.elements.get(0).scroll(-1); }
    if ( e.name == " -" ) {  gui.elements.get(0).scroll(1); }
    if ( e.name == "About" ) { gui.about(); }
    GuiElement e16 = gui.elements.get(16); GuiElement e17 = gui.elements.get(17); GuiElement e18 = gui.elements.get(18);
    if ( e.name == "random" ){params.iniState=0; viewing=true; synchroScroll=true; e.isSelected=true; e17.isSelected=false; e18.isSelected=false; gui.update(); }
    if ( e.name == "noise"  ){params.iniState=1; viewing=true; synchroScroll=true; e.isSelected=true; e16.isSelected=false; e18.isSelected=false; gui.update(); }
    if ( e.name == "uniform"){params.iniState=2; viewing=true; synchroScroll=true; e.isSelected=true; e16.isSelected=false; e17.isSelected=false; gui.update(); }
    mousePressed = false ;
}

void loadFile( File _file ){ params.loadFile( _file ); }
void saveFile( File _file ){ params.saveFile( _file ); }

color[] C = new color[26];
color bg = color(225);
color colorActive ; //color(255, 142, 9);
int a = 200, b = 5, c = 20, d = 10, haut = 60, gauche = 65;
void styleSelecStroke(){ stroke(C[15]); noFill(); }
void styleSelec(){ fill(C[15]); noStroke(); }
void fontColor(){ fill(C[0]); }
