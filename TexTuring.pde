int frames = 30;
float[] slider = {0 ,40 ,20 ,0 ,20 ,20 ,20 ,20}; float[] knob = {60 ,0 ,0 ,0 ,0 ,0 ,0 ,0};
Button[] button ; BiSlider[] bi ; DiSlider di ; Snap snaps ; CheckBox checkbox; MapImg mapImg;
PFont font;
boolean control = false, live = true, map = false, viewing = false, seuilVisible=true, greyScale = false;
String[] saved ; 
String lastPath ;
PImage src, view, currentI, srcMin, grad,gradInvert;
int viewX, viewY,h,w, off, offX, offY, viewSize=100 ;
color[] C = new color[26];

void setup() {
  size(1350, 720); //frame.setIconImage( getToolkit().getImage("icone.ico") ); //size(displayWidth, displayHeight);
  //if (frame != null) { frame.setResizable(true) ;}
  frameRate(60);
  for (int i = 0; i<=25; i++){   colorMode(HSB); C[i] = color(122,270-i*13,100+i*5); } // create palette
  background(C[25]); noStroke();
  src=loadImage("wiki.png");
  grad=loadImage("gradient.png"); gradInvert=loadImage("gradInvert.png");
  font = loadFont("FedraTwelve-Normal-12.vlw");  textFont(font, 12); fontColor();

  button = new Button[6];
  // TODO looper + actionner
  button[0] = new Button(d    , d, 100+5, 20 ,"new file");
  button[1] = new Button(d+110, d, 100+5, 20 ,"export");
  button[2] = new Button(d+220, d, 100+5, 20 ,"load");
  button[3] = new Button(d+330, d, 95,    20 ,"save");
  button[4] = new Button(d+430, d, a/2-b, 20,"specimen");
  button[5] = new Button(d+a+a+a/2+30, d, a/2-b, 20,"render");
  
  text("growing time", gauche+20, haut+a+c+10); if(seuilVisible) text("threshold", gauche+20, haut+a+c+55); 

  // TODO iterations control slider
  //cp5.addSlider("iterations", 1,1000,gauche,  haut+a+c+15, a+20, 20).setDecimalPrecision(0).setCaptionLabel("");         style1("iterations"); 
  // TODO inclure un switch pour un export en greyScale

  mapImg = new MapImg(gauche, haut);
  snaps = new Snap( d,  height-d-a/2 );
  bi = new BiSlider[2]; 
  bi[0] = new BiSlider(6, "reaction", gauche-10, haut+a+c+150, a+20);
  bi[1] = new BiSlider(7, "diffusion", gauche-10, haut+a+c+a+a/2-60, a+20);
  di = new DiSlider(gauche+a+80+b, haut+a+c+10, a+20);

  saved = loadStrings("default.trm");
  setParam(saved);
  di.setup();

  //selectInput("Select a file to process:", "fileSelected"); noLoop();  // File selector at TexTuring-launch
  File file = new File( dataPath("wiki.png") ); fileSelected(file);      // File selected at TexTuring-launch
}

void draw() {
  //if (frameCount%1==0) viewSize = (int)map(slider[0],0,1000,a,50);//int(frameRate*20) ;
  if (viewing && srcMin!=null) preview() ;
}
void preview(){
  //fill(C[25]); rect(a+b+d, d+haut, a/2, a/2); 
  view = src.get( viewX,viewY, viewSize, viewSize); turing2(view); 
  viewing = false ;
  imageMode(CENTER); image(view, gauche+srcMin.width+(a-srcMin.width+a+a/2)/2, haut+a/2); imageMode(CORNER);
}
void controlEvent (ControlEvent theEvent) {
  println("got a control event from controller with name " + theEvent.getName() );
  if ( theEvent.getName() == "iterations" )    { slider[0] = theEvent.getController().getValue(); viewing = true ;}
  if ( theEvent.getName() == "threshold" )     { slider[1] = theEvent.getController().getValue(); viewing = true ;}
  //if ( theEvent.isFrom(checkbox) )             { button[0] = !button[0] ;                         viewing = true ;}

  if ( theEvent.getName() == "new file" ) { noLoop(); selectInput("Select your image", "fileSelected"); viewing = true ;}  
  if ( theEvent.getName() == "renderControl" ) render(); 
  if ( theEvent.getName() == "export" )   { render(); currentI.save("testFinalz_"+frameCount+"_test.png"); }
  if ( theEvent.getName() == "specimen" ) { }//noLoop(); selectOutput("Nomez votre spécimen", "saveSpecimen"); }

  if ( theEvent.getName() == "load" ) {  noLoop();  selectInput( "Select TexTuring settings file", "loadParameters"); viewing = true ;}
  if ( theEvent.getName() == "save" ) {  noLoop();  selectOutput("Name your TexTuring settings file", "saveParameters"); }
  
  for (int i = 0; i<8; i++) {  
    if ( theEvent.getId() == i+16 ) { snaps.pressed(i); viewing = true ; }
  }
}
void buttonAction(String name){
}

