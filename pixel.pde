
class Pixel{

  RPoint pos;
  boolean is_on;
  int id;
  String name;
  color col;

  Pixel(){
    is_on = false;
    col = color(0,0,0);
  }

  int get_id(){
    return id;
  }

  boolean is_on(){
    return is_on;
  }

  void set_id(int i){
    id = i;
  }

  void set_name(String n){
    name = n;
  }

  void set_color(color c){
    col = c;
  }

  void toggle(){
    is_on =! is_on;
    println(is_on);
  }
}
