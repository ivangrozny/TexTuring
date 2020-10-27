import gab.opencv.*; OpenCV opencv;
import processing.svg.*;
import processing.pdf.*;

void vectorization( PImage img, String fileName, int format){

    opencv = new OpenCV(this, img );
    opencv.threshold( params.o[1] );
    opencv.invert();

    ArrayList<Contour> contours;
    contours = opencv.findContours();

    PGraphics vecto = null;
    if (format==1) vecto = createGraphics( img.width/3, img.height/3, PDF, fileName );
    if (format==2) vecto = createGraphics( img.width/3, img.height/3, SVG, fileName );
    vecto.beginDraw();
    vecto.background(255);
    vecto.noStroke();
    vecto.fill(0);


    vecto.beginShape();
    for (int j = contours.size()-1 ; j>=0 ; j--) {
        List<PVector> points = contours.get(j).getPoints();

        if ( points.size() > 4 ){

        points = smoothLine( points, 3 );

            if (j<contours.size()-2) vecto.beginContour();

                vecto.vertex( points.get(0).x/3, points.get(0).y/3 );
                // vecto.curveVertex( points.get(points.size()-1).x/3, points.get(points.size()-1).y/3 );
                for ( int i = 0 ; i < points.size() ; i+=4 )
                    vecto.curveVertex( points.get(i).x/3, points.get(i).y/3 );
                vecto.curveVertex( points.get(0).x/3, points.get(0).y/3 );
                vecto.curveVertex( points.get(1).x/3, points.get(1).y/3 );

            if (j<contours.size()-2) vecto.endContour();
        }
    }
    vecto.endShape();
    vecto.dispose();
    vecto.endDraw();
}


import java.util.List;

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

    // // old algo - doesnt take the firsts & lasts pooints

    // List<PVector> smoothedPoints = new ArrayList<PVector>();
    // smoothedPoints.add(points.get(0));
    // PVector newPoint = points.get(1);
    // for(int i = p; i < points.size()-p; i++) {
    //     newPoint = smoothPoint(points.subList(i-p, i+p+1));
    //     smoothedPoints.add( newPoint );
    // }

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
