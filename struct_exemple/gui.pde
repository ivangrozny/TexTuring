
static String SEP_ELEM = ":";
static String SEP_SUBELEM = "/";

class GuiSkin {

  color backColor = color(127, 50, 50);
  color frontColor = color(35, 20, 50); 
  color secondColor = color(35, 50, 70);
  color fontColor = color(35, 200, 200);

  String serialize(color _color) {
    String s = str(red(_color));
    s += SEP_SUBELEM;
    s += str(green(_color));
    s += SEP_SUBELEM;
    s += str(blue(_color));
    return s;
  }
  color deserializeColor(String str) {
    return color(127, 50, 50);
  }

  void save(String filename) {
    String str = new String();
    str += serialize(backColor);
    str += SEP_ELEM;
    str += serialize(frontColor);
    str += SEP_ELEM;
  }
  void load(String filename) {
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
  
  void setup() {
    colorMode(HSB);
    frameRate(60);
    background(skin.backColor); 
    noStroke();
  }

  void setupGui() {
    Rect curPlace = new Rect(10, 10, 60, 15);
    addElement(new Button(new Rect(curPlace), "New"));
    curPlace.pos.x += 80;
    addElement(new Button(new Rect(curPlace), "Open"));
    curPlace.pos.x += 80;
    addElement(new Button(new Rect(curPlace), "Save"));
  }

  void render() {
    for (GuiElement elem : elements) {
      elem.setOver(elem.isOver(mouseX, mouseY)); 
      elem.render();
    }
  }

 void injectMouseClick() {
     for (GuiElement elem : elements) {
      if (elem.isOver(mouseX, mouseY)) {
        // an element is pressed
        elem.onPress();
        //stop iterating, we find the elements
        return;
      }
    }
  }
  
  void setModel(Model _model) {
    model = _model;
  }
  void refresh() {
   if (model == null)return;
   
  }

  void addElement(GuiElement _newElement) {
    elements.add(_newElement);
    _newElement.skin = skin;
  }
}



