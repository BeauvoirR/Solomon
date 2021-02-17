import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import geomerative.*; 
import java.util.Set; 
import java.util.Iterator; 
import java.net.*; 
import java.util.Arrays; 
import java.util.Map; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class solomon extends PApplet {






OPC opc;
int c1,c2;
ControlP5 cp5;
Grid grid;

boolean ignoringStyles = true;
JSONObject json;

public void settings() {
  System.setProperty("jogl.disable.openglcore", "true");
  size(1280, 900, P2D);
  //fullScreen(P3D);
}

public void setup(){
  //size(1000, 900);
  smooth();
  opc = new OPC(this, "192.168.1.2", 7890);
  PFont  f= createFont ("Arial", 25);
  //json = new JSONObject();
  json = loadJSONObject(dataPath("svg_led_mapping.json"));
  cp5 = new ControlP5(this);
  RG.init(this);
  RG.ignoreStyles(ignoringStyles);
  RG.setPolygonizer(RG.UNIFORMSTEP);
  RG.setPolygonizerStep(60);
  grid = new Grid(RG.loadShape(dataPath("solomon_map_active.svg")), status.State.A);
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

public void draw(){
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

public void keyPressed(){
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
public void colorB(int theValue) {
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

public void mouseClicked(){
  grid.contains(mouseX-width/2, mouseY-height/2);
}
/*
 * Simple Open Pixel Control client for Processing,
 * designed to sample each LED's color from some point on the canvas.
 *
 * Micah Elizabeth Scott, 2013
 * This file is released into the public domain.
 */




public class OPC implements Runnable
{
  Thread thread;
  Socket socket;
  OutputStream output, pending;
  String host;
  int port;

  int[] pixelLocations;
  byte[] packetData;
  byte firmwareConfig;
  String colorCorrection;
  boolean enableShowLocations;

  OPC(PApplet parent, String host, int port)
  {
    this.host = host;
    this.port = port;
    thread = new Thread(this);
    thread.start();
    this.enableShowLocations = true;
    parent.registerMethod("draw", this);
  }

  // Set the location of a single LED
  public void led(int index, int x, int y)  
  {
    // For convenience, automatically grow the pixelLocations array. We do want this to be an array,
    // instead of a HashMap, to keep draw() as fast as it can be.
    if (pixelLocations == null) {
      pixelLocations = new int[index + 1];
    } else if (index >= pixelLocations.length) {
      pixelLocations = Arrays.copyOf(pixelLocations, index + 1);
    }

    pixelLocations[index] = x + width * y;
  }
  
  // Set the location of several LEDs arranged in a strip.
  // Angle is in radians, measured clockwise from +X.
  // (x,y) is the center of the strip.
  public void ledStrip(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(reversed ? (index + count - 1 - i) : (index + i),
        (int)(x + (i - (count-1)/2.0f) * spacing * c + 0.5f),
        (int)(y + (i - (count-1)/2.0f) * spacing * s + 0.5f));
    }
  }

  // Set the locations of a ring of LEDs. The center of the ring is at (x, y),
  // with "radius" pixels between the center and each LED. The first LED is at
  // the indicated angle, in radians, measured clockwise from +X.
  public void ledRing(int index, int count, float x, float y, float radius, float angle)
  {
    for (int i = 0; i < count; i++) {
      float a = angle + i * 2 * PI / count;
      led(index + i, (int)(x - radius * cos(a) + 0.5f),
        (int)(y - radius * sin(a) + 0.5f));
    }
  }

  // Set the location of several LEDs arranged in a grid. The first strip is
  // at 'angle', measured in radians clockwise from +X.
  // (x,y) is the center of the grid.
  public void ledGrid(int index, int stripLength, int numStrips, float x, float y,
               float ledSpacing, float stripSpacing, float angle, boolean zigzag,
               boolean flip)
  {
    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      ledStrip(index + stripLength * i, stripLength,
        x + (i - (numStrips-1)/2.0f) * stripSpacing * c,
        y + (i - (numStrips-1)/2.0f) * stripSpacing * s, ledSpacing,
        angle, zigzag && ((i % 2) == 1) != flip);
    }
  }

  // Set the location of 64 LEDs arranged in a uniform 8x8 grid.
  // (x,y) is the center of the grid.
  public void ledGrid8x8(int index, float x, float y, float spacing, float angle, boolean zigzag,
                  boolean flip)
  {
    ledGrid(index, 8, 8, x, y, spacing, spacing, angle, zigzag, flip);
  }

  // Should the pixel sampling locations be visible? This helps with debugging.
  // Showing locations is enabled by default. You might need to disable it if our drawing
  // is interfering with your processing sketch, or if you'd simply like the screen to be
  // less cluttered.
  public void showLocations(boolean enabled)
  {
    enableShowLocations = enabled;
  }
  
  // Enable or disable dithering. Dithering avoids the "stair-stepping" artifact and increases color
  // resolution by quickly jittering between adjacent 8-bit brightness levels about 400 times a second.
  // Dithering is on by default.
  public void setDithering(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x01;
    else
      firmwareConfig |= 0x01;
    sendFirmwareConfigPacket();
  }

  // Enable or disable frame interpolation. Interpolation automatically blends between consecutive frames
  // in hardware, and it does so with 16-bit per channel resolution. Combined with dithering, this helps make
  // fades very smooth. Interpolation is on by default.
  public void setInterpolation(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x02;
    else
      firmwareConfig |= 0x02;
    sendFirmwareConfigPacket();
  }

  // Put the Fadecandy onboard LED under automatic control. It blinks any time the firmware processes a packet.
  // This is the default configuration for the LED.
  public void statusLedAuto()
  {
    firmwareConfig &= 0x0C;
    sendFirmwareConfigPacket();
  }    

  // Manually turn the Fadecandy onboard LED on or off. This disables automatic LED control.
  public void setStatusLed(boolean on)
  {
    firmwareConfig |= 0x04;   // Manual LED control
    if (on)
      firmwareConfig |= 0x08;
    else
      firmwareConfig &= ~0x08;
    sendFirmwareConfigPacket();
  } 

  // Set the color correction parameters
  public void setColorCorrection(float gamma, float red, float green, float blue)
  {
    colorCorrection = "{ \"gamma\": " + gamma + ", \"whitepoint\": [" + red + "," + green + "," + blue + "]}";
    sendColorCorrectionPacket();
  }
  
  // Set custom color correction parameters from a string
  public void setColorCorrection(String s)
  {
    colorCorrection = s;
    sendColorCorrectionPacket();
  }

  // Send a packet with the current firmware configuration settings
  public void sendFirmwareConfigPacket()
  {
    if (pending == null) {
      // We'll do this when we reconnect
      return;
    }
 
    byte[] packet = new byte[9];
    packet[0] = (byte)0x00; // Channel (reserved)
    packet[1] = (byte)0xFF; // Command (System Exclusive)
    packet[2] = (byte)0x00; // Length high byte
    packet[3] = (byte)0x05; // Length low byte
    packet[4] = (byte)0x00; // System ID high byte
    packet[5] = (byte)0x01; // System ID low byte
    packet[6] = (byte)0x00; // Command ID high byte
    packet[7] = (byte)0x02; // Command ID low byte
    packet[8] = (byte)firmwareConfig;

    try {
      pending.write(packet);
    } catch (Exception e) {
      dispose();
    }
  }

  // Send a packet with the current color correction settings
  public void sendColorCorrectionPacket()
  {
    if (colorCorrection == null) {
      // No color correction defined
      return;
    }
    if (pending == null) {
      // We'll do this when we reconnect
      return;
    }

    byte[] content = colorCorrection.getBytes();
    int packetLen = content.length + 4;
    byte[] header = new byte[8];
    header[0] = (byte)0x00;               // Channel (reserved)
    header[1] = (byte)0xFF;               // Command (System Exclusive)
    header[2] = (byte)(packetLen >> 8);   // Length high byte
    header[3] = (byte)(packetLen & 0xFF); // Length low byte
    header[4] = (byte)0x00;               // System ID high byte
    header[5] = (byte)0x01;               // System ID low byte
    header[6] = (byte)0x00;               // Command ID high byte
    header[7] = (byte)0x01;               // Command ID low byte

    try {
      pending.write(header);
      pending.write(content);
    } catch (Exception e) {
      dispose();
    }
  }

  // Automatically called at the end of each draw().
  // This handles the automatic Pixel to LED mapping.
  // If you aren't using that mapping, this function has no effect.
  // In that case, you can call setPixelCount(), setPixel(), and writePixels()
  // separately.
  public void draw()
  {
    if (pixelLocations == null) {
      // No pixels defined yet
      return;
    }
    if (output == null) {
      return;
    }

    int numPixels = pixelLocations.length;
    int ledAddress = 4;

    setPixelCount(numPixels);
    loadPixels();

    for (int i = 0; i < numPixels; i++) {
      int pixelLocation = pixelLocations[i];
      int pixel = pixels[pixelLocation];

      packetData[ledAddress] = (byte)(pixel >> 16);
      packetData[ledAddress + 1] = (byte)(pixel >> 8);
      packetData[ledAddress + 2] = (byte)pixel;
      ledAddress += 3;

      if (enableShowLocations) {
        pixels[pixelLocation] = 0xFFFFFF ^ pixel;
      }
    }

    writePixels();

    if (enableShowLocations) {
      updatePixels();
    }
  }
  
  // Change the number of pixels in our output packet.
  // This is normally not needed; the output packet is automatically sized
  // by draw() and by setPixel().
  public void setPixelCount(int numPixels)
  {
    int numBytes = 3 * numPixels;
    int packetLen = 4 + numBytes;
    if (packetData == null || packetData.length != packetLen) {
      // Set up our packet buffer
      packetData = new byte[packetLen];
      packetData[0] = (byte)0x00;              // Channel
      packetData[1] = (byte)0x00;              // Command (Set pixel colors)
      packetData[2] = (byte)(numBytes >> 8);   // Length high byte
      packetData[3] = (byte)(numBytes & 0xFF); // Length low byte
    }
  }
  
  // Directly manipulate a pixel in the output buffer. This isn't needed
  // for pixels that are mapped to the screen.
  public void setPixel(int number, int c)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      setPixelCount(number + 1);
    }

    packetData[offset] = (byte) (c >> 16);
    packetData[offset + 1] = (byte) (c >> 8);
    packetData[offset + 2] = (byte) c;
  }
  
  // Read a pixel from the output buffer. If the pixel was mapped to the display,
  // this returns the value we captured on the previous frame.
  public int getPixel(int number)
  {
    int offset = 4 + number * 3;
    if (packetData == null || packetData.length < offset + 3) {
      return 0;
    }
    return (packetData[offset] << 16) | (packetData[offset + 1] << 8) | packetData[offset + 2];
  }

  // Transmit our current buffer of pixel values to the OPC server. This is handled
  // automatically in draw() if any pixels are mapped to the screen, but if you haven't
  // mapped any pixels to the screen you'll want to call this directly.
  public void writePixels()
  {
    if (packetData == null || packetData.length == 0) {
      // No pixel buffer
      return;
    }
    if (output == null) {
      return;
    }

    try {
      output.write(packetData);
    } catch (Exception e) {
      dispose();
    }
  }

  public void dispose()
  {
    // Destroy the socket. Called internally when we've disconnected.
    // (Thread continues to run)
    if (output != null) {
      println("Disconnected from OPC server");
    }
    socket = null;
    output = pending = null;
  }

  public void run()
  {
    // Thread tests server connection periodically, attempts reconnection.
    // Important for OPC arrays; faster startup, client continues
    // to run smoothly when mobile servers go in and out of range.
    for(;;) {

      if(output == null) { // No OPC connection?
        try {              // Make one!
          socket = new Socket(host, port);
          socket.setTcpNoDelay(true);
          pending = socket.getOutputStream(); // Avoid race condition...
          println("Connected to OPC server");
          sendColorCorrectionPacket();        // These write to 'pending'
          sendFirmwareConfigPacket();         // rather than 'output' before
          output = pending;                   // rest of code given access.
          // pending not set null, more config packets are OK!
        } catch (ConnectException e) {
          dispose();
        } catch (IOException e) {
          dispose();
        }
      }

      // Pause thread to avoid massive CPU load
      try {
        Thread.sleep(500);
      }
      catch(InterruptedException e) {
      }
    }
  }
}


static class status {
   enum State {A,B,C};
}

class Grid {

  HashMap<String,Pixel> led_map;
  HashMap<String,Pixel> map;
  RShape grp;
  RShape cLine;
  RPoint[] onLine;
  status.State current_state;
  int index;
  int led_index;
  String name;
  Pixel[] pixel_buffer;

  Grid(RShape svg, status.State init_status){
    index = 0;
    grp = svg;
    led_map = new HashMap<String,Pixel>();
    map = new HashMap<String,Pixel>();
    current_state = init_status;
    // VERY IMPORTANT: Allways initialize the library before using it
    grp.centerIn(g, 100, 1, 1);
    name = grp.children[index].name;
    // Construct map
    for(int i=0;i<grp.countChildren();i++){
      Pixel p = new Pixel();
      p.set_name(grp.children[i].name);
      map.put(grp.children[i].name, p);
    }
    load_mapping();
  }

  public void update_leds(){
    for (Map.Entry<String, Pixel> me : led_map.entrySet()){
      Pixel p = me.getValue();
      opc.setPixel(p.id, p.col);
    }
    // for(Pixel p: pixel_buffer){
    //   opc.setPixel(p.id, p.col);
    // }

  }

  public void set_led(String s, int c){
    Pixel p = led_map.get(s);
    p.set_color(c);
  }

  public void increment_index(){
    index += 1;
    println("Index: ",index);
  }
  public void increment_led_index(){
    led_index += 1;
    println("LED Index: ", led_index);
  }
  public void decrement_index(){
    index -= 1;
    println("Index: ", index);
  }
  public void decrement_led_index(){
    led_index -= 1;
    println("LED Index: ", led_index);
  }
  public void update_state(status.State state){
    print("Updating");
    current_state = state;
  }

  public void display(){
    switch (current_state) {
        case A :
            // Using an enhanced loop to iterate over each entry
            for (Map.Entry<String, Pixel> me : led_map.entrySet()) {
              Pixel p = me.getValue();
              if (p.is_on){
                set_led(p.name, color(100,70,40));
                fill(255);
                grp.getChild(p.name).draw();
                noFill();
              }
            }
            break;
        case B :
            //println("B");
           //load_mapping();
           //set_led(led_index, color(150, 100, 20));
           // for (Map.Entry entry : map.entrySet()) {
           //   Pixel p = map.get(entry.getKey());
           //   if (p.is_on()){
           //     fill(255);
           //     grp.getChild(p.name).draw();
           //     set_led(p.id, color(100, 100, 20));
           //     noFill();
           //   }
           //   else{
           //     noFill();
           //     opc.setPixel(p.id, color(0, 0, 0));
           //   }
           // }
           //  fill(255);
           //  grp.children[index].draw();

            //opc.setPixel(0, color(150,100,35));

            noFill();
            break;
        case C :
            //println("C");
            break;
        }
    grp.draw();
    update_leds();
    opc.writePixels();
  }

  public void draw_single_pixel(int index, int c){
    for (int i=0; i<512; i++){
      if (i == index){
        opc.setPixel(index, c);
      }
      else{
        opc.setPixel(i, color(0,0,0));
      }
    }
  }

  public void save_mapping(){
     name = grp.children[index].name;
     println(name,led_index);
     json.setInt(name, led_index);
     Pixel p = map.get(name);
     p.toggle();
     p.set_id(led_index);
     map.put(name, p);
  }


  public void load_mapping(){
    println("LOADING");
    //int iterator = 0;
    Set<String> keys = json.keys();
    //pixel_buffer = new Pixel[keys.size()];
    for(String s : keys){
      Pixel p = new Pixel();
      p.set_id(json.getInt(s));
      p.set_name(s);
      led_map.put(s, p);
      //pixel_buffer[iterator] = p;
      //iterator += 1;
    }
  }

  public void contains(int x, int y){
    RPoint point = new RPoint(x, y);
    //RPoint p = new RPoint(mouseX-width/2, mouseY-height/2);
    for(int i=0;i<grp.countChildren();i++){
      if (grp.children[i].contains(point)) {
        //Pixel pix = map.get(grp.children[i].name);
        //Pixel p = pixel_buffer[i];
        Pixel p = led_map.get(grp.children[i].name);
        println(p.get_id());
        p.toggle();
      }
    }
  }
}

class Pixel{

  RPoint pos;
  boolean is_on;
  int id;
  String name;
  int col;

  Pixel(){
    is_on = false;
    col = color(0,0,0);
  }

  public int get_id(){
    return id;
  }

  public boolean is_on(){
    return is_on;
  }

  public void set_id(int i){
    id = i;
  }

  public void set_name(String n){
    name = n;
  }

  public void set_color(int c){
    col = c;
  }

  public void toggle(){
    is_on =! is_on;
    println(is_on);
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "solomon" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
