
class Pixel{

  RPoint pos;
  boolean is_on;
  int id;
  String name;

  Pixel(String n){
    name = n;
    is_on = false;
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

  void toggle(){
    is_on =! is_on;
    println(is_on);
  }
}
