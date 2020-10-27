import javax.swing.*;
import java.awt.event.*;
import java.awt.BorderLayout;
import java.awt.image.BufferedImage;
import gifAnimation.*;
GifMaker gifExport;
import drop.*; SDrop drop; MyDropListener dropListener;
import org.apache.commons.io.FilenameUtils;

boolean control = false, viewing = false, threshold = true, lastFrameAnimation = false, isRendering = false ;
boolean killRender = false;
boolean synchroScroll = false;
boolean updateViewImg = false, updateMessage = false ;
PImage src ;
int h,w, off, offX, offY, viewSize=100, renderProgress=0 ;
float lastRenderTime;

int lastExportWidth = 0;
String loadedFileName = "";
File lastDirectory = null;

GuiWindow gui ;
Parameters params ;
int listenerWidth, listenerHeight;

void settings() { size( displayWidth, displayHeight ); }
void setup() {
  listenerHeight=height; listenerWidth=width;
  frameRate(30);
  params = new Parameters();
  gui = new GuiWindow(); gui.setupGui();
  fileSelected( new File(dataPath("Jaguar.jpg")) );
  params.loadFile( new File(dataPath("default.texturing")) );
}

void draw() {
    resizeListener();

    gui.elements.get(9).update(); // diSlider
    if ( synchroScroll ) gui.elements.get(0).dragged();

    if ( viewing || updateViewImg )  gui.elements.get(0).update();
    if ( updateViewImg ) updateViewImg = false;
    if ( updateMessage ) {
        updateMessage = false;
        gui.elements.get(1).update();
        gui.elements.get(21).update(); // update render
    }
}
void mousePressed (){ gui.injectMousePressed (); }
void mouseReleased(){ gui.injectMouseReleased(); }
void mouseMoved()   { gui.injectMouseMoved ();  }
void mouseDragged() { gui.injectMouseDragged (); }
void mouseWheel(processing.event.MouseEvent event) { gui.injectMouseWheel(event.getCount()); }
void keyReleased(){ control = false; }
void resizeListener(){
  if (listenerWidth!=width || listenerHeight!=height) {  // resize listener
  	if( width<800 ) surface.setSize(800,height);
  	if( height<700 ) surface.setSize(width,700);
    listenerWidth=width; listenerHeight=height;
    gui.resize();
    gui.update();
  }
}

void exportImage() {
  String[] extention = { ".png     image", ".gif     animation", ".pdf     vectors", ".svg     vectors" };
  JTextField nameField = new JTextField(30); nameField.setText( loadedFileName + "_TexTuring-"+int(random(9999)) );
  JTextField widthField = new JTextField(5);
  int advisedWidth = constrain(params.o[2]*src.width/50,2000,20000);
  widthField.setText( ""+ int( (advisedWidth>lastExportWidth||lastExportWidth==0)? advisedWidth:lastExportWidth )  );
  JComboBox extField = new JComboBox( new DefaultComboBoxModel(extention) );
  JFileChooser pathField = new JFileChooser();

  if (lastDirectory != null) pathField.setCurrentDirectory( lastDirectory );
  pathField.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);

  JPanel p1 = new JPanel(new FlowLayout(FlowLayout.LEFT)); p1.add(pathField);
  JPanel p2 = new JPanel(new FlowLayout(FlowLayout.LEFT));
  JPanel p3 = new JPanel(new FlowLayout(FlowLayout.LEFT));
  p2.setBorder(BorderFactory.createEmptyBorder(50,20,5,5));
  p3.setBorder(BorderFactory.createEmptyBorder(0,20,5,5));
  p2.add(new JLabel("Image width : ")); p2.add(widthField); p2.add(new JLabel(" pixels"));
  p3.add(new JLabel("Image name : ")); p3.add(nameField); p3.add(extField);
  JPanel outer = new JPanel(new BorderLayout());
  outer.add(p1, BorderLayout.NORTH);
  outer.add(p2, BorderLayout.CENTER);
  outer.add(p3, BorderLayout.SOUTH);

  int result = JOptionPane.showConfirmDialog(null, outer, "Select export options", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
  if (result == JOptionPane.OK_OPTION) {

    if( int(widthField.getText()) != advisedWidth ){ lastExportWidth = int(widthField.getText()); } else { lastExportWidth = 0; } //save width field
    lastDirectory = pathField.getCurrentDirectory();
    String path = pathField.getCurrentDirectory() + File.separator + nameField.getText() ;

    if(extention[2].equals(extField.getSelectedItem())) gifExport = new GifMaker(this, path + ".gif" );
    new ExportThread(path, int(widthField.getText()), split((String)extField.getSelectedItem(),' ')[0] ).start();
    isRendering = true;
  }
}

