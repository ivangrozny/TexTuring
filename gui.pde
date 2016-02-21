boolean isOver (float x, float y, float w, float h) {
  if (mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h) { return true ; }
  else { return false ; }
}
/////////////////////////////////////////////////////////////////////////////////
class GuiElement {
  Rect coords;
  String name;
  int ref;
  boolean isOver = false;

  GuiElement(){
    coords = new Rect();
  }
  GuiElement(Rect _coords, String _name){
    coords = _coords;
    name = _name;
    if (name=="iterations") ref = 0 ;
    if (name=="reaction") ref = 6 ;
    if (name=="diffusion") ref = 7 ;
  }

  boolean isOver() {
    return coords.isOver(mouseX, mouseY);
  }

  void update() {  }
  //callbacks for injecting events
  void updateImg() {  }   //// only for DiSlider
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

class Button extends GuiElement {

  Button(Rect _coords, String _name) { 
    super(_coords, _name);
    update();
  }

  void update(){
    fill( isOver() ? C[12] : C[17] ); 
    drawRect(coords);

    fill(colorFont); 
    text(name, coords.pos.x + 5, coords.pos.y + 15);
  }

  void pressed() {
    if ( name == "new file" ) { noLoop(); selectInput("Select your image", "fileSelected"); viewing = true ; } 
    if ( name == "export" ) { render(); selectFolder("Select a folder to process:", "folderSelected"); }       
    if ( name == "load" ) { noLoop();  selectInput( "Select TexTuring settings file", "loadParameters"); viewing = true ; } 
    if ( name == "save" ) { noLoop();  selectOutput("Name your TexTuring settings file", "saveParameters"); } 
    if ( name == "specimen" ) { noLoop(); selectOutput("Nomez votre spécimen", "saveSpecimen"); }
    if ( name == "render" ) { render(); }
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
    if (press) di.updateImg();
    press = false;  
  }
  void dragged () {
    if ( press ) {
      int off = (control) ? 20 : 1 ;
      int m = mouseX ;
      slider[ref] = constrain(slider[ref] + map(m-pos,0,w,0,range)/off , 0, range);
      pos = m; 
      update(); 
      viewing = true ; 
    }
  }
  void update(){
    float sli = slider[ref]*w/range;
    Vector2 s = new Vector2(coords.size);

    fill( isOver() ? C[12] : C[17] ); 
    drawRect(coords);
    pushMatrix(); translate(coords.pos.x, coords.pos.y);
        fill(C[15]); rect(0, 3, sli, s.y-6); // slider
        fill(colorFont); 
        text(name, 0 , -10);
        text(nfs(sli,0,1), sli, s.y-3-4);  // number display
    popMatrix();
  }  
}

class MapImg {
  char over = 'n'; int x,y,mX,mY;
  MapImg (int tx, int ty){ y=ty; x=tx; mX=x+40; mY=y+40;}
  void mouved(){ 
    if ( isOver(x, y, srcMin.width, srcMin.height) ){ 
      over='a'; update(); 
    }else if (over=='a') { 
      over='n'; update(); 
      }  
    }
  void dragged(){
    if ( mouseX>x && mouseX<a+x && mouseY>y && mouseY<a+y && di.zone == 0 ) {  // pre-view position
      viewX = constrain( (mouseX-x)*w/srcMin.width -viewSize/2 ,0,w-viewSize-1) ; 
      viewY = constrain( (mouseY-y)*h/srcMin.height-viewSize/2 ,0,h-viewSize-1) ;
      mX = mouseX ; 
      mY = mouseY ;
      update();
      viewing = true ;
    } 
  }
  void update(){
    image(srcMin, x, y);
    styleSelecStroke(); if(over=='a') stroke(colorActive); strokeWeight(2.5);
    rect(constrain( mX-viewSize*srcMin.width/w/2, x+1, x+srcMin.width-viewSize*srcMin.width/w -2), 
         constrain( mY-viewSize*srcMin.width/w/2,   y+1,   y+srcMin.height-viewSize*srcMin.width/w -2), 
        viewSize*srcMin.width/w, viewSize*srcMin.width/w
    ); strokeWeight(1); noStroke();
  }
}

class Snap extends GuiElement {
  PImage snap, tmp1, tmp2;
  String[] snapVar = new String[8];

