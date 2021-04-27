import boofcv.processing.*;
import boofcv.struct.image.*;
import boofcv.alg.filter.binary.Contour;
import georegression.struct.point.*;

import java.util.List;
import processing.pdf.*;
import processing.svg.*;

void vectorization( PImage img, String fileName, int format){
    PGraphics vecto = null;
    if (format==1) vecto = createGraphics( img.width/3, img.height/3, PDF, fileName );
    if (format==2) vecto = createGraphics( img.width/3, img.height/3, SVG, fileName );
    vecto.beginDraw();
    vecto.background(255);
    vecto.noStroke();
    vecto.fill(0);


    SimpleGray gray = Boof.gray(img,ImageDataType.F32); // Convert the image into a simplified BoofCV data type
    ResultsBlob results = gray.threshold(params.o[1],true).contour();

    for( Contour contour : results.contour) {
        vecto.beginShape();

            drawBlob( vecto, contour.external, 4 );

            for( List<Point2D_I32> pts : contour.internal){
                vecto.beginContour();
                drawBlob(vecto, pts, 4 );
                vecto.endContour();
            }

        vecto.endShape(CLOSE);
    }
    vecto.dispose();
    vecto.endDraw();
}

void drawBlob(PGraphics vecto, List<Point2D_I32> points32, int minimumBlobPoints  ) {

    if ( points32.size() > minimumBlobPoints ){ // delete small blobs
        List<PVector> points = new ArrayList<PVector>();
        for( Point2D_I32 p : points32 ) points.add(new PVector(p.x, p.y) );

        points = smoothLine( points, 5 ); // int == smoothness lvl

        vecto.vertex( points.get(0).x/3, points.get(0).y/3 );
        vecto.curveVertex( points.get(points.size()-1).x/3, points.get(points.size()-1).y/3 );
        for ( int i = 0 ; i < points.size() ; i+=4 )
        vecto.curveVertex( points.get(i).x/3, points.get(i).y/3 );
        vecto.curveVertex( points.get(0).x/3, points.get(0).y/3 );
        vecto.curveVertex( points.get(1).x/3, points.get(1).y/3 );
    }
}

public List<PVector> smoothLine(List<PVector> points, int pointsAdjacents) {
    int p = pointsAdjacents;
    if(points.size() < p*2) return points;

    List<PVector> smoothedPoints = new ArrayList<PVector>();

    for(int i = 0; i < points.size(); i++) {
        List<PVector> tmp = new ArrayList<PVector>();
        for( int j=p; j>=1; j-- ) tmp.add(points.get( (i-j<0)? points.size()+i-j : i-j) );
        tmp.add(points.get(i));
        for( int j=1; j<=p; j++ ) tmp.add(points.get( (i+j>=points.size())? (i+j)-points.size() : i+j) );
        smoothedPoints.add( smoothPoint(tmp) );
    }
    return smoothedPoints;
}


public  PVector smoothPoint(List<PVector> points) {
    float avgX = 0;
    float avgY = 0;
    for(PVector point : points) {
        avgX += point.x;
        avgY += point.y;
    }
    avgX = avgX/points.size();
    avgY = avgY/points.size();

    return new PVector(avgX, avgY);
}
