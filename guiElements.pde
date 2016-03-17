class GuiElement {
  Rect coords;
  String name;
  int ref;
  boolean isOver = false;
  boolean isVisible = true;

  GuiElement(){
    coords = new Rect();
  }
  GuiElement(Rect _coords, String _name){
    coords = _coords;
    name = _name;
    if (name=="iterations") ref = 0 ;
    if (name=="threshold") ref = 1 ;
    if (name=="reaction") ref = 2 ;
    if (name=="diffusion") ref = 3 ;
  }

  boolean isOver() {
    return coords.isOver(mouseX, mouseY);
  }

  void update() {  }
  //callbacks for injecting events
  void mouved() { update(); }
  void pressed() {  }
  void released() {  }
  void dragged() {  }
  //helpers to uniformize ways of drawings things
  void drawRect( Rect r) {
     rect(r.pos.x, r.pos.y,r.size.x,r.size.y); 
  }
  void drawText( Rect r, String text) {
     text(text, coords.pos.x + 5, coords.pos.y);
  }
}


class Menu extends GuiElement {

String[] names;
Rect zone;
  Menu(Rect _coords, String[] _names) { 
    super(_coords, _names[0]);
    names = new String[_names.length];
    arrayCopy( _names, names );
    for (int i = 1; i<names.length; i++){
      Rect _rect = new Rect( coords );
      _rect.pos.y += coords.size.y * i ;
      gui.elements.add( new Button(_rect, names[i] ) );
    }
    zone = new Rect( coords );
    zone.size.y = coords.size.y * names.length ;
    update();
  }
  void update(){ 
    fill( isOver() ? C[14] : C[15] ); 
    drawRect(coords);
    fill(colorFont); 
    text(name, coords.pos.x + 5, coords.pos.y + 15);
    for (int i = 1; i<names.length; i++){
      for (GuiElement _elem : gui.elements) {
        if ( _elem.name == names[i] ){
          if ( isOver() ) _elem.isVisible = true ;
          if ( !zone.isOver() ) _elem.isVisible = false ;
        }
      }
    }
  }
  void pressed() {
    buttonPressed( this );
  }
}


class Button extends GuiElement {
  
  Button(Rect _coords, String _name) { 
    super(_coords, _name);
    update();
  }
  void update(){
    if (isVisible){
      fill( isOver() ? C[12] : C[17] ); 
      drawRect(coords);
      fill(colorFont); 
      text(name, coords.pos.x + 5, coords.pos.y + 15);
    }else{      
      fill(C[25]); 
      drawRect(coords);
    }
  }
  void pressed() {
    buttonPressed( this );
  }
}


class CheckBox extends GuiElement {
  boolean b = false;
  CheckBox(Rect _coords, String _name) { 
    super(_coords, _name);
    update();
  }
  void update(){
    fill( isOver() ? C[12] : C[17] ); 
    drawRect(coords);
    fill( b ? C[0] : C[10] ); 
    rect(coords.pos.x+3, coords.pos.y+3, coords.size.x-6, coords.size.y-6);
  }
  void pressed() {
    buttonPressed( this );
    b = !b ;
  }
}


class Slider extends GuiElement {
  int range; 
  float pos; 
  boolean press = false;
  
  Slider(Rect _coords, String _name, int _range){ 
    super(_coords, _name);
    range = _range;
    update();
  }
  void pressed (){
    press = true; 
    pos = mouseX;
  }
  void released (){ 
    if (press) updateDiSliderImage = true;
    press = false;  
  }
  void dragged () {
    if ( press ) {
      int off = (control) ? 20 : 1 ;
      int m = mouseX ;
      params.o[ref] = (int)constrain(params.o[ref] + map(m-pos,0,w,0,range)/off , 0, range);
      pos = m; 
      update(); 
      viewing = true ; 
    }
  }
  void update(){
    float b = params.o[ref]*w/range;
    Vector2 s = new Vector2(coords.size);

    fill( isOver() ? C[12] : C[17] ); 
    drawRect(coords);
    pushMatrix(); translate(coords.pos.x, coords.pos.y);
        fill(C[15]); rect(0, 3, b, s.y-6); // Slider
        fill(colorFont); 
        text(name, 0 , -10);
        text(nfs(b,0,1), b, s.y-3-4);  // number display
    popMatrix();
  }  
}


