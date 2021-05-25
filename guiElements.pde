class GuiElement {
  Rect coords;
  String name;
  int ref;
  PImage mapImg ;
  PImage viewImg ;
  Rect viewZone ;
  float zoom = 0.5240786 ;
  boolean isOver = false;
  boolean isVisible = true;
  boolean dropState = false;
  boolean isSelected = false;
  Parameters savedParams ;
  String flag = "";

  GuiElement(){
    coords = new Rect();
  }

  GuiElement(Rect _coords, String _name){
    coords = _coords;
    name = _name;
    if (name=="iterations") ref = 0 ;
    if (name=="threshold") ref = 1 ;
    if (name=="resolution") ref = 2 ;
    if (name=="reaction") ref = 2 ;
    if (name=="diffusion") ref = 3 ;
  }

  boolean isOver() { return coords.isOver(mouseX, mouseY); }

  void update() {}
  //callbacks for injecting events
  void moved() { update(); }
  void pressed() {}
  void released() {}
  void dragged() {}
  void initView() {}
  //helpers to uniformize ways of drawings things
  void drawRect( Rect r) {             rect(   r.pos.x, r.pos.y, r.size.x, r.size.y ); }
  void drawImage(PImage i, Rect r) {  image(i, r.pos.x, r.pos.y, r.size.x, r.size.y ); }
  void drawText( Rect r, String text){ text(text, coords.pos.x + 5, coords.pos.y ); }
  void renderView() {}
  void scroll(int scroll) {}
  void resize() {}
  boolean isSnaped(){return false;}
  void updateMapImg(){}
  void message(String msg) {}
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
        fill( isOver() ? C[14] : C[18] );
        drawRect(coords);
        fill(0);
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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Button extends GuiElement {
    Button(Rect _coords, String _name) {
        super(_coords, _name);
        update();
    }
    void update(){
      if (isVisible){
          if( name.equals("Render  preview") && isRendering ){
              fill( isOver()? C[8] : C[12] ); drawRect(coords);
              fill(C[25]); text("Stop", coords.pos.x + 5, coords.pos.y + 15);
          }else{
              fill( isOver() ? C[15] : C[19] );
              if( isSelected ) fill( C[13] );
              drawRect(coords);
              fill(0); text(name, coords.pos.x + 5, coords.pos.y + 15);
          }
      }else{
          fill(C[24]);
          drawRect(coords);
      }
    }
    void pressed() {
      buttonPressed( this );
    }
    void resize(){
      if (name.equals("About")) coords = new Rect( width-d-coords.size.x , coords.pos.y, coords.size.x, coords.size.y );
    }
}
      ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class CheckBox extends GuiElement {
  boolean b = false;
  CheckBox(Rect _coords, String _name) {
    super(_coords, _name);
    update();
  }
  void update(){
    fill( C[20] ); if(isOver()) fill(C[19]); // fond
    drawRect(coords);
    fill( b ? C[18] : C[14] );
    if(isOver()) fill(colorActive); // fond
    rect(coords.pos.x+4, coords.pos.y+4, coords.size.x-8, coords.size.y-8);
  }
  void pressed() {
    buttonPressed( this );
    b = !b ;
    gui.elements.get(9).updateMapImg();
    gui.injectMouseMoved();
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class StatusBar extends GuiElement {
  String txt = "";
  StatusBar(Rect _coords, String _name) {
    super(_coords, _name);
    update();
  }
  void update(){
    fill( 255 ); drawRect(coords);
    fill(C[0]); text(txt, coords.pos.x + 10, coords.pos.y + 15);
    if (isRendering){
        int space = 120;
        fill(bg); rect(coords.pos.x + space-6, coords.pos.y, space+2, coords.size.y);
        fill( ( txt.equals("Saving file ...") && frameCount%15<5 )? C[14] : C[19]);
        rect(coords.pos.x + space, coords.pos.y, 110, coords.size.y);
        fill(C[10]); rect(coords.pos.x + space, coords.pos.y, renderProgress, coords.size.y);
        if (txt.equals("Saving file ...")) updateMessage = true;
    }
  }
  void message(String msg){
    println("msg: "+msg);
    txt = msg ;
  }
  void resize(){
    coords = new Rect( coords.pos.x , coords.pos.y, width-coords.pos.x-50-d, coords.size.y );
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Slider extends GuiElement {
  int range;
  float pos;
  boolean press = false;
  PImage sliderTimeBg = loadImage("slider.png");
  PImage sliderTimeBg2 = loadImage("slider2.png");
  String txt;
  Slider(Rect _coords, String _name, String _txt, int _range){
    super(_coords, _name);
    range = _range;
    txt = _txt;
    update();
  }
  void pressed (){
      pos = mouseX;
      press = true;
  }
  void released (){
    if (press) gui.elements.get(9).updateMapImg();
    press = false;
  }
  void dragged () {
      off = (control) ? 2 : 1 ;
      pos += (mouseX - pos)/off ;
      params.o[ref] = (int)constrain( map(pos-coords.pos.x,0, coords.size.x,0,range), 0, range);
      pos = mouseX;
      if( params.o[ref]==0 ) params.o[ref] = 1;

      update();
      viewing = true;
  }

  void update(){
    float b = map( params.o[ref], 0,range, 0,coords.size.x ) ;

    fill( C[20] );
    drawRect(coords);
    pushMatrix(); translate(coords.pos.x, coords.pos.y);
        if (name=="iterations"||name=="resolution") image(sliderTimeBg, int(coords.size.x - sliderTimeBg.width), 0 );  // bg img
        if (!isOver()) fill( C[14] );
        if (isOver()) fill( C[11] );
        if(press) fill(colorActive);
        if (!threshold && ref==1) fill( C[18] );
        rect(0, 0, b, coords.size.y); // Slider
        fontColor();
        text(txt, 0 , -8);
        float textPos = b < coords.size.x-30 ? b+5 : b-30 ;
        text((int)params.o[ref], textPos, coords.size.y-6);  // number display
    popMatrix();
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

PImage renderMin ;
PImage renderMinDone ;
class ViewPort extends GuiElement {
    Thread[] viewZoneThread = new Thread[ constrain(Runtime.getRuntime().availableProcessors(),1,4) ] ; int offThread = 0;
  Rect renderZone ;
  float centerRectX = 0, centerRectY = 0, centerSize ;
  boolean updateViewPort = false ;
  float[][] dataAnimation ;
  ViewPort (Rect _coords) {
    super(_coords, "preview");
    viewZone   = new Rect(0,0,coords.size.x, coords.size.y); // from top left of input src-img
    renderZone = new Rect(coords.pos.x, coords.pos.y, 100, 100);
    viewImg = createImage(int(coords.size.x), int(coords.size.y), ALPHA);
    renderMin = createImage(50,50,ALPHA);
    renderMinDone = createImage(50,50,ALPHA);
    viewZoneThread[1] = new ViewZoneThread( 10 ); viewZoneThread[0] = new ViewZoneThread( 10 );
    viewZoneThread[2] = new ViewZoneThread( 10 ); viewZoneThread[3] = new ViewZoneThread( 10 );
  }
  void resize(){
    coords = new Rect( d+200+350+90 , b+35, width-200-350-90-d-d, height -3*b-35 );
    scroll(0);
  }
  void scroll(int scroll){
    if( src.width/src.height < 1) zoom = constrain(zoom +0.05*scroll, 0.1, src.height/coords.size.y);  // src image = portrait
    if( src.width/src.height >= 1) zoom = constrain(zoom +0.05*scroll, 0.1, src.width/coords.size.x);  // src image = paysage
    modifyViewZonePos( (viewZone.size.x-zoom*coords.size.x)/2 , (viewZone.size.y-zoom*coords.size.y)/2 ); // keep zooming centered
    viewZone.size.x = coords.size.x*zoom ;
    viewZone.size.y = coords.size.y*zoom ;
    synchroScroll = true ;
  }
  void moved() {
      if (coords.isOver() ){ cursor(MOVE); }else{ cursor(ARROW); }
  }
  void dragged() {
    if ( isOver() || synchroScroll ) {
      synchroScroll = false ;
      modifyViewZonePos( pmouseX - mouseX , pmouseY - mouseY );
      updateView(src);
      viewing = true ;
    }
  }
  void initView() {
      scroll(-1);
      modifyViewZonePos((src.width -viewZone.size.x)/2, (src.height-viewZone.size.y)/2 );
      updateView(src);
      viewing = true ;
  }
  void modifyViewZonePos(float x, float y) {
      viewZone.pos.x = constrain( viewZone.pos.x+x, 0, (src.width -viewZone.size.x > 0) ? src.width -viewZone.size.x : 0 ) ;
      viewZone.pos.y = constrain( viewZone.pos.y+y, 0, (src.height-viewZone.size.y > 0) ? src.height-viewZone.size.y : 0 ) ;
  }
  void renderView(){  // render all the viewPort
      if ( isRendering ) {
        killRender = true;
      }else{
          isRendering = true ;
          viewing = false ;
          thread("renderViewThread");
      }
  }

  void updateView( PImage source ){ // setup viewImg as the viewZone from src
    viewImg = createImage(
      (viewZone.pos.x+viewZone.size.x < src.width )? (int)viewZone.size.x : int( src.width  ) ,
      (viewZone.pos.y+viewZone.size.y < src.height)? (int)viewZone.size.y : int( src.height ) ,
    ALPHA );
    viewImg.set(-(int)viewZone.pos.x, -(int)viewZone.pos.y, source );
  }

  void update(){
    fill(bg); rect(coords.pos.x,coords.pos.y,coords.size.x+10,coords.size.y+10); // background

    if( isRendering ){ frameAnimation();
    } else{
        image(viewImg, coords.pos.x, coords.pos.y,
            round((viewZone.pos.x+viewZone.size.x < src.width )? coords.size.x : src.width /zoom),
            round((viewZone.pos.y+viewZone.size.y < src.height )? coords.size.y : src.height /zoom)
       ); // display original image
    }

    if( dropState ) { // drag & drop files indicator
      fill( colorActive,100 );
      rect( coords.pos.x, coords.pos.y, coords.size.x, coords.size.y );
    }

    // render renderZone
    if ( !isRendering && !updateViewPort ) {
      if( viewing ){
        viewing = false ;
        // set renderZone size
        float time = 0.14;
        if( lastRenderTime <time-0.03 ){ centerSize+=1 ;} else if (lastRenderTime >time+0.03) { centerSize-=2 ;};
        if( lastRenderTime <time-0.04 ){ centerSize+=2 ;} else if (lastRenderTime >time+0.04) { centerSize-=2 ;};
        if( lastRenderTime <time-0.06 ){ centerSize+=10 ;} else if (lastRenderTime >time+0.06) { centerSize-=10 ;};
        if( lastRenderTime <time-0.10 ){ centerSize+=50 ;} else if (lastRenderTime >time+0.10) { centerSize-=50 ;};
        if( coords.size.x<coords.size.y ) centerSize = constrain( centerSize, 50, coords.size.x*zoom-10 );
        if( coords.size.x>coords.size.y ) centerSize = constrain( centerSize, 50, coords.size.y*zoom-10 );
        // set the renderZone position
        centerRectX = ( coords.size.x - centerSize/zoom )/2 ;
        centerRectY = ( coords.size.y - centerSize/zoom )/2 ;

        renderMin = createImage( int(centerSize), int(centerSize), ALPHA );
        renderMin.set( int(-centerRectX*zoom), int(-centerRectY*zoom), viewImg );

        viewZoneThread[offThread].interrupt();
        viewZoneThread[offThread] = new ViewZoneThread( int(centerSize/zoom) );
        viewZoneThread[offThread].start();
        offThread = (offThread+1) % viewZoneThread.length ;
        delay( int( (1000*time)/viewZoneThread.length)-10 );
      }
      // image(renderMinDone,  int(coords.pos.x +centerRectX), int(coords.pos.y +centerRectY) );
      image(renderMinDone,  int(coords.pos.x +( coords.size.x - renderMinDone.width )/2), int(coords.pos.y +( coords.size.y - renderMinDone.height )/2) ) ;
    }
    if (updateViewPort) updateView(src);
    if (updateViewPort) updateViewPort = false ;
  }
  void frameAnimation(){ // played during render-thread
    PImage img = createImage(dataAnimation.length, dataAnimation[0].length, ALPHA);
    writeImg(img, dataAnimation);
    img.resize( round( (viewZone.pos.x+viewZone.size.x < src.width )? coords.size.x : src.width /zoom ), 0 );
    thresholdImg(img);
    image(img, coords.pos.x, coords.pos.y);
    fill(150,70);
    if(!lastFrameAnimation) rect(coords.pos.x, coords.pos.y,img.width,img.height);
    lastFrameAnimation = false;
  }
}
class ViewZoneThread extends Thread{
    PImage imgRnd;
    int size;
    public ViewZoneThread ( int size ){
        this.imgRnd = renderMin ;
        this.size = size;
    }
    public void run(){
            imgRnd = render(imgRnd, size, "");
            if(imgRnd != null ) renderMinDone = imgRnd.get();
            updateViewImg = true;
    }
}

void renderViewThread(){
    ViewPort vp = ((ViewPort)gui.elements.get(0));
  PImage img = vp.viewImg.get() ;
  img = render(img, (int)  vp.coords.size.x*3, "animate" );
  img.resize(img.width/3,img.height/3);
  vp.viewImg = img.get();
  isRendering = false;
  vp.updateViewPort = true; updateViewImg = true;
  gui.message("Last render in "+ int(lastRenderTime) + " sec");
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Snap extends GuiElement {
  PImage snap;
  Rect delete;
  PImage delImg;

  Snap (Rect _coords, String _name) {
    super(_coords, _name);
    savedParams = new Parameters();
    delete = new Rect(coords.pos.x+b, coords.pos.y+b, 20, 20);
    delImg = loadImage("delete.png");
    update();

  }
  boolean isSnaped(){ if( snap == null ){ return false; }else{ return true; } }
  void pressed (){
    if( snap == null ) {  // save snap
      savedParams.loadParameters( params );

      snap = loadImage("gradient.png");
      snap.resize((int)coords.size.x,(int)coords.size.y);
      snap = render(snap,(int)coords.size.x*3, "quiet");
      snap.resize((int)coords.size.x,0);

      fill(C[25]); drawRect(coords);
      update();
    }

    if ( snap!=null  ) {
      if ( delete.isOver() ) { snap = null ; }
      else { // load snap
        params.loadParameters( savedParams );
        gui.update();
      }
    }
    viewing = true ;
  }
  void update(){
    if ( snap == null ) {
      fill( isOver() ? C[20] : C[22] );
      drawRect(coords);
      fill( isOver()? C[10] : C[15] );
      if (flag.equals("beginAnimation")) text("begin animation", coords.pos.x+4, coords.pos.y + coords.size.y-4 );
      if (flag.equals("endAnimation"))   text("end animation",   coords.pos.x+4, coords.pos.y + coords.size.y-4 );
    } else {
      if ( !isOver() ) {
        fill(230); drawRect(coords);
        tint( 255, 80 );
        image(snap, coords.pos.x, coords.pos.y, snap.width, snap.height); noTint();
      } else {
        image(snap, coords.pos.x, coords.pos.y);
        fill( delete.isOver() ? C[12] : C[17] );
        drawRect(delete);
        image(delImg,coords.pos.x+b, coords.pos.y+b);
      }
      fill( C[22] );
      if (flag.equals("beginAnimation")||flag.equals("endAnimation")) rect( (int)coords.pos.x, (int)coords.pos.y + coords.size.y -15, (int)coords.size.x, 15 );
      fill( isOver()? C[10] : C[15] );
      if (flag.equals("beginAnimation")) text("begin animation", coords.pos.x+4, coords.pos.y + coords.size.y-4 );
      if (flag.equals("endAnimation"))   text("end animation",   coords.pos.x+4, coords.pos.y + coords.size.y-4 );
    }
    if( dropState ) { // drag & drop files indicator
      fill( colorActive,100 );
      rect( coords.pos.x, coords.pos.y, coords.size.x, coords.size.y );
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class BiSlider extends GuiElement {
  int m, sh=20;
  float pos1, pos2, pos3, zone;
  Rect handle[] = new Rect[3];
  PImage grad, gradInvert;
  String txt;
  BiSlider(Rect _coords, String _name, String _txt){
    super(_coords, _name);
    txt = _txt;
    grad = loadImage("gradient.png"); gradInvert = loadImage("gradInvert.png");
    update();
  }

  void pressed (){
    if ( handle[0].isOver() ) { zone=1; pos1=mouseX; } // top
    if ( handle[1].isOver() ) { zone=2; pos2=mouseX; } // bottom
    if ( handle[2].isOver() ) { zone=3; pos3=mouseX; } // center
  }
  void released (){
    if ( zone!=0 ) {
      gui.elements.get(9).updateMapImg();
    }
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
    fill(bg); rect(coords.pos.x-18,coords.pos.y,coords.size.x+26,3*sh);  //bg
    fill( (handle[2].isOver()||handle[1].isOver()||handle[0].isOver()) ? C[19] : C[20] ); drawRect(handle[2]); // bg bde

    fill( (handle[0].isOver() || handle[2].isOver())? colorActive : C[20]); drawRect(handle[0]); // top cursor
    fill( (handle[1].isOver() || handle[2].isOver())? colorActive : C[20]); drawRect(handle[1]); // bottom

    pushMatrix(); translate(coords.pos.x, coords.pos.y);
        fill( (handle[0].isOver() || handle[2].isOver())? colorActive : C[20]); triangle(b-18, sh-3, b+18, sh-3, b, sh+3); // top cursor
        fill( (handle[1].isOver() || handle[2].isOver())? colorActive : C[20]); triangle(w-18, 2*sh+3, w+18, 2*sh+3, w, 2*sh-3); // bottom
        fontColor(); text(txt, 0 , -2); textAlign(CENTER);
        fill( (handle[0].isOver() || handle[2].isOver())? 0 : C[0]); text(int(b), b, sh-3-3);
        fill( (handle[1].isOver() || handle[2].isOver())? 0 : C[0]); text(int(w), w, 3*sh-5);
        if(b<w) image(gradInvert, b, sh+3, w-b, sh-6);
        if(b>=w)image(grad,       w, sh+3, b-w, sh-6);
    popMatrix(); textAlign(LEFT);
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class DiSlider extends GuiElement { // slider 2D
  Rect handle[] = new Rect[2];
  float pos1, pos2, pos3, pos11, pos22, pos33, zone ;
  float s, sh, x, y;
  PImage grad, gradInvert;

  DiSlider(Rect _coords, String _name){
    super(_coords, _name);
    x = coords.pos.x; y = coords.pos.y; s = coords.size.x; sh = coords.size.y;  // layout helpers
    mapImg = createImage(int(10), int(10), ARGB);
    grad = loadImage("gradient.png"); gradInvert = loadImage("gradInvert.png");
  }
  void moved(){}
  void pressed (){
    if ( coords.isOver() )    { zone=3; pos1=mouseX; pos11=mouseY; pos2=mouseX; pos22=mouseY; } // center
    if ( handle[0].isOver() ) { zone=1; pos1=mouseX; pos11=mouseY; } // top
    if ( handle[1].isOver() ) { zone=2; pos2=mouseX; pos22=mouseY; } // bottom
  }
  void released () {
    zone = 0;
  }
  void dragged () {
    if ( zone!=0 ) {
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
      update();
      viewing = true ;
    }
  }

  void updateMapImg(){
    mapImg.filter(BLUR, 1.5);
    thread("renderMapImg");
  }

  void update () {
    if( frameCount%6==0 || isOver() ) {
      float b5 = s-params.b[1];
      float w5 = s-params.w[1];  // invert 0->200 to 200->0
      handle[0] = new Rect( x+params.b[0]-10, y + map(params.b[1],0,s,s,0)-10, 20, 20 );
      handle[1] = new Rect( x+params.w[0]-10, y + map(params.w[1],0,s,s,0)-10, 20, 20 );

      pushMatrix(); translate(x, y);
        fill(bg); rect(-40,-20,s+60,s+60 ); //bg
        fontColor(); text(name, -50 , 10);
        image(mapImg, 0,20,s-20,s-20);
        fill(240,180); rect(0,20,s-20,s-20);
        strokeWeight( (handle[0].isOver())? 8:5 ); stroke( (handle[0].isOver() || isOver()&&!handle[1].isOver() )? colorActive :C[20] ); ellipse(params.b[0], b5, 15, 15);  // top
        strokeWeight( (handle[1].isOver())? 8:5 ); stroke( (handle[1].isOver() || isOver()&&!handle[0].isOver() )? colorActive :C[20] ); ellipse(params.w[0], w5, 15, 15);  // bottom
        strokeWeight(1); noStroke();
        for (int i = 0; i<=50; i++){
          fill(255/50*i);
          ellipse(params.b[0]+i*(params.w[0]-params.b[0])/50, b5+i*(w5-b5)/50, 10,10);
        }
      popMatrix();
      updateSlider(0, x, y+s+5, s-10);
      updateSlider(1, x+s-15, y+s, s-10);
    }
  }
  void updateSlider(int ref, float xx, float yy, float s){
    int sh=10 ;
    float b = params.b[ref]; float w = params.w[ref];
    pushMatrix(); translate(xx, yy);
    if(ref==1)rotate(-PI/2);
    fill(C[22]); rect(0,0,s-10,sh-6); // slider rect
    if ( abs(b-w)<36 ) {
      float mid = (b<w) ? b+(w-b)/2 : w+(b-w)/2 ;
      fill(C[20]);
      if (b<w) { triangle(mid, 12, mid-36, 12, b, sh-6); triangle(mid, 12, mid+36, 12, w, sh-6); }
      if (b>=w){ triangle(mid, 12, mid+36, 12, b, sh-6); triangle(mid, 12, mid-36, 12, w, sh-6); }
        rect(mid, 12, -36,15);
        rect(mid, 12,  36,15); // handle rect

        fontColor(); textAlign(CENTER);
      if(b<w){ text(int(b), mid-18, 2*sh+3); text(int(w), mid+18, 2*sh+2);
      } else { text(int(b), mid+18, 2*sh+3); text(int(w), mid-18, 2*sh+2); }
      if(b<w) image (gradInvert, b, 0, w-b, sh-6);
      if(b>=w)image (grad,       w, 0, b-w, sh-6);
    } else {
        fill(C[20]);
        triangle ( b-18, 12, b+18, 12, b, sh-6); // top
      triangle ( w-18, 12, w+18, 12, w, sh-6); // bottom
      rect ( b-18, 12, 36, 15 ); // handle rect
      rect ( w-18, 12, 36, 15 );
        fontColor(); textAlign(CENTER);
      text ( int(b), b, 22);
      text ( int(w), w, 22);
      if(b<w) image(gradInvert, b, 0, w-b, sh-6);
      if(b>=w)image(grad,       w, 0, b-w, sh-6);
    }
    popMatrix(); textAlign(LEFT);
  }
}

void renderMapImg(){

    PImage mapImg = gui.elements.get(9).mapImg.get() ;
    float s = gui.elements.get(9).coords.size.x ;

    mapImg.resize( int((s-20)/1.6),int((s-20)/1.6) ) ;
    mapImg = algoReactionDiffusion(mapImg, "renderMapImg");
    mapImg.resize( int(s-20)*3, 0 );
    thresholdImg(mapImg);
    mapImg.resize( int(s-20), 0 );

    gui.elements.get(9).mapImg = mapImg;

}
