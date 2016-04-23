import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.geom.GeneralPath;
import java.awt.geom.Point2D;
import java.awt.image.BufferedImage;
import java.awt.image.WritableRaster;
import java.io.*;
import java.io.Writer;
import java.io.OutputStreamWriter;
import java.io.File;
import java.io.IOException;
import java.util.*;
import org.apache.batik.svggen.SVGGraphics2D;
import org.apache.batik.dom.GenericDOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.DOMImplementation;

param_t param = new param_t();
Bitmap bmp;
PoTraceJ poTraceJ = new PoTraceJ(param);
BufferedImage result;


void svgConverter( PImage input, float scale, String filePath ){
    PoTraceJ poTraceJ = new PoTraceJ(param);
    path_t trace = null;

    bmp = new Bitmap( input.width, input.height );
    for(int y=0; y<input.height; y++) {
        for(int x=0; x<input.width; x++) {

            if ( brightness( input.get(x, y) ) < params.o[1] ) {
                bmp.put(x, y, 255 );
            } else {
                bmp.put(x, y, 0 );
            }
        }
    } 


    trace = poTraceJ.trace(bmp);

    ArrayList<PathElement> al = new ArrayList<PathElement>();
    ConvertToJavaCurves.convert(trace, new HashSet<ConvertToJavaCurves.Point>(), al);

    DOMImplementation domImpl = GenericDOMImplementation.getDOMImplementation();
    String svgNS = "http://www.w3.org/2000/svg";
    Document document = domImpl.createDocument(svgNS, "svg", null);

    SVGGraphics2D g2 = new SVGGraphics2D(document);
        g2.scale(scale, scale);
        g2.setColor(Color.WHITE);
        g2.fillRect(0, 0, bmp.getWidth(), bmp.getHeight());
        g2.setColor(Color.BLACK);
        g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g2.setRenderingHint(RenderingHints.KEY_FRACTIONALMETRICS, RenderingHints.VALUE_FRACTIONALMETRICS_ON);
        g2.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        GeneralPath path = new GeneralPath();
        for (PathElement pathElement : al) {
            switch (pathElement.getType()) {
                case CLOSE_PATH:
                    path.closePath();
                    break;
                case LINE_TO:
                    path.lineTo(pathElement.getP0x(), pathElement.getP0y());
                    break;
                case MOVE_TO:
                    path.moveTo(pathElement.getP0x(), pathElement.getP0y());
                    break;
                case CURVE_TO:
                    path.curveTo(pathElement.getP0x(), pathElement.getP0y(), pathElement.getP1x(), pathElement.getP1y(), pathElement.getP2x(), pathElement.getP2y());
                    break;
            }
        }
        g2.setPaint(Color.black);
        g2.fill(path);

   try {
    Writer out = new FileWriter(filePath);
    g2.stream(out, false);
    out.close();
   } catch (Exception e) {
    println(e);
   }
}



/*
// processing path to svg - didn't work well ...

        beginRecord(SVG, "output.svg");
        background(255);
        stroke(0);
        int i = 0;

        PShape s = createShape();
        s.colorMode(HSB);
        

        for (PathElement pathElement : al) {
            println(" "+pathElement.getType());
            switch (pathElement.getType()) { 
                case CLOSE_PATH:
                    s.endShape(CLOSE);
                    break;

                case LINE_TO:
                    s.vertex((float)pathElement.getP0x(), (float)pathElement.getP0y());
                    break;

                case MOVE_TO:
                    s.beginShape();
                    s.fill(i,255,127);
                    s.vertex((float)pathElement.getP0x(), (float)pathElement.getP0y());
                    break;

                case CURVE_TO:
                    s.bezierVertex( (float)pathElement.getP0x(), (float)pathElement.getP0y(), 
                        (float)pathElement.getP1x(), (float)pathElement.getP1y(), 
                        (float)pathElement.getP2x(), (float)pathElement.getP2y() );
                    break;

                case POP_PARENT:
                    s.beginContour();
                    i+=50;
                    s.fill( color(i,255,127) );
                    break; 
                case PUSH_PARENT:
                    s.endContour();
                    i-=50;
                    break;
            }
        }
        stroke(0);
        shape(s, 25, 25);
        endRecord();
*/