void render(){
  currentI = src.get();
  turing2(currentI); 
  image(currentI, 3*a+35+d, d ); // ,(currentI.width*(height-d))/currentI.height, height-d); 
}
float[][] videoCtrl = new float[4][8] ; // iniSlider, iniKnob, finSlider, finKnob
int name = 0;
String instanceVideoFolder = ""+random(0, 1);
void saveVideo(){
  for (int i = 1; i<=frames; i++){ name++;
    currentI = src.get();
    for (int j = 0; j<8; j++){
      slider[j] = map(i,0,frames,videoCtrl[0][j],videoCtrl[2][j]);
      knob  [j] = map(i,0,frames,videoCtrl[1][j],videoCtrl[3][j]);
    }
    turing2(currentI); 
    image(currentI, 3*a+35+d, d );
    currentI.save("video/animation_"+instanceVideoFolder+"/"+name+".png");
  }
}
void keyPressed(){
  if ( keyCode == CONTROL) control = true;
  if (key == 'i') src.filter(INVERT);
  if (key == '+') src.resize(int(src.width+100),0);  if (key == '-') src.resize(int(src.width-100),0);
  if (key == 'v') { for (int i = 0; i<8; i++){ videoCtrl[0][i]=slider[i];  videoCtrl[1][i]=knob[i];  saved[i]=slider[i]+" "+knob[i] ; }              saveStrings( "video/animation_"+instanceVideoFolder+"/"+name+"-V.trm", saved); }
  if (key == 'b') { for (int i = 0; i<8; i++){ videoCtrl[2][i]=slider[i];  videoCtrl[3][i]=knob[i];  saved[i]=slider[i]+" "+knob[i] ; } saveVideo(); saveStrings( "video/animation_"+instanceVideoFolder+"/"+name+"-B.trm", saved); }
  if (key == 'a') {  selectFolder("Select a folder to process:", "folderSelected");  } 
}
ArrayList<File> filesList = new ArrayList<File>();

void folderSelected(File selection) {
  if (selection!=null) {

    File file = new File(selection.getAbsolutePath());
    File[] files = file.listFiles();
    for (int i = 0; i < files.length; i++) {
      filesList.add(files[i]);
    }
  }
  int count = 0;
  int folder = int(random(0, 100000));
  for(File f : filesList){ count++;
    src=loadImage(selection.getAbsolutePath()+"/"+f.getName()); 
    src.filter(GRAY);
    render(); 
    currentI.save("video/video_"+folder+"/"+count+".png");

  }
}
void keyReleased()  { control = false; }
void mousePressed() { for (BiSlider o : bi){ o.pressed(); } di.pressed(); }
void mouseReleased(){ for (BiSlider o : bi){ o.released();} di.released(); button[0].pressed(); }
void mouseMoved(){ di.mouved();  bi[0].mouved(); bi[1].mouved(); mapImg.mouved(); button[0].mouved(); }
void mouseDragged(){ for (BiSlider o : bi) { o.dragged(); } di.dragged(); mapImg.dragged(); }

