import javax.swing.*;
import java.awt.event.*;
import java.awt.BorderLayout;
import java.awt.image.BufferedImage;
import processing.pdf.*;
import drop.*; SDrop drop; MyDropListener dropListener;

boolean control = false, live = true, updateDiSliderImage = false, viewing = false, threshold = true;
boolean synchroScroll = false;
PImage src ;
int h,w, off, offX, offY, viewSize=100 ;
float lastRenderTime;

String lastPath ;
File lastDirectory = null;

GuiWindow gui ;
Parameters params ;
int listenerWidth, listenerHeight;

//MyThread myThread;

void settings() {
  size( int(displayWidth*0.8), int(displayHeight*0.8) );
}

void setup() {
  listenerHeight=height; listenerWidth=width;
  surface.setResizable(true);
  surface.setLocation(int(displayWidth*0.1), int(displayHeight*0.1));
  frameRate(30);

  //myThread = new MyThread();
  params = new Parameters();
  gui = new GuiWindow();
  gui.setupGui();
  fileSelected( new File(dataPath("launch.jpg")) );           
  params.loadFile( new File(dataPath("default.texturing")) );
  initDrop();
}

void draw() {
  fill( (frameCount%2==0)?100:200 ); rect(10,1000,500-frameCount*2%400,30);  // debug mode

  if ( viewing )       gui.elements.get(0).update() ;
  if ( synchroScroll ) gui.elements.get(0).dragged();
  if ( pmouseX!=mouseX || pmouseY!=mouseY)                  gui.injectMouseMoved (); // mousMoved listener
  if ((pmouseX!=mouseX || pmouseY!=mouseY) && mousePressed) gui.injectMouseDragged (); // mousDragged listener

  if (listenerWidth!=width || listenerHeight!=height) {  // resize listener
    listenerWidth=width; listenerHeight=height; 
    gui.resize(); 
    gui.update();
  }
}
void mousePressed (){ gui.injectMousePressed (); }
void mouseReleased(){ gui.injectMouseReleased(); }
void mouseMoved(){ if (gui.elements.get(0).isOver() ){ cursor(MOVE); }else{ cursor(ARROW); } }
void mouseWheel(processing.event.MouseEvent event) { gui.injectMouseWheel(event.getCount()); }
void keyReleased(){ control = false; }

