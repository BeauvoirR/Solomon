import java.util.Map;

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

  void update_leds(){
    for (Map.Entry<String, Pixel> me : led_map.entrySet()){
      Pixel p = me.getValue();
      opc.setPixel(p.id, p.col);
    }
    // for(Pixel p: pixel_buffer){
    //   opc.setPixel(p.id, p.col);
    // }

  }

  void set_led(String s, color c){
    Pixel p = led_map.get(s);
    p.set_color(c);
  }

  void increment_index(){
    index += 1;
    println("Index: ",index);
  }
  void increment_led_index(){
    led_index += 1;
    println("LED Index: ", led_index);
  }
  void decrement_index(){
    index -= 1;
    println("Index: ", index);
  }
  void decrement_led_index(){
    led_index -= 1;
    println("LED Index: ", led_index);
  }
  void update_state(status.State state){
    print("Updating");
    current_state = state;
  }

  void display(){
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

  void draw_single_pixel(int index, color c){
    for (int i=0; i<512; i++){
      if (i == index){
        opc.setPixel(index, c);
      }
      else{
        opc.setPixel(i, color(0,0,0));
      }
    }
  }

  void save_mapping(){
     name = grp.children[index].name;
     println(name,led_index);
     json.setInt(name, led_index);
     Pixel p = map.get(name);
     p.toggle();
     p.set_id(led_index);
     map.put(name, p);
  }


  void load_mapping(){
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

  void contains(int x, int y){
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