class MapImg extends GuiElement {
  Vector2 viewPos ;
  MapImg (Rect _coords) { 
    super(_coords, "mapImg");
    viewPos = new Vector2(0,0);
  }

  void dragged(){
    if ( isOver() ) {  // pre-view position
      viewX = (int)constrain( (mouseX-coords.pos.x)*w/srcMin.width -viewSize/2 ,0,w-viewSize-1) ; 
      viewY = (int)constrain( (mouseY-coords.pos.y)*h/srcMin.height-viewSize/2 ,0,h-viewSize-1) ;
      viewPos.x = mouseX ; 
      viewPos.y = mouseY ;
      update();
      viewing = true ;
    } 
  }

  void update(){
    coords.size.x = srcMin.width;
    coords.size.y = srcMin.height;
    fill(bg); rect(gauche,haut,a,a);
    image(srcMin, coords.pos.x, coords.pos.y);
    styleSelecStroke(); if ( isOver() ) stroke(colorActive); strokeWeight(2.5);
    rect(constrain( viewPos.x-viewSize*srcMin.width/w/2, coords.pos.x+1, coords.pos.x+srcMin.width-viewSize*srcMin.width/w -2), 
         constrain( viewPos.y-viewSize*srcMin.width/w/2, coords.pos.y+1, coords.pos.y+srcMin.height-viewSize*srcMin.width/w -2), 
        viewSize*srcMin.width/w, viewSize*srcMin.width/w
    ); strokeWeight(1); noStroke();
  }
}


class Snap extends GuiElement {
  PImage snap, tmp1, tmp2;
  Parameters savedParams = new Parameters();

  Snap (Rect _coords, String _name) { 
    super(_coords, _name);
    update();
  }
  void pressed (){
    if(snap==null && currentI!=null) {  // save snap
      savedParams.loadParameters( params );

      snap = currentI.get(); 
      tmp1 = snap.get();
      tmp1.resize( srcMin.width/2, srcMin.height/2 );
      tmp2 = snap.get( snap.width/2, snap.height/2, srcMin.width/2, srcMin.height/2 );
      fill(C[25]); drawRect(coords);
    }
    if (snap!=null) {  // load snap
      params.loadParameters( savedParams );
      gui.update();
      currentI = snap;
      image(currentI, 3*a+35+d, d ); // draw view
    }      
    viewing = true ;
    // TODO : delete snap function
  }
  void update(){
    if(snap==null){
      fill( isOver() ? C[12] : C[17] ); 
      drawRect(coords);
    }else{
      PImage off = isOver() ? tmp2 : tmp1 ; 
      image(off, coords.pos.x, coords.pos.y);
    }
  }
}



class BiSlider extends GuiElement {
  int m, sh=20; 
  float pos1, pos2, pos3, zone; 
  Rect handle[] = new Rect[3];
  PImage grad, gradInvert;

  BiSlider(Rect _coords, String _name){
    super(_coords, _name);
    grad = loadImage("gradient.png"); gradInvert = loadImage("gradInvert.png");
    update();
  }

