
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

  boolean isOver(float x, float y) {
    return coords.isOver(x, y);
  }
  void setOver(boolean active) {
    isOver = active;
  }
  void render() {  }
  //callbacks for injecting events
  void onPress() {  }
  //helpers to uniformize ways of drawings things
  void drawRect( Rect r) {
     rect(r.pos.x, r.pos.y,r.size.x,r.size.y); 
  }
  void drawText( Rect r, String text) {
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

  void render() {
    fill(isOver ? skin.frontColor : skin.secondColor);
    drawRect(coords);
    fill(skin.fontColor); 
    drawText(coords, text);
  }
  
  void onPress() {
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
  void render() {
    fill(isOver ? skin.frontColor : skin.secondColor);
    drawRect(coords);
    fill(skin.fontColor); 
    drawText(coords, text);
  }
  
}

