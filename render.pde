/*
    class MyThread extends Thread {
      boolean active;
      PApplet p;
      int sizeOut;
      PImage srcMin;
      PImage renderMin;

      MyThread() {
        active = false;
      }

      void start() {
        active = true;
        super.start();
      }
     
      void run ( ) {

        println("run thread : "+sizeOut);
        if(srcMin != null)  renderMin = render( srcMin, sizeOut );
      }

     
      PImage getImg(){
        return renderMin;
      }
     
      boolean isActive() {
          return active;
      }
     
      void quit() {
        active = false;
        interrupt();
      }
    }
*/