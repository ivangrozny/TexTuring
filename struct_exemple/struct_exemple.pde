Model model;
GuiWindow gui;

void setup(){
	size(800, 600);
	model = new Model();
	gui = new GuiWindow();
	gui.setModel(model);
	gui.refresh();
}

void draw(){
	gui.render();
}

void mousePressed(){
	gui.injectMouseClick();
  
}