class ExportThread extends Thread{
    String path;
    String ext;
    int widthField;

    public ExportThread(String path, int widthField, String ext ){
        this.path = path;
        this.ext = ext;
        this.widthField = widthField;
    }

    public void run(){
        if ( ext.equals(".png") ) {

            if( gui.state == "multiFiles" ){
                if( gui.elements.get(7).isSnaped() )
                params.loadParameters( gui.elements.get(7).savedParams );

                for ( int i=0; i < gui.listOfFiles.size(); ++i ) {
                    src = loadImage( gui.listOfFiles.get(i).getAbsolutePath() );
                    if( gui.elements.get(8).isSnaped() )
                    params.nextFrameAnimation( gui.listOfFiles.size(), gui.elements.get(8).savedParams );
                    saveImage( render(src.get(), widthField, "export"), path + File.separator + gui.listOfFiles.get(i).getName() );
                }
            } else {
                saveImage( render(src.get(), widthField, "export") , path + ".png" );
            }
        }

        if ( ext.equals(".gif") ) {
            // second message box to get gif export infos
            JPanel p3 = new JPanel();
            JPanel p4 = new JPanel();
            JTextField nbrFrameField = new JTextField(4); nbrFrameField.setText( "10" );
            p3.add(nbrFrameField);
            p3.add(new JLabel("<html> frames from <i>begining sample</i> to <i>ending sample</i></html>"));
            JTextField durationField = new JTextField(4); durationField.setText( "0.06" );
            p4.add(durationField);
            p4.add(new JLabel("<html> seconds per frame</html>"));
            JPanel outer2 = new JPanel(new BorderLayout());
            outer2.add(p3, BorderLayout.NORTH);
            outer2.add(p4, BorderLayout.SOUTH);

            int result2 = JOptionPane.showConfirmDialog(null, outer2, "Animation export options", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
            if (result2 == JOptionPane.OK_OPTION) {
                gifExport.setRepeat(0); // infinite
                gifExport.setQuality(10); // default 10

                if( gui.elements.get(7).isSnaped() )
                params.loadParameters( gui.elements.get(7).savedParams );

                // render every frames
                for (int i=0; i < int(nbrFrameField.getText()); ++i) {

                    PImage gifImg =  render(src.get(), widthField*3, "export") ;
                    gifImg.resize( widthField,0);
                    gifExport.addFrame( gifImg );
                    gifExport.setDelay( int( float( durationField.getText() )*1000 ) ); // convert sec to ms
                    params.nextFrameAnimation( int( nbrFrameField.getText() ), gui.elements.get(8).savedParams );
                }
                gifExport.finish();
            }
        }

        if ( ext.equals(".pdf") ) {
            vectorization( render(src.get(), int(params.o[2]*src.width/100)*5, "export"), path + ".pdf",1 );
        }
        if ( ext.equals(".svg") ) {
            vectorization( render(src.get(), int(params.o[2]*src.width/100)*5, "export"), path + ".svg",2 );
        }
        gui.message(path + ext + "   file saved.");
        isRendering = false;
        ((ViewPort)gui.elements.get(0)).frameAnimation();
    }
}

void saveImage ( PImage img, String path ) {
  PGraphics pg = null ;
  pg = createGraphics(img.width, img.height);
  pg.beginDraw();
  pg.image(img,0,0);
  pg.endDraw();
  pg.get().save( path );
}

void fileSelected(File selection) {
  if (selection !=null) {
    loadedFileName =  FilenameUtils.removeExtension( selection.getName() );
    PImage tmp = loadImage( selection.getAbsolutePath() );
    tmp.filter(GRAY);
    src = createImage(tmp.width, tmp.height, ALPHA);
    src.copy(tmp,0,0,src.width, src.height,0,0,src.width, src.height);
    w = src.width;
    h = src.height;
    gui.update();
    gui.elements.get(0).scroll(-1);
    viewing = true ;
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
