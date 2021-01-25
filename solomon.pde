import controlP5.*;
import geomerative.*;
import java.util.Set;
import java.util.Iterator;

OPC opc;
int c1,c2;
ControlP5 cp5;
Grid grid;

boolean ignoringStyles = true;
JSONObject json;

void setup(){
  size(1000, 900);
  smooth();
  opc = new OPC(this, "192.168.1.10", 7890);
  PFont  f= createFont ("Arial", 25);
  //json = new JSONObject();
  json = loadJSONObject("svg_led_mapping.json");
  cp5 = new ControlP5(this);
  RG.init(this);
  RG.ignoreStyles(ignoringStyles);
  RG.setPolygonizer(RG.UNIFORMSTEP);
  RG.setPolygonizerStep(60);
  grid = new Grid(RG.loadShape("solomon_map_active.svg"), status.State.A);
  // create a new button with name 'buttonA'
  cp5.addButton("colorA")
     .setBroadcast(false)
     .setValue(0)
     .setPosition(100,100)
     .setSize(100,40)
     .setLabel("LED OFF")
     .setFont(f)
     ;
  // and add another 2 buttons
  cp5.addButton("colorB")
     .setBroadcast(false)
     .setValue(100)
     .setPosition(100,140)
     .setSize(100,40)
     .setBroadcast(true)
     ;

  cp5.addButton("colorC")
     .setBroadcast(false)
     .setPosition(100,180)
     .setSize(100,40)
     .setValue(0)
     .setBroadcast(true)
     ;
  
}

void draw(){
  pushMatrix();
  translate(width/2, height/2);
  background(100);
  stroke(0);
  noFill();
  grid.display();
  // grp.draw();
  // RShape cLine = new RShape();
  // cLine.addMoveTo(400,-height/2 + 20);
  // //cLine.addBezierTo(mouseX, mouseY, 50, 25, 400, height-20);
  // cLine.addBezierTo(10, 20, 50, 25, 400, height-20);
  // cLine.draw();
  // onLine = cLine.getPoints();
  // //RPoint p = new RPoint(mouseX-width/2, mouseY-height/2);
  // for(int i=0;i<grp.countChildren();i++){
  //   for (RPoint p: onLine){
  //     ellipse(p.x,p.y,10,10);
  //     if (grp.children[i].contains(p)) {
  //       set_pixel(grp.children[i]);
  //     }
  //     else{
  //       //opc.setPixel(i, color(0, 0, 0));
  //     }
  //   }
  //
  // }
  //opc.setPixel(led_map.get("P0T0"), color(255,0,0));
  //opc.writePixels();
  popMatrix();
}

void keyPressed(){
  if (grid.current_state == status.State.B){
    switch(keyCode){
      case RIGHT:
        grid.increment_index();
        break;
      case LEFT:
        grid.decrement_index();
        break;
      case UP:
        grid.increment_led_index();
        break;
      case DOWN:
        grid.decrement_led_index();
        break;
    }
    switch(key){
      case 'm':
        println("SAVING");
        grid.save_mapping();
        break;
      case 's':
        //save map to json
        saveJSONObject(json, "svg_led_mapping.json");
        break;
      case 'l':
        grid.load_mapping();
    }
  }
}

// void set_pixel(RShape shape){
//   if (led_map.containsKey(shape.name)){
//     //println(led_map.get(shape.name));
//     opc.setPixel(led_map.get(shape.name), color(0, 100, 20));
//       RG.ignoreStyles(true);
//     fill(0,100,255,250);
//     noStroke();
//     shape.draw();
//     RG.ignoreStyles(ignoringStyles);
//     noFill();
//   }
// }

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
}


// function colorB will receive changes from
// controller with name colorB
void colorB(int theValue) {
  //println("a button event from colorB: "+theValue);
  grid.update_state(status.State.B);
  // for(int i=0;i<grid.countChildren();i++){
  //   opc.setPixel(i, color(10, 100, 40));
  // }
  // opc.writePixels();
}

public void colorA(int theValue) {
  // println("a button event from colorB: "+theValue);
  // for(int i=0;i<grid.countChildren();i++){
  //   opc.setPixel(i, color(0, 0, 0));
  // }
  // opc.writePixels();
}

void mouseClicked(){
  grid.contains(mouseX-width/2, mouseY-height/2);
}
