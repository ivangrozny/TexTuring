import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class struct_exemple extends PApplet {

Model model;
GuiWindow gui;

public void setup(){
	
	model = new Model();
	gui = new GuiWindow();
	gui.setModel(model);
	gui.refresh();
}

public void draw(){
	gui.render();
}

public void mousePressed(){
	gui.injectMouseClick();
  
}



static String SEP_ELEM = ":";
static String SEP_SUBELEM = "/";

class GuiSkin {

  int backColor = color(127, 50, 50);
  int frontColor = color(35, 20, 50); 
  int secondColor = color(35, 50, 70);
  int fontColor = color(35, 200, 200);

  public String serialize(int _color) {
    String s = str(red(_color));
    s += SEP_SUBELEM;
    s += str(green(_color));
    s += SEP_SUBELEM;
    s += str(blue(_color));
    return s;
  }
  public int deserializeColor(String str) {
    return color(127, 50, 50);
  }

  public void save(String filename) {
    String str = new String();
    str += serialize(backColor);
    str += SEP_ELEM;
    str += serialize(frontColor);
    str += SEP_ELEM;
  }
  public void load(String filename) {
  }
}

class GuiWindow {
  ArrayList<GuiElement> elements;
  GuiSkin skin = new GuiSkin();

  Model model;
  
  GuiWindow() {
    elements = new ArrayList<GuiElement>();

    setup();
    setupGui();
  }
  
  public void setup() {
    colorMode(HSB);
    frameRate(60);
    background(skin.backColor); 
    noStroke();
  }

  public void setupGui() {
    Rect curPlace = new Rect(10, 10, 60, 15);
    addElement(new Button(new Rect(curPlace), "New"));
    curPlace.pos.x += 80;
    addElement(new Button(new Rect(curPlace), "Open"));
    curPlace.pos.x += 80;
    addElement(new Button(new Rect(curPlace), "Save"));
  }

  public void render() {
    for (GuiElement elem : elements) {
      elem.setOver(elem.isOver(mouseX, mouseY)); 
      elem.render();
    }
  }

 public void injectMouseClick() {
     for (GuiElement elem : elements) {
      if (elem.isOver(mouseX, mouseY)) {
        // an element is pressed
        elem.onPress();
        //stop iterating, we find the elements
        return;
      }
    }
  }
  
  public void setModel(Model _model) {
    model = _model;
  }
  public void refresh() {
   if (model == null)return;
   
  }

  public void addElement(GuiElement _newElement) {
    elements.add(_newElement);
    _newElement.skin = skin;
  }
}




class GuiElement 
{
  Rect coords;
  GuiSkin skin;

  boolean isOver = false;

  GuiElement(){
    coords = new Rect();
  }
  GuiElement(Rect _coords){
    coords = _coords;
  }

  public boolean isOver(float x, float y) {
    return coords.isOver(x, y);
  }
  public void setOver(boolean active) {
    isOver = active;
  }
  public void render() {  }
  //callbacks for injecting events
  public void onPress() {  }
  //helpers to uniformize ways of drawings things
  public void drawRect( Rect r) {
     rect(r.pos.x, r.pos.y,r.size.x,r.size.y); 
  }
  public void drawText( Rect r, String text) {
     text(text, coords.pos.x + 5, coords.pos.y);
  }
}

class Label extends GuiElement 
{
  String text;
  Label(Rect _coords, String _text) {
    super(_coords);
    text = _text;
  }
}

class Button extends GuiElement 
{
  String text;
  int signal;
  Button(Rect _coords, String _text) {
    super(_coords);
    text = _text;
  }
  Button(Rect _coords, String _text, int _signal) {
    super(_coords);
    text = _text;
    signal = _signal;
  }

  public void render() {
    fill(isOver ? skin.frontColor : skin.secondColor);
    drawRect(coords);
    fill(skin.fontColor); 
    drawText(coords, text);
  }
  
  public void onPress() {
    println("button " + text + " pressed");
  }
}

class Slider extends GuiElement 
{
  float value;
  float maxValue;
  float minValue;
  Slider(Rect _coords, float _value, float _min, float _max) {
    super(_coords);
    value = _value;
    minValue = _min;
    maxValue = _max;
  }
  public void render() {
    fill(isOver ? skin.frontColor : skin.secondColor);
    drawRect(coords);
    fill(skin.fontColor); 
    drawText(coords, text);
  }
  
}



class Model
{
  
  Model() 
  {
    
  }
  
   public void save(String _filename){
   }
   public void load(String _filename){
   }
}

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

  public boolean isOver(float x, float y) {
   return isOver(new Vector2(x,y));
  }
   public boolean isOver(Vector2 in) {
    if (in.x >= pos.x && in.x <= pos.x+size.x && in.y >= pos.y && in.y <= pos.y+size.y)
    { 
      return true ;
    } else 
    { 
      return false ;
    }
  }
}

  public void settings() { 	size(800, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "struct_exemple" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
