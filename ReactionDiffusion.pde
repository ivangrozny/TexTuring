
PImage render(PImage img, int widthOut, String state ){

    int imgWidth = int( params.o[2]*img.width/100 ); if (imgWidth<5) imgWidth = 5;

    img.resize(imgWidth, 0 );
    algoReactionDiffusion(img, state);

    if ( state.equals("export") || state.equals("animate") ) {
        // load PImage to bufferImage
        BufferedImage scaledImg = Scalr.resize( (BufferedImage)img.getNative(), Scalr.Method.QUALITY, Scalr.Mode.FIT_TO_WIDTH, widthOut);
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
float diffU, diffV;
float lapU, lapV;
float[] MINI = { 0.00, 0.01, 0.03, 0.005 };  // F, K, diffU, diffV
float[] MAXI = { 0.15, 0.08, 0.11, 0.05 };  // F, K, diffU, diffV
float NOISE_ZOOM = 0.10;

PImage algoReactionDiffusion (PImage img, String state) {
    int W = img.width, H = img.height;
    int[][] offsetW = new int[W][2], offsetH = new int[H][2];
    float[][]  U = new float[W][H],  V = new float[W][H];
    float time = millis();

    //  INITIALISATION
    for (int i = 0; i < W; ++i) {
        for (int j = 0; j < H; ++j) {
            if ( params.iniState == 0 ) { // random
                U[i][j] = 0;
                V[i][j] = random(1) *0.7 ;
            }
            if ( params.iniState == 1 ) { // noise
                U[i][j] = 0; // map( noise( i*NOISE_ZOOM, j*NOISE_ZOOM) , 0,1, slider[0], slider[1]);
                V[i][j] = noise( i*NOISE_ZOOM, j*NOISE_ZOOM) *0.7 ;
            }
            if ( params.iniState == 2 ) { // uniform
                U[i][j] = 0.15 ;
                V[i][j] = 0.7  ;
            }
        }
    }

    float[][][] fkuv = new float[W][H][4];  // init param grid
    float[] b = new float[5];
    float[] w = new float[5];
    for (int k = 0; k<4; ++k) b[k] = map(params.b[k], 0, 200, MINI[k], MAXI[k]);
    for (int k = 0; k<4; ++k) w[k] = map(params.w[k], 0, 200, MINI[k], MAXI[k]);
    float midU = map( params.b[2]+params.w[2] ,0,400,MINI[2],MAXI[2] );
    float midV = map( params.b[3]+params.w[3] ,0,400,MINI[3],MAXI[3] );

    for (int i = 0; i<W; ++i){
        for (int j = 0; j<H; ++j){

            if ( state.equals("renderMapImg") ) {
                fkuv[i][j][0] = ( map( i, 0, H, MINI[0], MAXI[0] )  );
                fkuv[i][j][1] = ( map( j, 0, W, MAXI[1], MINI[0] )  );
                fkuv[i][j][2] = midU;
                fkuv[i][j][3] = midV;
            } else {
                for (int k = 0; k<4; ++k){
                    fkuv[i][j][k] = (  map( brightness(img.pixels[j*W+i]),0,255, b[k], w[k]) );
                }
            }
        }
    }

    int n = 0;
    int nMax = params.o[0];
    for ( n = 0; n< nMax ; ++n){ // nombre d'iterations
        for (int i = 0; i < W; ++i) {
            for (int j = 0; j < H; ++j) {
                u = U[i][j];
                v = V[i][j];
                uvv = u*v*v;
                lapU = U[constrain(i+1,0,W-1)][j] + U[constrain(i-1,0,W-1)][j] + U[i][constrain(j+1,0,H-1)] + U[i][constrain(j-1,0,H)] -4*u;
                lapV = V[constrain(i+1,0,W-1)][j] + V[constrain(i-1,0,W-1)][j] + V[i][constrain(j+1,0,H-1)] + V[i][constrain(j-1,0,H)] -4*v;

                U[i][j] = u+ ( fkuv[i][j][2]*lapU - uvv + fkuv[i][j][0] * (1-u) ) * 1.38 ;
                V[i][j] = v+ ( fkuv[i][j][3]*lapV + uvv - (fkuv[i][j][1]+fkuv[i][j][0])*v ) * 0.63 ;

                if (u>1) U[i][j] = 1; if (u<0) U[i][j] = 0;
                if (v>1) V[i][j] = 1; if (v<0) V[i][j] = 0;
            }
        }

        if( (state.equals("export") || state.equals("animate")) && n%int((params.o[0])/100+1) == 0 )  {
            renderProgress = int( (100*n)/(params.o[0]+1) );
            gui.message("Rendering : "+renderProgress+" %  " );
        }

        if( (state.equals("export") || state.equals("animate")) && n%30 == 3 ){
            ((ViewPort)gui.elements.get(0)).dataAnimation = U ;
            updateViewImg = true;
        }
        if( (state.equals("export") || state.equals("animate")) && n%200 == 3 ){
            preventOsSleep();
        }
        if( (state.equals("export") ) && n == params.o[0]-1 ){
            ((ViewPort)gui.elements.get(0)).dataAnimation = U ;
            lastFrameAnimation = true;
            updateViewImg = true;
            gui.message("Saving file ...");
        }
        if( killRender ){ n = params.o[0]-2; killRender = false; }
        if( Thread.currentThread().isInterrupted() ) break;
    }

    if( Thread.currentThread().isInterrupted() ) lastRenderTime = ( nMax / n ) * ( millis()-time ) /1000 ;
    if( Thread.currentThread().isInterrupted() ) return null ;

    writeImg(img, U);
    lastRenderTime = ( millis()-time ) /1000 ;
    return img;
}

void writeImg(PImage img, float[][] U){
    int pShift;
    for (int i = 0; i < img.width; i++) {
        for (int j = 0; j < img.height; j++) {
            pShift = int( constrain( (U[i][j])*255 ,0,255) ) ;
            img.pixels[j*img.width+i] = 0xff000000 | (pShift << 16) | (pShift << 8) | pShift  ;
        }
    }
}
