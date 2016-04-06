import javax.swing.*;
import java.awt.event.*;
import java.awt.BorderLayout;
boolean control = false, live = true, updateDiSliderImage = false, viewing = false, greyScale = true;
PImage src, currentI, srcMin ;
int viewX, viewY,h,w, off, offX, offY, viewSize=100 ;
String lastPath ;

File lastDirectory = null;

GuiWindow gui ;
Parameters params ;

void setup() {
  size(1350, 720); //size(displayWidth, displayHeight);
  gui = new GuiWindow();
  params = new Parameters();
  gui.setupGui();
  fileSelected( new File(dataPath("wiki.png")) );                        // file selected at TexTuring launch
  //selectInput("Select a file to process:", "fileSelected");            // file selector at TexTuring launch
  params.loadFile( new File(dataPath("default.texturing")) );
  
  //frame.setIconImage( getToolkit().getImage("icone.ico") ); 
  //if (frame != null) { frame.setResizable(true) ;}
}

void draw() {
  if ( viewing ) preview() ;
}
  
void mousePressed (){ gui.injectMousePressed (); }
void mouseDragged (){ gui.injectMouseDragged (); }
void mouseMoved   (){ gui.injectMouseMoved   (); }
void mouseReleased(){ gui.injectMouseReleased(); }


void preview(){
  PImage view = src.get( viewX,viewY, viewSize, viewSize); 
  view.resize((int) params.o[2]*view.width/100+5, 0 );
  turing2(view); 
  view.resize(viewSize, 0 );
  if (greyScale) view.filter( THRESHOLD, map(params.o[1],0,255,0,1) );
  imageMode(CENTER); image(view, gauche+srcMin.width+(a-srcMin.width+a+a/2)/2, haut+a/2); imageMode(CORNER);
  viewing = false ;
}
PImage render(PImage imageIn, int widthOut ){
  PImage image = imageIn.get();
  image.resize((int) params.o[2]*image.width/100, 0 );
  turing2(image);
  image.resize( widthOut, 0 );
  
  if (greyScale) image.filter(THRESHOLD, map(params.o[1],0,255,0,1) );

  image(image, 3*a+35+d, d, height*image.width/image.height, height ); // display image on GUI
  return image ;
}

void exportImage() {
  JTextField nameField = new JTextField(12); nameField.setText( "export-"+int(random(9999)) );
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
      render(src, int(sizeField.getText()) ).save( path ); 
      break;
      case ".svg" : svgConverter( render(src, int(sizeField.getText()) ), 1, path ); break;  
    }

  }
}

void fileSelected(File selection) { 
  lastPath = selection.getAbsolutePath(); 
  src = loadImage(lastPath); 
  src.filter(GRAY);
  w = src.width;
  h = src.height;
  if (w>h) { srcMin = src.get(); srcMin.resize(a,0); }
  if (w<=h) { srcMin = src.get(); srcMin.resize(0,a); }

  gui.update();

  viewing = true ; 
}
void saveSpecimen(File selection){ 
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
}

void keyReleased()  { 
  control = false; 
}

