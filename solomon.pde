import geomerative.*;

OPC opc;
RShape grp;
RShape cLine;
RPoint[] onLine;
HashMap<String,Integer> led_map = new HashMap<String,Integer>();
boolean ignoringStyles = true;

void setup(){
  size(2000, 1200);
  smooth();

  // VERY IMPORTANT: Allways initialize the library before using it
  RG.init(this);
  RG.ignoreStyles(ignoringStyles);
  RG.setPolygonizer(RG.UNIFORMSTEP);
  RG.setPolygonizerStep(60);
  // create an RCommand as a straight line and draw it
  //cLine = new RCommand();


  opc = new OPC(this, "192.168.1.8", 7890);
  grp = RG.loadShape("solomon_map_active.svg");
  grp.centerIn(g, 100, 1, 1);
  println(grp.countChildren());
  for (int i = 0; i < 24; i++) {
    led_map.put("H0T" + str(i), i);
    //led_map.put("H1T" + str(i), i+48);
    //led_map.put("H2T" + str(i), i+64);
    //led_map.put("H3T" + str(i), i+88);
  }
  for (int i = 0; i < 20; i++) {
    led_map.put("P0T" + str(i), i+24);
  }
  for (int i = 0; i < 24; i++) {
    led_map.put("H1T" + str(i), i+48);
  }
  //led_map.put("P0T0", 24);
  for (int i = 0; i < 24; i++) {
    led_map.put("H2T" + str(i), i+64);
  }
  for (int i = 0; i < 24; i++) {
    led_map.put("H3T" + str(i), i+88);
  }
}

void draw(){
  translate(width/2, height/2);
  background(100);
  stroke(0);
  noFill();
  stroke(255);
  grp.draw();
  RShape cLine = new RShape();
  cLine.addMoveTo(400,-height/2 + 20);
  cLine.addBezierTo(mouseX, mouseY, 50, 25, 400, height-20);
  cLine.draw();
  onLine = cLine.getPoints();
  //RPoint p = new RPoint(mouseX-width/2, mouseY-height/2);
  for(int i=0;i<grp.countChildren();i++){
    for (RPoint p: onLine){
      ellipse(p.x,p.y,10,10);
      if (grp.children[i].contains(p)) {
        set_pixel(grp.children[i]);
      }
      else{
        //opc.setPixel(i, color(0, 0, 0));
      }
    }

  }
  //opc.setPixel(led_map.get("P0T0"), color(255,0,0));
  opc.writePixels();
}

void set_pixel(RShape shape){
  if (led_map.containsKey(shape.name)){
    println(led_map.get(shape.name));
    opc.setPixel(led_map.get(shape.name), color(0, 100, 20));
      RG.ignoreStyles(true);
    fill(0,100,255,250);
    noStroke();
    shape.draw();
    RG.ignoreStyles(ignoringStyles);
    noFill();
  }

}

void mousePressed(){
  ignoringStyles = !ignoringStyles;
  RG.ignoreStyles(ignoringStyles);
}
