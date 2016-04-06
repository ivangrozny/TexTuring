//////////////////////////////////////////////// reaction - diffusion /////////////// TURING

PImage turing2(PImage img) {
surface.setTitle ("TexTuring - computing ..." );  

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
        U[i][j] = 0.8 *( noise(i*noiseZoom,j*noiseZoom) );
        V[i][j] = 0.45*( noise(i*noiseZoom,j*noiseZoom) );
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
        if ( updateDiSliderImage == false ) {
          fkuv[i][j][k] = map( brightness(img.pixels[j*W+i]),0,255, 
            map(params.b[k],0,controlSize[k],0,maxi[k]), 
            map(params.w[k],0,controlSize[k],0,maxi[k]));
            //map(Slider[k+4],0,controlSize[k],0,maxi[k]) + map(wb[k+4],0,controlSize[k],0,maxi[k]));
        } 
      }
      if ( updateDiSliderImage == true) {
        fkuv[i][j][0] = map( i, 0, W, 0, maxi[0]);
        fkuv[i][j][1] = map( j, 0, W, maxi[1], 0);  
        fkuv[i][j][2] = map(params.b[2],0,controlSize[2],0,maxi[2]);
        fkuv[i][j][3] = map(params.w[3],0,controlSize[3],0,maxi[3]);
      }
    }
  }

  for (int n = 0; n< params.o[0] * 6 +1 ; n++){  // reaction diffusion
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
    surface.setTitle ("TexTuring - computing ["+int( (100*n)/(params.o[0]*7+1))+"%]" );
  }
  
  img.loadPixels();
    int pShift,pShift2;
    for (int i = 0; i < W; i++) {
      for (int j = 0; j < H; j++) {
        pShift = int( U[i][j]*255 ) ;

        img.pixels[j*W+i] = 0xff000000 | (pShift << 16) | (pShift << 8) | pShift  ;

        if( updateDiSliderImage && pShift<params.o[1] ) { img.pixels[j*W+i] = C[18]; } 
        else if ( updateDiSliderImage ) { img.pixels[j*W+i] = color(255); }

      }
    }
  img.updatePixels();
  //console.setText("").setColor(colorFont);
  surface.setTitle ("TexTuring" );
  return img;
}
