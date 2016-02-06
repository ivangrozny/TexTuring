boolean isOver (float x, float y, float w, float h) {
  if (mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h) { return true ; }
  else { return false ; }
}
/////////////////////////////////////////////////////////////////////////////////

class Button {

  int x, y, w, h;
  String name ; 
  boolean over = false;
  Button(int tmpX, int tmpY, int tmpW, int tmpH, String tmpName){ 
    y=tmpY; x=tmpX; w=tmpW; h=tmpH;
    name = tmpName;
    update();
  }

  void mouved(){ 
    over = isOver(x, y, w, h) ;
    update();
  }

  void update(){
    if (over) { fill( C[12] );
    } else {    fill( C[17] ); }
    rect(x,y,w,h);
    fill(colorFont); 
    text(name, x+5, y+15);
  }
}

class MapImg {
  char over = 'n'; int x,y,mX,mY;
  MapImg (int tx, int ty){ y=ty; x=tx; mX=x+40; mY=y+40;}
  void mouved(){ 
    if ( isOver(x, y, srcMin.width, srcMin.height) ){ 
      over='a'; setup(); 
    }else if (over=='a') { 
      over='n'; setup(); 
      }  
    }
  void dragged(){
    if ( mouseX>x && mouseX<a+x && mouseY>y && mouseY<a+y && di.zone == 0 ) {  // pre-view position
      viewX = constrain( (mouseX-x)*w/srcMin.width -viewSize/2 ,0,w-viewSize-1) ; 
      viewY = constrain( (mouseY-y)*h/srcMin.height-viewSize/2 ,0,h-viewSize-1) ;
      mX = mouseX ; 
      mY = mouseY ;
      setup();
      viewing = true ;
    } 
  }
  void setup(){
    image(srcMin, x, y);
    styleSelecStroke(); if(over=='a') stroke(colorActive); strokeWeight(2.5);
    rect(constrain( mX-viewSize*srcMin.width/w/2, x+1, x+srcMin.width-viewSize*srcMin.width/w -2), 
         constrain( mY-viewSize*srcMin.width/w/2,   y+1,   y+srcMin.height-viewSize*srcMin.width/w -2), 
        viewSize*srcMin.width/w, viewSize*srcMin.width/w
    ); strokeWeight(1); noStroke();
  }
}

class Snap {
  String name; int ref, x, y, s, m, sh=20; float pos1, pos2, pos3, zone;
  String[][] snapVar = new String[20][8];
  PImage[] snap = new  PImage[6];
  Button[] snapButton = new Button[snap.length];
  Snap (int tx,int ty){ 
    x=tx; y=ty;
    for (int i = 0; i<snap.length; i++) {  
      snapButton[i] = new Button( x+i%6*(a/2+b), y+floor(i/6)*(a/2+b), a/2, a/2, "snap" );  
    }
  }