  Snap (Rect _coords, String _name) { 
    super(_coords, _name);
    update();
  }
  void pressed (){
    if(snap==null && currentI!=null) {  // save snap
      snap = currentI.get(); 
      for (int i = 0; i<8; i++){ 
        snapVar[i] = slider[i]+" "+knob[i] ; 
      }
      tmp1 = snap.get();
      tmp1.resize( srcMin.width/2, srcMin.height/2 );
      tmp2 = snap.get( snap.width/2, snap.height/2, srcMin.width/2, srcMin.height/2 );
      fill(C[25]); drawRect(coords);
    }
    if (snap!=null) {  // load snap
      currentI = snap;
      image(currentI, 3*a+35+d, d ); // draw view
      setParam(snapVar);
    }      
    viewing = true ;
    // TODO : delete snap
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

  BiSlider(Rect _coords, String _name){
    super(_coords, _name);
    update();
  }

  void pressed (){
    if ( handle[0].isOver() ) { zone=1; pos1=mouseX; } // top
    if ( handle[1].isOver() ) { zone=2; pos2=mouseX; } // bottom
    if ( handle[2].isOver() ) { zone=3; pos3=mouseX; } // center
  }
  void released (){ 
    if ( zone!=0 ) di.updateImg();
    zone = 0;  
  }
  void dragged () {
    if ( zone!=0 ) {
      m   = mouseX ;
      off = (control) ? 20 : 1 ;
      if ( zone==1 ) { // top
        slider[ref] += (m-pos1)/off;    pos1=m; 
        slider[ref] = constrain(slider[ref], 0, coords.size.x-10);
      }
      if ( zone==2 ) { // bottom
        knob[ref] += (m-pos2)/off;  pos2=m; 
        knob[ref] = constrain(knob[ref], 0, coords.size.x-10);
      }
      if ( zone==3 ) { // center
        slider[ref] += (m-pos3)/off ;
        knob  [ref] += (m-pos3)/off ;
        slider[ref] = constrain(slider[ref], 0, coords.size.x-10);
        knob  [ref] = constrain(knob  [ref], 0, coords.size.x-10);
        pos3 = m;
      }
      update(); 
      viewing = true ;
    }
  } 
  void update(){
    float sli = slider[ref]; 
    float kno = knob[ref];
    handle[0] = new Rect( coords.pos.x+sli-18, coords.pos.y+0,  36, sh-3 );
    handle[1] = new Rect( coords.pos.x+kno-18, coords.pos.y+2*sh+3, 36, sh-3 );
    handle[2] = new Rect( coords.pos.x, coords.pos.y+sh+3, coords.size.x-10, sh-6 );
    fill(colorElemBg); rect(coords.pos.x-18,coords.pos.y,coords.size.x+26,3*sh);  //bg
    fill(handle[2].isOver() ? C[18] : C[20] ); drawRect(handle[2]); // bg slide
    fill(C[15]); if (handle[0].isOver() || handle[2].isOver()) fill(colorActive); drawRect(handle[0]); // top cursor box
    fill(C[15]); if (handle[1].isOver() || handle[2].isOver()) fill(colorActive); drawRect(handle[1]); // bottom
    pushMatrix(); translate(coords.pos.x, coords.pos.y); 
        fontColor(); text(name, 0 , -10); textAlign(CENTER);
        fill(0); triangle(sli-18, sh-3, sli+18, sh-3, sli, sh+3); // top
        fill(255); triangle(kno-18, 2*sh+3, kno+18, 2*sh+3, kno, 2*sh-3); // bottom
        fontColor(); 
        text(nfs(sli,0,1), sli, sh-3-4);
        text(nfs(kno,0,1), kno, 3*sh-4);
          fill(C[15]);
        if(sli<kno) image(gradInvert, sli, sh+3, kno-sli, sh-6);  
        if(sli>=kno)image(grad,       kno, sh+3, sli-kno, sh-6); 
    popMatrix(); textAlign(LEFT);
  }  
}

class DiSlider extends GuiElement { 
  Rect handle[] = new Rect[2];
  float pos1, pos2, pos3, pos11, pos22, pos33, zone ; 
  PImage mapImg = createImage(100, 100, ARGB); 
  String name2;

