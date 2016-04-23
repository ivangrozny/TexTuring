import javax.swing.*;
import java.awt.event.*;
import java.awt.BorderLayout;
import java.awt.image.BufferedImage;

boolean control = false, live = true, updateDiSliderImage = false, viewing = false, threshold = true;
boolean synchroScroll = false;
PImage src ;
int h,w, off, offX, offY, viewSize=100 ;
float lastRenderTime;

String lastPath ;
File lastDirectory = null;

GuiWindow gui ;
Parameters params ;

void setup() {
  size(1350, 720); //size(displayWidth, displayHeight);
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

void draw() {
 if ( viewing )       gui.elements.get(0).update() ;
 if ( synchroScroll ) gui.elements.get(0).dragged();

 if (pmouseX!=mouseX || pmouseY!=mouseY) gui.injectMouseMoved  ();
 if ((pmouseX!=mouseX || pmouseY!=mouseY) && mousePressed) gui.injectMouseDragged ();
}

void mousePressed (){ gui.injectMousePressed (); }
void mouseReleased(){ gui.injectMouseReleased(); }
void mouseWheel(processing.event.MouseEvent event) { gui.injectMouseWheel(event.getCount()); }

PImage render(PImage imageIn, int widthOut ){
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
  PImage tmp = loadImage(lastPath);
  tmp.filter(GRAY);
  src = createImage(tmp.width, tmp.height, ALPHA);
  src.copy(tmp,0,0,src.width, src.height,0,0,src.width, src.height);
  w = src.width;
  h = src.height;
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