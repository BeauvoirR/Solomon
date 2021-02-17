import controlP5.*;
import geomerative.*;
import java.util.Set;
import java.util.Iterator;
import java.util.*;


OPC opc;
int c1,c2;
ControlP5 cp5;
Grid grid;
PFont f;
int fontSize = 32;
boolean ignoringStyles = true;
JSONObject json;

void settings() {
  System.setProperty("jogl.disable.openglcore", "true");
  size(1280, 900, P2D);
  //fullScreen(P3D);
}

void setup(){
  //size(1000, 900);
  smooth();
  opc = new OPC(this, "192.168.1.2", 7890);
  //PFont f = createFont ("Arial", 25);
  f = createFont("DINCond-Regular.ttf", fontSize);
  textFont(f, fontSize);
  //json = new JSONObject();
  json = loadJSONObject(dataPath("svg_led_mapping.json"));
  cp5 = new ControlP5(this);
  RG.init(this);
  RG.ignoreStyles(ignoringStyles);
  RG.setPolygonizer(RG.UNIFORMSTEP);
  RG.setPolygonizerStep(60);
  grid = new Grid(RG.loadShape(dataPath("solomon_map_active.svg")), Interface.State.INACTIVE);
  // create a new button with name 'buttonA'
  // cp5.addButton("colorA")
  //    .setBroadcast(false)
  //    .setValue(0)
  //    .setPosition(100,100)
  //    .setSize(100,40)
  //    .setLabel("LED OFF")
  //    .setFont(f)
  //    ;
  // and add another 2 buttons



  // cp5.addButton("colorB")
  //    .setBroadcast(false)
  //    .setValue(100)
  //    .setPosition(100,140)
  //    .setSize(100,40)
  //    .setBroadcast(true)
  //    ;
  //
  // cp5.addButton("colorC")
  //    .setBroadcast(false)
  //    .setPosition(100,180)
  //    .setSize(100,40)
  //    .setValue(0)
  //    .setBroadcast(true)
  //    ;
  List l = Arrays.asList("INACTIVE", "DRAW", "SETUP");
  cp5.addScrollableList("dropdown")
    .setPosition(10, 10)
    .setSize(200, 140)
    .setBarHeight(40)
    .setItemHeight(40)
    .addItems(l)
    // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
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
  text("TEST", 10,100);
}

void dropdown(int n) {
  /* request the selected item based on index n */

  Map s = cp5.get(ScrollableList.class, "dropdown").getItem(n);
  println(n, s);
  switch(n){
    case 0:
      grid.update_state(Interface.State.INACTIVE);
    case 1:
      grid.update_state(Interface.State.DRAW);
    case 2:
      grid.update_state(Interface.State.SETUP);
  }
  /* here an item is stored as a Map  with the following key-value pairs:
   * name, the given name of the item
   * text, the given text of the item by default the same as name
   * value, the given value of the item, can be changed by using .getItem(n).put("value", "abc"); a value here is of type Object therefore can be anything
   * color, the given color of the item, how to change, see below
   * view, a customizable view, is of type CDrawable
   */
  //grid.update_state(status.State.B);
  CColor c = new CColor();
  c.setBackground(color(255,0,0));
  cp5.get(ScrollableList.class, "dropdown").getItem(n).put("color", c);

}

void mouseClicked(){
  grid.contains(mouseX-width/2, mouseY-height/2);
}

void keyPressed(){
  if (grid.current_state == Interface.State.SETUP){
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

// public void controlEvent(ControlEvent theEvent) {
//   println(theEvent.getController().getName());
// }
//
//
// // function colorB will receive changes from
// // controller with name colorB
// void colorB(int theValue) {
//   //println("a button event from colorB: "+theValue);
//   grid.update_state(Interface.State.SETUP);
//   // for(int i=0;i<grid.countChildren();i++){
//   //   opc.setPixel(i, color(10, 100, 40));
//   // }
//   // opc.writePixels();
// }
//
// public void colorA(int theValue) {
//   // println("a button event from colorB: "+theValue);
//   // for(int i=0;i<grid.countChildren();i++){
//   //   opc.setPixel(i, color(0, 0, 0));
//   // }
//   // opc.writePixels();
// }
