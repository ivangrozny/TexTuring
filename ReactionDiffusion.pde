//////////////////////////////////////////////// reaction - diffusion ///////////////

PImage turing2 (PImage img, boolean updateMapImg) {
surface.setTitle ("TexTuring - computing ..." );  
float time = millis();
int left, right, up, down, W = img.width, H = img.height;  float uvv, u, v;
float diffU, diffV, F, K; 
int[][] offsetW = new int[W][2], offsetH = new int[H][2];
float[][]  U = new float[W][H],  V = new float[W][H];
float[][] dU = new float[W][H], dV = new float[W][H];
float lapU, lapV;

    //  INITIALISATION

    float noiseZoom = 0.20;
    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {
        if ( params.iniState == 0 ) {
          U[i][j] = 0.15 * noise( i*noiseZoom, j*noiseZoom, i*0.06) ;
          V[i][j] = 0.7 *  noise( i*noiseZoom, j*noiseZoom, i*0.06) ;
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
  
  //Set up offsets
  for (int i=1; i < W-1; i++) { offsetW[i][0] = i-1; offsetW[i][1] = i+1; }
  for (int i=1; i < H-1; i++) { offsetH[i][0] = i-1; offsetH[i][1] = i+1; }
  offsetW[0][0] = W-1; offsetW[0][1] = 1; offsetW[W-1][0] = W-2; offsetW[W-1][1] = 0;
  offsetH[0][0] = H-1; offsetH[0][1] = 1; offsetH[H-1][0] = H-2; offsetH[H-1][1] = 0;

  //diffU = 0.16; diffV = 0.08; F = 0.035;  K = 0.06;

  float[][][] fkuv = new float[W][H][4];  // init param grid
  float[] mini = { 0.00, 0.01, 0.03, 0.005 };  // F, K, diffU, diffV
  float[] maxi = { 0.15, 0.08, 0.11, 0.05 };  // F, K, diffU, diffV

  for (int i = 0; i<W; i++){
    for (int j = 0; j<H; j++){

      for (int k = 0; k<4; k++){
        if ( updateMapImg == false ) {
          fkuv[i][j][k] = map( brightness(img.pixels[j*W+i]),0,255, 
            map(params.b[k], 0, 200, mini[k], maxi[k]), 
            map(params.w[k], 0, 200, mini[k], maxi[k]));
        } 
      }
      if ( updateMapImg == true) {
        fkuv[i][j][0] = map( i, 0, H, mini[0], maxi[0] );
        fkuv[i][j][1] = map( j, 0, W, maxi[1], mini[0] );  
        fkuv[i][j][2] = map(params.b[2],0,200,0,maxi[2]);
        fkuv[i][j][3] = map(params.w[3],0,200,0,maxi[3]);
      }
    }
  }

  for (int n = 0; n< params.o[0] ; ++n){ 
    for (int i = 0; i < W; ++i) {
      for (int j = 0; j < H; ++j) {

        F = fkuv[i][j][0] ;
        K = fkuv[i][j][1] ;

        u = U[i][j];  
        v = V[i][j]; 
        //left  = offsetW[i][0]; right = offsetW[i][1];
        //up    = offsetH[j][0]; down  = offsetH[j][1];

        uvv = u*v*v;
        dU[i][j] = fkuv[i][j][2]*(U[offsetW[i][0]][j]+U[offsetW[i][1]][j]+U[i][offsetH[j][0]]+U[i][offsetH[j][1]] -4*u) - uvv + F*(1 - u);
        dV[i][j] = fkuv[i][j][3]*(V[offsetW[i][0]][j]+V[offsetW[i][1]][j]+V[i][offsetH[j][0]]+V[i][offsetH[j][1]] -4*v) + uvv - (K+F)*v;
      }
    }
    for (int i = 0; i < W; ++i) {
      for (int j = 0; j < H; ++j) {
        U[i][j] += dU[i][j] * 1.38 ;
        V[i][j] += dV[i][j] * 0.63 ;
      }
    }
    surface.setTitle ("TexTuring - computing ["+int( (100*n)/(params.o[0]+1))+"%]" );
  }

  img.loadPixels();
    int pShift,pShift2;
    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {
        pShift = int( U[i][j]*255 ) ;

        img.pixels[j*W+i] = 0xff000000 | (pShift << 16) | (pShift << 8) | pShift  ;
      }
    }
  img.updatePixels();

  lastRenderTime = ( millis()-time ) /1000 ; 
  surface.setTitle ( "TexTuring - 1.0" );

  return img;
}
