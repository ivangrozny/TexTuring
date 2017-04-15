import java.awt.Color;

PImage render(PImage img, int widthOut, String state ){

  int imgWidth = int( params.o[2]*img.width/100 ); if (imgWidth<5) imgWidth = 5;

  img.resize(imgWidth, 0 );
  algoReacionDiffusion(img, state);

  if ( state.equals("export") || state.equals("animate") ) {
    BufferedImage scaledImg = Scalr.resize( (BufferedImage)img.getNative(), Scalr.Method.QUALITY, Scalr.Mode.FIT_TO_WIDTH, widthOut);  // load PImage to bufferImage 
    img = new PImage(scaledImg);
  }else{
    img.resize( widthOut, 0 );  // may be faster but uglyer (blobs not perfectly round)
  }

  thresholdImg(img);
  return img ;
}
void thresholdImg(PImage img){
  if (threshold) img.filter(THRESHOLD, map(params.o[1],0,255,0,1) );
}
//////////////////////////////////////////////// reaction - diffusion ///////////////
float uvv, u, v;
float diffU, diffV, F, K; 
float lapU, lapV;
float[] MINI = { 0.00, 0.01, 0.03, 0.005 };  // F, K, diffU, diffV
float[] MAXI = { 0.15, 0.08, 0.11, 0.05 };  // F, K, diffU, diffV
float NOISE_ZOOM = 0.20;

PImage algoReacionDiffusion (PImage img, String state) {

  int W = img.width, H = img.height;  
  int[][] offsetW = new int[W][2], offsetH = new int[H][2];
  float[][]  U = new float[W][H],  V = new float[W][H];
  float time = millis();

  //  INITIALISATION
  for (int i = 0; i < W; ++i) {
    for (int j = 0; j < H; ++j) {
      if ( params.iniState == 0 ) {
        U[i][j] = 0.15 * noise( i*NOISE_ZOOM, j*NOISE_ZOOM, i*0.06) ;
        V[i][j] = 0.7 *  noise( i*NOISE_ZOOM, j*NOISE_ZOOM, i*0.06) ;
      }
      if ( params.iniState == 1 ) {
        U[i][j] = 0.15 * map(i%9+j%9,0,16,-1,1) ;
        V[i][j] = 0.7 *  map(i%9+j%9,0,16,-1,1) ;
      }
      if ( params.iniState == 2 ) {
        U[i][j] = 0.15 ;
        V[i][j] = 0.7  ;
      }
    }
  }  

  float[][][] fkuv = new float[W][H][4];  // init param grid

  for (int i = 0; i<W; ++i){
    for (int j = 0; j<H; ++j){

      if ( state.equals("renderMapImg") ) {
        fkuv[i][j][0] = ( map( i, 0, H, MINI[0], MAXI[0] )  );
        fkuv[i][j][1] = ( map( j, 0, W, MAXI[1], MINI[0] )  );
        fkuv[i][j][2] = ( map(params.b[2],0,200,0,MAXI[2] ) );
        fkuv[i][j][3] = ( map(params.w[3],0,200,0,MAXI[3] ) );

      } else {
        for (int k = 0; k<4; ++k){
          fkuv[i][j][k] = (  map( brightness(img.pixels[j*W+i]),0,255, 
            map(params.b[k], 0, 200, MINI[k], MAXI[k]), 
            map(params.w[k], 0, 200, MINI[k], MAXI[k])) );
        } 
      }

    }
  }

  //Set up offsets
  for (int i=0; i < W; ++i) { offsetW[i][0] = i-1; offsetW[i][1] = i+1; }
  for (int i=0; i < H; ++i) { offsetH[i][0] = i-1; offsetH[i][1] = i+1; }
  offsetW[0][0] = 0; offsetW[W-1][1] = W-1;
  offsetH[0][0] = 0; offsetH[H-1][1] = H-1;

  for (int n = 0; n< params.o[0] ; ++n){ 
    for (int i = 0; i < W; ++i) {
      for (int j = 0; j < H; ++j) {

        F = fkuv[i][j][0] ;
        u = U[i][j];  
        v = V[i][j]; 
        uvv = u*v*v;
        lapU = U[offsetW[i][0]][j] + U[offsetW[i][1]][j] + U[i][offsetH[j][0]] + U[i][offsetH[j][1]] -4*u;
        lapV = V[offsetW[i][0]][j] + V[offsetW[i][1]][j] + V[i][offsetH[j][0]] + V[i][offsetH[j][1]] -4*v;

        U[i][j] += ( fkuv[i][j][2]*lapU - uvv + F*(1 - u) ) * 1.38 ;
        V[i][j] += ( fkuv[i][j][3]*lapV + uvv - (fkuv[i][j][1]+F)*v   ) * 0.63 ;
      } 
    }
    if( (state.equals("export") || state.equals("animate")) && n%((params.o[0])/30+1) == 0 )  {
      String progress = "";
      for (int i = 0; i < 30; ++i) progress += (map(n,0,params.o[0],0,30) >i)? "(" : ")" ; // "◼" : "◻" ;
      surface.setTitle ("TexTuring - Evolution : "+progress+" - "+int( (100*n)/(params.o[0]+1) )+" %  " );
    }


    if( state.equals("animate") && n>2 && n%(20) == 3 ){
      ((ViewPort)gui.elements.get(0)).dataAnimation = U ;
      updateViewImg = true;
    }
  }
  writeImg(img, U);

  lastRenderTime = ( millis()-time ) /1000 ; 
  if( state.equals("export") || state.equals("animate") ) surface.setTitle ( "TexTuring" );
  
  return img;
}

void writeImg(PImage img, float[][] U){
    int pShift;
    for (int i = 0; i < img.width; i++) {
      for (int j = 0; j < img.height; j++) {
        pShift = int( U[i][j]*255) ;
        img.pixels[j*img.width+i] = 0xff000000 | (pShift << 16) | (pShift << 8) | pShift  ;
      }
    }
}