  void pressed (){
    if ( handle[0].isOver() ) { zone=1; pos1=mouseX; } // top
    if ( handle[1].isOver() ) { zone=2; pos2=mouseX; } // bottom
    if ( handle[2].isOver() ) { zone=3; pos3=mouseX; } // center
  }
  void released (){ 
    if ( zone!=0 ) updateDiSliderImage = true ;
    zone = 0;  
  }
  void dragged () {
    if ( zone!=0 ) {
      m   = mouseX ;
      off = (control) ? 20 : 1 ;
      if ( zone==1 ) { // top
        params.b[ref] += (m-pos1)/off;    pos1=m; 
        params.b[ref] = constrain(params.b[ref], 0, coords.size.x-10);
      }
      if ( zone==2 ) { // bottom
        params.w[ref] += (m-pos2)/off;  pos2=m; 
        params.w[ref] = constrain(params.w[ref], 0, coords.size.x-10);
      }
      if ( zone==3 ) { // center
        params.b[ref] += (m-pos3)/off ;
        params.w[ref] += (m-pos3)/off ;
        params.b[ref] = constrain(params.b[ref], 0, coords.size.x-10);
        params.w[ref] = constrain(params.w[ref], 0, coords.size.x-10);
        pos3 = m;
      }
      update(); 
      viewing = true ;
    }
  } 
  void update(){
    float b = params.b[ref]; 
    float w = params.w[ref];
    handle[0] = new Rect( coords.pos.x+b-18, coords.pos.y+0,  36, sh-3 );
    handle[1] = new Rect( coords.pos.x+w-18, coords.pos.y+2*sh+3, 36, sh-3 );
    handle[2] = new Rect( coords.pos.x, coords.pos.y+sh+3, coords.size.x-10, sh-6 );
    fill(colorElemBg); rect(coords.pos.x-18,coords.pos.y,coords.size.x+26,3*sh);  //bg
    fill(handle[2].isOver() ? C[18] : C[20] ); drawRect(handle[2]); // bg bde
    fill(C[15]); if (handle[0].isOver() || handle[2].isOver()) fill(colorActive); drawRect(handle[0]); // top cursor box
    fill(C[15]); if (handle[1].isOver() || handle[2].isOver()) fill(colorActive); drawRect(handle[1]); // bottom
    pushMatrix(); translate(coords.pos.x, coords.pos.y); 
        fontColor(); text(name, 0 , -10); textAlign(CENTER);
        fill(0); triangle(b-18, sh-3, b+18, sh-3, b, sh+3); // top
        fill(255); triangle(w-18, 2*sh+3, w+18, 2*sh+3, w, 2*sh-3); // bottom
        fontColor(); 
        text(nfs(b,0,1), b, sh-3-4);
        text(nfs(w,0,1), w, 3*sh-4);
          fill(C[15]);
        if(b<w) image(gradInvert, b, sh+3, w-b, sh-6);  
        if(b>=w)image(grad,       w, sh+3, b-w, sh-6); 
    popMatrix(); textAlign(LEFT);
  }  
}



class DiSlider extends GuiElement { 
  Rect handle[] = new Rect[2];
  float pos1, pos2, pos3, pos11, pos22, pos33, zone ; 
  PImage mapImg = createImage(100, 100, ARGB); 
  PImage grad, gradInvert;
  String name2;

  DiSlider(Rect _coords, String _name, String _name2){ 
    super(_coords, _name);
    name2 = _name2;
    grad = loadImage("gradient.png"); gradInvert = loadImage("gradInvert.png");
    updateDiSliderImage = true;
    update();
  }
  void pressed (){
    if ( coords.isOver() )    { zone=3; pos1=mouseX; pos11=mouseY; pos2=mouseX; pos22=mouseY; } // center
    if ( handle[0].isOver() ) { zone=1; pos1=mouseX; pos11=mouseY; } // top
    if ( handle[1].isOver() ) { zone=2; pos2=mouseX; pos22=mouseY; } // bottom
  }  
  void released () { 
    zone = 0; 
  }
  void dragged () {
    float b5 = coords.size.x-params.b[1]; float w5 = coords.size.x-params.w[1];
    off = (control) ? 20 : 1 ;
    if ( zone==1 || zone==3 ) { // top black
      params.b[0] += (mouseX-pos1)/off;    pos1=mouseX; 
      params.b[1] -= (mouseY-pos11)/off;   pos11=mouseY; 
      params.b[0] = constrain(params.b[0], 0, coords.size.x-20);
      params.b[1] = constrain(params.b[1], 0, coords.size.x-20);
    }
    if ( zone==2 || zone==3 ) { // bottom white
      params.w[0] += (mouseX-pos2)/off;  pos2=mouseX; 
      params.w[1] -= (mouseY-pos22)/off; pos22=mouseY; 
      params.w[0] = constrain(params.w[0], 0, coords.size.x-20);
      params.w[1] = constrain(params.w[1], 0, coords.size.x-20);
    }
    if ( zone!=0 ) update();
    viewing = true ;
  }

