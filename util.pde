
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
  boolean isOver() {
   return isOver(new Vector2(mouseX,mouseY));
  }
  boolean isOver(float x, float y) {
   return isOver(new Vector2(x,y));
  }
  boolean isOver(Vector2 in) {
    if (in.x >= pos.x && in.x <= pos.x+size.x && in.y >= pos.y && in.y <= pos.y+size.y) {
      return true ;
    } else {
      return false ;
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////
void initDrop(){
  drop = new SDrop(this);
  dropListener = new MyDropListener();
  drop.addDropListener(dropListener);
}

void dropEvent(DropEvent event) {}

// a custom DropListener class.
class MyDropListener extends DropListener {

  int myColor;

  MyDropListener() {
    myColor = color(255);
    setTargetRect(20,20,width-40,height-40);
  }

  void draw() {
    fill(myColor);
    rect(10,10,100,100);
  }
  void dropEnter() {
    gui.elements.get(0).dropState = true;
    viewing = true;
  }
  void dropLeave() {
    gui.elements.get(0).dropState = false;
    viewing = true;
  }

  void dropEvent(DropEvent event) {
    if(event.isFile()) {
      if( event.isImage() )            fileSelected( event.file() );
      if( event.file().isDirectory() ) folderSelected( event.file() );
      if( event.file().getName().toLowerCase().indexOf("texturing") > -1 ) params.loadFile( event.file() );
    }
  }
}
/////////////////////////////////////////////////////////////////////////////////

boolean isOver (float x, float y, float w, float h) {
  if (mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h) { return true ; }
  else { return false ; }
}

boolean validImageFile(File file){
  boolean isValid = false ;
  String fileName = file.getName().toLowerCase();
  String[] ext = { ".gif", ".jpg", ".tga", ".png" };
  for (String o : ext) {
    if ( fileName.endsWith(o) )
      isValid = true;
  }
  return isValid ;
}


/////////////////////////////////////////////// url link (about)
import java.awt.Cursor;
import java.awt.Desktop;
import java.awt.EventQueue;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;

public class SwingLink extends JLabel {
  private static final long serialVersionUID = 8273875024682878518L;
  private String text;
  private URI uri;

  public SwingLink(String text, URI uri){
    super();
    setup(text,uri);
  }

  public SwingLink(String text, String uri){
    super();
    setup(text,URI.create(uri));
  }

  public void setup(String t, URI u){
    text = t;
    uri = u;
    setText(text);
    setToolTipText(uri.toString());
    addMouseListener(new MouseAdapter() {
      public void mouseClicked(MouseEvent e) {
        open(uri);
      }
      public void mouseEntered(MouseEvent e) {
        setText(text,false);
        setCursor(new Cursor(Cursor.HAND_CURSOR));
      }
      public void mouseExited(MouseEvent e) {
        setText(text,true);
      }
    });
  }

  @Override
  public void setText(String text){
    setText(text,true);
  }

  public void setText(String text, boolean ul){
    String link = ul ? "<u>"+text+"</u>" : text;
    super.setText("<html><span style=\"color: #000099;\">"+
    link+"</span></html>");
    this.text = text;
  }

  public String getRawText(){
    return text;
  }

  private void open(URI uri) {
    if (Desktop.isDesktopSupported()) {
      Desktop desktop = Desktop.getDesktop();
      try {
        desktop.browse(uri);
      } catch (IOException e) {
        JOptionPane.showMessageDialog(null,
            "Failed to launch the link, your computer is likely misconfigured.",
            "Cannot Launch Link",JOptionPane.WARNING_MESSAGE);
      }
    } else {
      JOptionPane.showMessageDialog(null,
          "Java is not able to launch links on your computer.",
          "Cannot Launch Link", JOptionPane.WARNING_MESSAGE);
    }
  }
}