  void pressed (int off){
    if ( isOver(x, y, w, h) ){
      if(snap[off]==null && currentI!=null) {  // save snap
        snap[off] = currentI.get(); 
        for (int i = 0; i<8; i++){ snapVar[off][i] = slider[i]+" "+knob[i] ; } 
        PImage tmp1 = snap[off].get();
        tmp1.resize( srcMin.width/2, srcMin.height/2 );
        PImage tmp2 = snap[off].get( snap[off].width/2, snap[off].height/2, srcMin.width/2, srcMin.height/2 );
        // TODO : display snaped img on snapButtons
        //snapButton[off].setImages(tmp1,tmp2,tmp1).hide().setSize(srcMin.width/2, srcMin.height/2).show() ;  //oldway
        fill(C[25]); rect( x+off%6*(a/2+b) , y+floor(off/6)*(a/2+b), a/2, a/2); 
      }
      if (snap[off]!=null) {  // load snap
        currentI = snap[off];
        image(currentI, 3*a+35+d, d ); // ,(currentI.width*(height-d))/currentI.height, height-d); 
        setParam(snapVar[off]);
      }      
      viewing = true ;
    }
  }
}
class MonoSlider {
  String name; int ref, x, y, w, range, m, sh=20; float pos; boolean press = false, over = false;
  MonoSlider(int tref, String tname, int tx, int ty, int tw, int trange){ 
    ref=tref; name=tname; x=tx+10; y=ty; w=tw-10; range=trange;
    setup();
  }
  void mouved(){
    if ( isOver(x, y+sh, w, sh ) ) { over = true ; setup(); }
    else { over = false ; setup(); } 
  }
  void pressed (){
    if ( over ) { press = true; pos = mouseX; }
  }  
  void released (){ 
    if (press) di.setupImg();
    press = false;  
  }
  void dragged () {
    if ( press ) {
      m   = mouseX ;
      off = (control) ? 20 : 1 ;
      slider[ref] += map(m-pos,0,w,0,range)/off;    pos=m; 
      slider[ref] = constrain(slider[ref], 0, range);
      setup(); 
      viewing = true ;
    }
  } 
  void setup(){
    float sli = slider[ref]*w/range;
    pushMatrix(); translate(x, y); 
        fontColor(); text(name, 0 , -10); textAlign(CENTER);
        fill(colorElemBg); rect(-18,0,w+26,3*sh);  //bg
        fill(C[18]); rect(0,sh+3,w-10,sh-6); // bg slider
        text(nfs(sli,0,1), sli, sh-3-4);  // number display
        fill(C[15]); rect(0, sh+3, sli, sh-6); // slider
    popMatrix(); textAlign(LEFT);
  }  
}
class BiSlider {
  String name; int ref, x, y, s, m, sh=20; float pos1, pos2, pos3, zone; char over;
  BiSlider(int tref, String tname,int tx,int ty, int ts){ 
    ref=tref; name=tname; x=tx+10; y=ty; s=ts-10;
    setup();
  }
    void mouved(){
    if      ( isOver(x+slider[ref]-18, y ,     36, sh ) ) { over = 'b' ; setup(); }  // Black handle
    else if ( isOver(x+  knob[ref]-18, y+2*sh, 36, sh ) ) { over = 'w' ; setup(); }  // white handle
    else if ( isOver(x, y+sh, s, sh ) )                   { over = 'a' ; setup(); }  // bolth handle
    else                                                  { over = 'n' ; setup(); }  // none
  }
  void pressed (){
    if ( over == 'b') { zone=1; pos1=mouseX; }
    if ( over == 'w') { zone=2; pos2=mouseX; }
    if ( over == 'a') { zone=3; pos3=mouseX; }
  }  
  void released (){ 
    if (zone!=0) di.setupImg();
    zone=0;  
  }
  void dragged () {
    if ( zone!=0 ) {
      m   = mouseX ;
      off = (control) ? 20 : 1 ;
      if ( zone==1 ) { // top
        slider[ref] += (m-pos1)/off;    pos1=m; 
        slider[ref] = constrain(slider[ref], 0, s-10);
      }
      if ( zone==2 ) { // bottom
        knob[ref] += (m-pos2)/off;  pos2=m; 
        knob[ref] = constrain(knob[ref], 0, s-10);
      }
      if ( zone==3 ) { // center
        slider[ref] += (m-pos3)/off ;
        knob  [ref] += (m-pos3)/off ;
        slider[ref] = constrain(slider[ref], 0, s-10);
        knob  [ref] = constrain(knob  [ref], 0, s-10);
        pos3=m;
      }
      setup(); 
      viewing = true ;
    }
  } 
  void setup(){
    float sli = slider[ref]; float kno = knob[ref];
    pushMatrix(); translate(x, y); 
        fontColor(); text(name, 0 , -10); textAlign(CENTER);
        fill(colorElemBg); rect(-18,0,s+26,3*sh);  //bg
        fill(C[18]); rect(0,sh+3,s-10,sh-6); // bg slide
        fill(0); triangle(sli-18, sh-3, sli+18, sh-3, sli, sh+3); // top
        fill(255); triangle(kno-18, 2*sh+3, kno+18, 2*sh+3, kno, 2*sh-3); // bottom
        fill(C[15]); if(over=='b' || over=='a') fill(colorActive); rect(sli-18, 0,  36,sh-3); // top cursor box
        fill(C[15]); if(over=='w' || over=='a') fill(colorActive); rect(kno-18, 2*sh+3, 36,sh-3); // bottom
          fontColor(); 
        text(nfs(sli,0,1), sli, sh-3-4);
        text(nfs(kno,0,1), kno, 3*sh-4);
          fill(C[15]);
        if(sli<kno) image(gradInvert, sli, sh+3, kno-sli, sh-6);  
        if(sli>=kno)image(grad,       kno, sh+3, sli-kno, sh-6); 
    popMatrix(); textAlign(LEFT);
  }  
}