void fileSelected(File selection) { lastPath=selection.getAbsolutePath(); 
  src=loadImage(lastPath); 
  src.filter(GRAY);
  w=src.width;
  h=src.height;
  if(w>h) { srcMin = src.get(); srcMin.resize(a,0); }
  if(w<=h) { srcMin = src.get(); srcMin.resize(0,a); }
  //cp5.getController("largeur (px)").setText(src.width+"");
  fill(colorElemBg); rect(gauche,haut,2*a+a/2+b,a); // setup view
  mapImg.setup();
  viewing = true ;
  loop(); 
}
void saveSpecimen(File selection){ 
  for (int i = 0; i<8; i++){ saved[i] = slider[i]+" "+knob[i] ; } 
  //saveStrings( selection.getAbsolutePath()+".trm", saved) ;
  render(); //currentI.save(selection.getAbsolutePath()+".png");
  fileToPrinter("specimen.pdf");
  loop(); 
}
void saveParameters(File selection){ 
  for (int i = 0; i<8; i++){ saved[i] = slider[i]+" "+knob[i] ; } 
  saveStrings( selection.getAbsolutePath()+".trm", saved) ;
  loop(); 
}
void loadParameters(File selection){ setParam(loadStrings(selection.getAbsolutePath())); loop(); }
void setParam ( String data[] ) {           
  for (int i = 0; i<8; i++) { 
    String[] n = split(data[i]," "); 
    slider[i] = int(n[0]); 
    knob[i] = int(n[1]); 
  }
  for (BiSlider o : bi) { o.setup(); } di.setup();
  // TODO slider[iterations].setValue(slider[0]);
  // TODO slider[ threshold].setValue(slider[1]);
  map=true; turing2(di.mapImg); map=false;
  viewing = true ;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void fileToPrinter(String fileName) {
  try {
    ProcessBuilder pb = new ProcessBuilder("lpr", fileName);
    Process p = pb.start();
  } catch (IOException e) { println(e); }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////// reaction - diffusion /////////////// TURING

PImage turing2(PImage img) {
frame.setTitle ("TexTuring - computing ..." );  

int left, right, up, down, W = img.width, H = img.height;  float uvv, u, v;
float diffU, diffV, F, K; 
int[][] offsetW = new int[W][2], offsetH = new int[H][2];
float[][]  U = new float[W][H],  V = new float[W][H];
float[][] dU = new float[W][H], dV = new float[W][H];
float lapU, lapV;

  for (int i = 0; i < W; i++) {
    for (int j = 0; j < H; j++) {
      U[i][j] = 1.0;
      V[i][j] = 0.0;
    }
  }
  img.loadPixels();                  //  INITIALISATION
    float noiseZoom = 0.01;

    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {        
        U[i][j] = 0.8*(noise(i*noiseZoom,j*noiseZoom));
        V[i][j] = 0.45*(noise(i*noiseZoom,j*noiseZoom));
        //U[i][j] = random(0,0.5);
        //V[i][j] = random(0,0.25);
      }
    }  
  img.updatePixels();
  //Set up offsets
  for (int i=1; i < W-1; i++) { offsetW[i][0] = i-1; offsetW[i][1] = i+1; }
  for (int i=1; i < H-1; i++) { offsetH[i][0] = i-1; offsetH[i][1] = i+1; }
  offsetW[0][0] = W-1; offsetW[0][1] = 1; offsetW[W-1][0] = W-2; offsetW[W-1][1] = 0;
  offsetH[0][0] = H-1; offsetH[0][1] = 1; offsetH[H-1][0] = H-2; offsetH[H-1][1] = 0;

  //diffU = 0.16; diffV = 0.08; F = 0.035;  K = 0.06;

  float[][][] fkuv = new float[W][H][4];  // init param grid
  float[] maxi = { 0.15, 0.07, 0.1, 0.1 };
  int[] controlSize = { a, a, a, a };
  for (int i = 0; i<W; i++){
    for (int j = 0; j<H; j++){
      for (int k = 0; k<4; k++){
        if(map==false) {
          fkuv[i][j][k] = map( brightness(img.pixels[j*W+i]),0,255, 
            map(slider[k+4],0,controlSize[k],0,maxi[k]), 
            map(knob[k+4],0,controlSize[k],0,maxi[k]));
            //map(slider[k+4],0,controlSize[k],0,maxi[k]) + map(knob[k+4],0,controlSize[k],0,maxi[k]));
        } 
      }
      if(map==true) {
        fkuv[i][j][0] = map( i, 0, W, 0, maxi[0]);
        fkuv[i][j][1] = map( j, 0, W, maxi[1], 0);  
        fkuv[i][j][2] = map(slider[6],0,controlSize[2],0,maxi[2]);
        fkuv[i][j][3] = map(slider[7],0,controlSize[3],0,maxi[3]);
      }
    }
  }

  for (int n = 0; n<slider[0]*6+1; n++){  // reaction diffusion
    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {

        F = fkuv[i][j][0] ;
        K = fkuv[i][j][1] ;
        diffU = fkuv[i][j][2] ;
        diffV = fkuv[i][j][3] ;

        u = U[i][j];  
        v = V[i][j]; 
        left  = offsetW[i][0]; right = offsetW[i][1];
        up    = offsetH[j][0]; down  = offsetH[j][1];

        lapU = U[left][j] + U[right][j] + U[i][up] + U[i][down] - (u+u+u+u);
        lapV = V[left][j] + V[right][j] + V[i][up] + V[i][down] - (v+v+v+v);

        uvv = u*v*v;
        dU[i][j] = diffU*lapU  - uvv + F*(1 - u);
        dV[i][j] = diffV*lapV + uvv - (K+F)*v;
      }
    }
    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {
        U[i][j] += dU[i][j];
        V[i][j] += dV[i][j];
      }
    }
    frame.setTitle ("TexTuring - computing ["+int( (100*n)/(slider[0]*7))+"%]" );
  }
  
  img.loadPixels();
    int pShift,pShift2;
    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {
        pShift = int( U[i][j]*255 ) ;

        if( !greyScale && pShift<slider[1] ) { img.pixels[j*W+i] = color(0); } else { img.pixels[j*W+i] = color(255); }
        if( greyScale ) img.pixels[j*W+i] =  0xff000000 | (pShift << 16) | (pShift << 8) | pShift  ;
        if( map && pShift<slider[1] ) { img.pixels[j*W+i] = C[18]; } else if(map){ img.pixels[j*W+i] = color(255); }

      }
    }
  img.updatePixels();
  //console.setText("").setColor(colorFont);
  frame.setTitle ("TexTuring" );
  return img;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 /*
void turing1() {
  generateInitialState();

  for (int i = 1; i < N-1; i++) {  //Set up offsets
    offset[i][0] = i-1;
    offset[i][1] = i+1;
  }
  offset[0][0] = N-1;   offset[0][1] = 1;  
  offset[N-1][0] = N-2; offset[N-1][1] = 0;

  diffU = map(slider[4],0,127,0,0.1); diffV = map(slider[5],0,127,0,0.1); F = map(slider[6],0,127,0,0.1); K = map(slider[7],0,127,0,0.1);
  diffU = 0.16; diffV = 0.08; 

  for (int n = 0; n<slider[0]*4+1; n++){
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
         
        u = U[i][j];  
        v = V[i][j]; 
        left  = offset[i][0];
        right = offset[i][1];
        up    = offset[j][0];
        down  = offset[j][1];
         
        uvv = u*v*v;    
        double lapU = (U[left][j] + U[right][j] + U[i][up] + U[i][down] - 4*u);
        double lapV = (V[left][j] + V[right][j] + V[i][up] + V[i][down] - 4*v);
         
        dU[i][j] = diffU*lapU  - uvv + F*(1 - u);
        dV[i][j] = diffV*lapV + uvv - (K+F)*v;
      }
    }
              
    for (int i= 0; i < N; i++) {
      for (int j = 0; j < N; j++){
          U[i][j] += dU[i][j];
          V[i][j] += dV[i][j];
      }
    }
  }

  loadPixels();
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        pixels[i*N+j] = color( (float)(U[i][j]*255) ) ;
      }
    }
  updatePixels();
}
 
void generateInitialState() {
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      U[i][j] = 1.0;
      V[i][j] = 0.0;
    }
  }
  src.loadPixels();
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {    
      switch (init) {
        case 0:    
          U[i][j] = 0.5*(1 + random(-1, 1));
          V[i][j] = 0.25*( 1 + random(-1, 1));
        break;
        case 1:
          U[i][j] = map(brightness(src.pixels[i*N+j]),0,255,1,0.5);
          V[i][j] = map(brightness(src.pixels[i*N+j]),0,255,0,0.25);
        break;
      }
    }
  }  
  src.updatePixels();
}
 
*/