  DiSlider(Rect _coords, String _name, String _name2){ 
    super(_coords, _name);
    name2 = _name2;
    updateImg();
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
    float sli5 = coords.size.x-slider[5]; float kno5 = coords.size.x-knob[5];
    off = (control) ? 20 : 1 ;
    if ( zone==1 || zone==3 ) { // top black
      slider[4] += (mouseX-pos1)/off;    pos1=mouseX; 
      slider[5] -= (mouseY-pos11)/off;   pos11=mouseY; 
      slider[4] = constrain(slider[4], 0, coords.size.x-20);
      slider[5] = constrain(slider[5], 0, coords.size.x-20);
    }
    if ( zone==2 || zone==3 ) { // bottom white
      knob[4] += (mouseX-pos2)/off;  pos2=mouseX; 
      knob[5] -= (mouseY-pos22)/off; pos22=mouseY; 
      knob[4] = constrain(knob[4], 0, coords.size.x-20);
      knob[5] = constrain(knob[5], 0, coords.size.x-20);
    }
    if ( zone!=0 ) update();
    viewing = true ;
  }
  void updateImg () { map=true; turing2(mapImg); map=false; update();}
  void update () {
    float x=coords.pos.x, y=coords.pos.y, s=coords.size.x, sh=coords.size.y ;
    
    handle[0] = new Rect( x+slider[4]-10, y+map(slider[5],0,s,s,0)-10, 20, 20 );
    handle[1] = new Rect( x+  knob[4]-10, y+map(  knob[5],0,s,s,0)-10, 20, 20 );
    float sli5 = s-slider[5]; float kno5 = s-knob[5];  // invert 0->200 to 200->0

    pushMatrix(); translate(x, y);
      fill(C[25]); rect(-36,s,50,50 ); //bg cleaner //// utile?
      fill(colorElemBg); rect(-20,0,s+40,s+40 ); //bg
      image(mapImg, 0,20,s-20,s-20);
      strokeWeight(5);
        stroke(C[12]); if (handle[0].isOver() && coords.isOver()) stroke(colorActive); ellipse(slider[4], sli5, 15, 15);  // top
        stroke(C[12]); if (handle[1].isOver() && coords.isOver()) stroke(colorActive); ellipse(knob  [4], kno5, 15, 15);  // bottom
      strokeWeight(1); noStroke();
      for (int i = 0; i<=20; i++){
        fill(255/20*i);
        ellipse(slider[4]+i*(knob[4]-slider[4])/20, sli5+i*(kno5-sli5)/20, 10,10);
      }
    popMatrix();
    setupSlider(4, name, x, y+s+10, s-10);
    setupSlider(5, name2, x+s-10, y+s, s-10);
  } 
  void setupSlider(int ref, String name, float xx, float yy, float s){ 
    int sh=15;
    float sli = slider[ref]; float kno = knob[ref];
    pushMatrix(); translate(xx, yy); if(ref==5)rotate(-PI/2);
    fontColor(); text(name, 0 , 50); 
    fill(C[18]); rect(0,0,s-10,sh-6); // bg slide
    if ( abs(sli-kno)<36 ) {
      float mid = (sli<kno) ? sli+(kno-sli)/2 : kno+(sli-kno)/2 ;
      if (sli<kno) { fill(0); triangle(mid, sh, mid-36, sh, sli, sh-6); fill(255); triangle(mid, sh, mid+36, sh, kno, sh-6); }
      if (sli>=kno) {fill(0); triangle(mid, sh, mid+36, sh, sli, sh-6); fill(255); triangle(mid, sh, mid-36, sh, kno, sh-6); }
        fill(C[18]);
      rect(mid, sh, -36,sh); rect(mid, sh, 36,sh); // cursor box

        fontColor(); textAlign(CENTER); 
      if(sli<kno){ text(nfs(sli,0,1), mid-18, 2*sh-4); text(nfs(kno,0,1), mid+18, 2*sh-4);
      } else {     text(nfs(sli,0,1), mid+18, 2*sh-4); text(nfs(kno,0,1), mid-18, 2*sh-4); }
      if(sli<kno) image (gradInvert, sli, 0, kno-sli, sh-6);  
      if(sli>=kno)image (grad,       kno, 0, sli-kno, sh-6); 
    } else {
      fill (0);   triangle ( sli-18, sh, sli+18, sh, sli, sh-6); // top
      fill (255); triangle ( kno-18, sh, kno+18, sh, kno, sh-6); // bottom
        fill(C[18]);
      rect ( sli-18, sh, 36,sh ); // cursor box
      rect ( kno-18, sh, 36,sh );
        fontColor(); textAlign(CENTER);
      text ( nfs(sli,0,1), sli, 2*sh-4);
      text ( nfs(kno,0,1), kno, 2*sh-4);
      if(sli<kno) image(gradInvert, sli, 0, kno-sli, sh-6);  
      if(sli>=kno)image(grad,       kno, 0, sli-kno, sh-6);        
    }
    popMatrix(); textAlign(LEFT);
  } 
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
color bg = #EDEDED;
color colorElemBg = color(210);
//color colorOver = color();
color colorActive = #ff7f09; //#fc3011; //fc622a;
color colorFont = #002645;
int a = 200, b = 5, c = 20, d = 10, haut = 60, gauche = 65;
void styleSelecStroke(){ stroke(C[15]); noFill(); }
void styleSelec(){ fill(C[15]); noStroke(); }
void fontColor(){ fill(#002666); }

void style2 () {
  ControlFont cFont = new ControlFont(font,12);
  checkbox.getCaptionLabel().setFont(cFont).toUpperCase(false);
  checkbox.setColorBackground(C[18]);
  checkbox.setColorForeground(C[12]);
  checkbox.setColorActive(C[15]);
}
/////////////////////////////////////////////////////////////////////////////////////////////