  void update () {
    if ( updateDiSliderImage ) {
      turing2(mapImg); 
      updateDiSliderImage = false;
    }

    float x=coords.pos.x, y=coords.pos.y, s=coords.size.x, sh=coords.size.y ;
    
    handle[0] = new Rect( x+params.b[0]-10, y+map(params.b[1],0,s,s,0)-10, 20, 20 );
    handle[1] = new Rect( x+  params.w[0]-10, y+map(  params.w[1],0,s,s,0)-10, 20, 20 );
    float b5 = s-params.b[1]; float w5 = s-params.w[1];  // invert 0->200 to 200->0

    pushMatrix(); translate(x, y);
      fill(C[25]); rect(-36,s,50,50 ); //bg cleaner //// utile?
      fill(colorElemBg); rect(-20,0,s+40,s+40 ); //bg
      image(mapImg, 0,20,s-20,s-20);
      strokeWeight(5);
        stroke(C[12]); if (handle[0].isOver() && coords.isOver()) stroke(colorActive); ellipse(params.b[0], b5, 15, 15);  // top
        stroke(C[12]); if (handle[1].isOver() && coords.isOver()) stroke(colorActive); ellipse(params.w[0], w5, 15, 15);  // bottom
      strokeWeight(1); noStroke();
      for (int i = 0; i<=20; i++){
        fill(255/20*i);
        ellipse(params.b[0]+i*(params.w[0]-params.b[0])/20, b5+i*(w5-b5)/20, 10,10);
      }
    popMatrix();
    setupSlider(0, name, x, y+s+10, s-10);
    setupSlider(1, name2, x+s-10, y+s, s-10);
  } 
  void setupSlider(int ref, String name, float xx, float yy, float s){ 
    int sh=15;
    float b = params.b[ref]; float w = params.w[ref];
    pushMatrix(); translate(xx, yy); 
    if(ref==1)rotate(-PI/2);
    fontColor(); text(name, 0 , 50); 
    fill(C[18]); rect(0,0,s-10,sh-6); // bg bde
    if ( abs(b-w)<36 ) {
      float mid = (b<w) ? b+(w-b)/2 : w+(b-w)/2 ;
      if (b<w) { fill(0); triangle(mid, sh, mid-36, sh, b, sh-6); fill(255); triangle(mid, sh, mid+36, sh, w, sh-6); }
      if (b>=w) {fill(0); triangle(mid, sh, mid+36, sh, b, sh-6); fill(255); triangle(mid, sh, mid-36, sh, w, sh-6); }
        fill(C[18]);
      rect(mid, sh, -36,sh); rect(mid, sh, 36,sh); // cursor box

        fontColor(); textAlign(CENTER); 
      if(b<w){ text(nfs(b,0,1), mid-18, 2*sh-4); text(nfs(w,0,1), mid+18, 2*sh-4);
      } else {     text(nfs(b,0,1), mid+18, 2*sh-4); text(nfs(w,0,1), mid-18, 2*sh-4); }
      if(b<w) image (gradInvert, b, 0, w-b, sh-6);  
      if(b>=w)image (grad,       w, 0, b-w, sh-6); 
    } else {
      fill (0);   triangle ( b-18, sh, b+18, sh, b, sh-6); // top
      fill (255); triangle ( w-18, sh, w+18, sh, w, sh-6); // bottom
        fill(C[18]);
      rect ( b-18, sh, 36,sh ); // cursor box
      rect ( w-18, sh, 36,sh );
        fontColor(); textAlign(CENTER);
      text ( nfs(b,0,1), b, 2*sh-4);
      text ( nfs(w,0,1), w, 2*sh-4);
      if(b<w) image(gradInvert, b, 0, w-b, sh-6);  
      if(b>=w)image(grad,       w, 0, b-w, sh-6);        
    }
    popMatrix(); textAlign(LEFT);
  } 
}

