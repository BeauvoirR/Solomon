import controlP5.*;
import geomerative.*;

OPC opc;
RShape grp;
RShape cLine;
RPoint[] onLine;


int c1,c2;

ControlP5 cp5;

HashMap<String,Integer> led_map = new HashMap<String,Integer>();
boolean ignoringStyles = true;

void setup(){
  size(1000, 900);
  smooth();
  cp5 = new ControlP5(this);
  
  // create a new button with name 'buttonA'
  cp5.addButton("colorA")
     .setValue(0)
     .setPosition(100,100)
     .setSize(200,19)
     ;
  
  // and add another 2 buttons
  cp5.addButton("colorB")
     .setValue(100)
     .setPosition(100,120)
     .setSize(200,19)
     ;
     
  cp5.addButton("colorC")
     .setPosition(100,140)
     .setSize(200,19)
     .setValue(0)
     ;
  // VERY IMPORTANT: Allways initialize the library before using it
  RG.init(this);
  RG.ignoreStyles(ignoringStyles);
  RG.setPolygonizer(RG.UNIFORMSTEP);
  RG.setPolygonizerStep(60);
  // create an RCommand as a straight line and draw it
  //cLine = new RCommand();


  opc = new OPC(this, "192.168.1.10", 7890);
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
  pushMatrix();  
  translate(width/2, height/2);
  background(100);
  stroke(0);
  noFill();
  grp.draw();
  RShape cLine = new RShape();
  cLine.addMoveTo(400,-height/2 + 20);
  //cLine.addBezierTo(mouseX, mouseY, 50, 25, 400, height-20);
  cLine.addBezierTo(10, 20, 50, 25, 400, height-20);
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
  popMatrix();
}

void set_pixel(RShape shape){
  if (led_map.containsKey(shape.name)){
    //println(led_map.get(shape.name));
    opc.setPixel(led_map.get(shape.name), color(0, 100, 20));
      RG.ignoreStyles(true);
    fill(0,100,255,250);
    noStroke();
    shape.draw();
    RG.ignoreStyles(ignoringStyles);
    noFill();
  }
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
}


// function colorB will receive changes from 
// controller with name colorB
public void colorB(int theValue) {
  println("a button event from colorB: "+theValue);
  for(int i=0;i<grp.countChildren();i++){
    opc.setPixel(i, color(10, 100, 40));
  }
  opc.writePixels();
}

public void colorA(int theValue) {
  println("a button event from colorB: "+theValue);
  for(int i=0;i<grp.countChildren();i++){
    opc.setPixel(i, color(0, 0, 0));
  }
  opc.writePixels();
}

public void play(int theValue) {
  println("a button event from buttonB: "+theValue);
  c1 = c2;
  c2 = color(0,0,0);
}