class DiSlider {
  int x, y, s; float pos1, pos2, pos3, pos11, pos22, pos33, zone ; PImage mapImg = createImage(100, 100, ARGB); char over = 'n' ;
  DiSlider(int tx,int ty, int ts){ 
    x=tx; y=ty; s=ts;
    setupImg();
  }
  void mouved(){
    if      ( isOver(x+slider[4]-10, y+map(slider[5],0,s,s,0)-10, 20, 20 ) ) { over = 'b' ; setup(); }  // Black handle
    else if ( isOver(x+  knob[4]-10, y+map(  knob[5],0,s,s,0)-10, 20, 20 ) ) { over = 'w' ; setup(); }  // white handle
    else if ( isOver(x, y, s, s )                                        )   { over = 'a' ; setup(); }  // bolth handle
    else                                                                     { over=  'n'; setup();  }  // none
  }
  void pressed (){
    if (      mouseX>x+slider[4]-10 && mouseY>y+map(slider[5],0,s,s,0)-10 && mouseX<x+slider[4]+10 && mouseY<y+map(slider[5],0,s,s,0)+10 ) { zone=1; pos1=mouseX; pos11=mouseY; }
    else if ( mouseX>x+ knob [4]-10 && mouseY>y+map( knob [5],0,s,s,0)-10 && mouseX<x+ knob [4]+10 && mouseY<y+map( knob [5],0,s,s,0)+10 ) { zone=2; pos2=mouseX; pos22=mouseY; }
    else if ( mouseX>x              && mouseY>y              && mouseX<x+s            && mouseY<y+s            ) { zone=3; pos1=mouseX; pos11=mouseY; pos2=mouseX; pos22=mouseY; }
  }  
  void released () { zone=0; 
  }
  void dragged () {
    float sli5 = s-slider[5]; float kno5 = s-knob[5];
    off = (control) ? 20 : 1 ;
    if ( zone==1 || zone==3 ) { // top black
      slider[4] += (mouseX-pos1)/off;    pos1=mouseX; 
      slider[5] -= (mouseY-pos11)/off;   pos11=mouseY; 
      slider[4] = constrain(slider[4], 0, s-20);
      slider[5] = constrain(slider[5], 0, s-20);
    }
    if ( zone==2 || zone==3 ) { // bottom white
      knob[4] += (mouseX-pos2)/off;  pos2=mouseX; 
      knob[5] -= (mouseY-pos22)/off; pos22=mouseY; 
      knob[4] = constrain(knob[4], 0, s-20);
      knob[5] = constrain(knob[5], 0, s-20);
    }
    if ( zone!=0 ) setup();
    viewing = true ;
  }
  void setupImg () { map=true; turing2(mapImg); map=false; setup();}
  void setup () {
    float sli5 = s-slider[5]; float kno5 = s-knob[5];  // invert 0->200 to 200->0
    pushMatrix(); translate(x, y);
      fill(C[25]); rect(-36,s,50,50 ); //bg clean
      fill(colorElemBg); rect(-20,0,s+40,s+40 ); //bg
      image(mapImg, 0,20,s-20,s-20);
      strokeWeight(5);
        stroke(C[12]); if(over=='b' || over=='a') stroke(colorActive); ellipse(slider[4], sli5, 15, 15);  // top
        stroke(C[12]); if(over=='w' || over=='a') stroke(colorActive); ellipse(knob  [4], kno5, 15, 15);  // bottom
      strokeWeight(1); noStroke();
      for (int i = 0; i<=20; i++){
        fill(255/20*i);
        ellipse(slider[4]+i*(knob[4]-slider[4])/20, sli5+i*(kno5-sli5)/20, 10,10);
      }
    popMatrix();
    setupSlider(4, "thickness", x, y+s+10, s-10);
    setupSlider(5, "brightness", x+s-10, y+s, s-10);
  } 
  void setupSlider(int ref, String name, int xx, int yy, int s){ int sh=15;
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

void style1 (String theControllerName) { 
    println(theControllerName);
}

void style2 () {
  ControlFont cFont = new ControlFont(font,12);
  checkbox.getCaptionLabel().setFont(cFont).toUpperCase(false);
  checkbox.setColorBackground(C[18]);
  checkbox.setColorForeground(C[12]);
  checkbox.setColorActive(C[15]);
}