void exportImage() {
  String[] extention = { ".png", ".gif animation", ".pdf specimen", ".svg [experimental]" };
  JTextField nameField = new JTextField(12); nameField.setText( "TexTuring-"+int(random(9999)) );
  JTextField sizeField = new JTextField(5); sizeField.setText( ""+(int) params.o[2]*src.width/100 );
  JComboBox extField = new JComboBox( new DefaultComboBoxModel(extention) );
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

  int result = JOptionPane.showConfirmDialog(null, outer, "Select export options", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
  if (result == JOptionPane.OK_OPTION) {

    lastDirectory = pathField.getCurrentDirectory();
    String path = pathField.getCurrentDirectory() + File.separator + nameField.getText() ;  
    println("savedPath: "+ path + "["+ extField.getSelectedItem() +"]" );


    if ( extention[0].equals(extField.getSelectedItem()) ) { 

      if( gui.state == "multiFiles" ){
        for ( int i=0; i < gui.listOfFiles.size(); ++i ) {
          src = loadImage( gui.listOfFiles.get(i).getAbsolutePath() );
          saveImage( render(src, int(sizeField.getText()) ), 
            pathField.getCurrentDirectory() + File.separator + nameField.getText() + File.separator + gui.listOfFiles.get(i).getName() ); 
        }
      } else {
        saveImage( render(src, int(sizeField.getText()) ) , path + ".png" ); 
      }
    }


    if ( extention[1].equals(extField.getSelectedItem()) ) { 
      // second message box to get gif export infos
      JPanel p3 = new JPanel(); 
      JPanel p4 = new JPanel(); 
      JTextField nbrFrameField = new JTextField(4); nbrFrameField.setText( "10" );
      p3.add(nbrFrameField); 
      p3.add(new JLabel("<html> frames from <i>begining sample</i> to <i>ending sample</i></html>"));
      JTextField durationField = new JTextField(4); durationField.setText( "0.1" );
      p4.add(durationField);
      p4.add(new JLabel("<html> seconds per frame</html>"));
      JPanel outer2 = new JPanel(new BorderLayout());
      outer2.add(p3, BorderLayout.NORTH);
      outer2.add(p4, BorderLayout.SOUTH);

      int result2 = JOptionPane.showConfirmDialog(null, outer2, "Select animation export options", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
      if (result2 == JOptionPane.OK_OPTION) {

        gifExport = new GifMaker(this, path + ".gif" );
        gifExport.setRepeat(0); // infinite
        gifExport.setQuality(10); // default 10

        params.loadParameters( gui.elements.get(7).savedParams );

        // render every frames
        for (int i=0; i < int(nbrFrameField.getText()); ++i) {
          
          gifExport.setDelay( int( float( durationField.getText() )*1000 ) ); // convert sec to ms 
          gifExport.addFrame( render(src, int(sizeField.getText())) );
          params.nextFrameAnimation( int( nbrFrameField.getText() ), gui.elements.get(8).savedParams );
        }
      
        gifExport.finish();
      }
    }

    if ( extention[2].equals(extField.getSelectedItem()) ) { 
      
      PGraphics pdf = createGraphics(3000, 4243, PDF, path + ".pdf");
      pdf.beginDraw();
      pdf.background(255);
      pdf.image(render(src, 3000), 0, 150);
      pdf.fill(0);
      pdf.textSize(36);
      
      pdf.text("TexTuring 1.0",20,40);
      pdf.text(nameField.getText(),120,40);

      pdf.text("Growing Time : " + params.o[0],500,40);
      pdf.text("Threshold : "    + params.o[1],500,80);
      pdf.text("Size : "         + params.o[2],500,120);
      
      String[] label = { "Bay X","Bay Y","Feed","Kill" };
      for (int i = 0; i < 4; ++i) {
        pdf.text(label[i]                  ,1000+i*500,40);
        pdf.text( "Black : " + params.b[i] ,1000+i*500,80);
        pdf.text( "White : " + params.w[i] ,1000+i*500,120);
      }

      pdf.dispose();
      pdf.endDraw();
    }
    if ( extention[3].equals(extField.getSelectedItem()) ) { 
      svgConverter( render(src, int(params.o[2]*src.width/100)*2 ), 1, path + ".svg" );
    }
  }
}


void saveImage ( PImage img, String path ) {

  PGraphics pg = null ;
  pg = createGraphics(img.width, img.height); 
  pg.beginDraw();
  pg.image(img,0,0);
  pg.endDraw();
  pg.get().save( path );
  gui.message("image file saved");
}

void fileSelected(File selection) { 
  if (selection !=null) {
    lastPath = selection.getAbsolutePath(); 
    PImage tmp = loadImage(lastPath);
    tmp.filter(GRAY);
    src = createImage(tmp.width, tmp.height, ALPHA);
    src.copy(tmp,0,0,src.width, src.height,0,0,src.width, src.height);
    w = src.width;
    h = src.height;
    gui.update();
    gui.elements.get(0).scroll(-1);
    viewing = true ;
    params.o[2] = (int)map(w+h,1000,10000,150,20) ; // setup a proper dithering resolution
    if (params.o[2]<5) params.o[2]=5;
    if (params.o[2]>255) params.o[2]=255;
  }
}
void folderSelected(File selection) {
  if ( selection !=null ) {

    File viewFile = null;
    File[] files = selection.listFiles();

    for ( File file : files ) {
      if ( file.isFile() && validImageFile( file ) ) {
        gui.listOfFiles.add( file );
        viewFile = file;
      }
    }
    if ( viewFile !=null ){
      fileSelected( viewFile );
      gui.state = "multiFiles";
      gui.message(gui.listOfFiles.size()+" images loaded");
    }
  }
}
