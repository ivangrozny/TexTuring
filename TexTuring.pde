import javax.swing.*;
import java.awt.event.*;
import java.awt.BorderLayout;
boolean control = false, live = true, updateDiSliderImage = false, viewing = false, greyScale = false;
PImage src, view, currentI, srcMin ;
int viewX, viewY,h,w, off, offX, offY, viewSize=100 ;
String lastPath ;

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
  //fill(C[25]); rect(a+b+d, d+haut, a/2, a/2); 
  view = src.get( viewX,viewY, viewSize, viewSize); turing2(view); 
  viewing = false ;
  imageMode(CENTER); image(view, gauche+srcMin.width+(a-srcMin.width+a+a/2)/2, haut+a/2); imageMode(CORNER);
}
void render(){
  currentI = src.get();
  turing2(currentI); 
  image(currentI, 3*a+35+d, d ); // ,(currentI.width*(height-d))/currentI.height, height-d); 
}

void exportImage() {
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
  render(); //currentI.save(selection.getAbsolutePath()+".png"); 
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

