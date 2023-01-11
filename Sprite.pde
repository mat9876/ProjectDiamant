public class Sprite {
  PImage image;
  float center_x, center_y;
  float change_x, change_y;
  float w, h;
  float left, right, bottom, top;

  public Sprite(String filename, float scale, float x, float y) {
    image = loadImage(filename);
    w = image.width * scale;
    h = image.height * scale;
    image = scaleImageNoBlur(image, (int)w, (int)h);
    
    center_x = x;
    center_y = y;
    change_x = 0;
    change_y = 0;

    updateBounds();
  }
  public Sprite(String filename, float scale) {
    this(filename, scale, 0, 0);
  }

  public Sprite(PImage img, float scale, float x, float y) {
    image = img;
    w = image.width * scale;
    h = image.height * scale;
    image = scaleImageNoBlur(image, (int)w, (int)h);
    
    center_x = x;
    center_y = y;
    change_x = 0;
    change_y = 0;

    updateBounds();
  }
  public Sprite(PImage img, float scale) {
    this(img, scale, 0, 0);
  }

  public void display(float offset_x, float offset_y) {
    image(image, center_x + offset_x, center_y + offset_y, w, h); 
  }
  
  public void update() {
    center_x += change_x;
    center_y += change_y;
    updateBounds();
  }

  void updateBounds() {
    left = center_x - w/2;
    right = center_x + w/2;
    bottom = center_y + h/2;
    top = center_y - h/2;
  }
  
  void setCenter(float x, float y) {
    center_x = x;
    center_y = y;
    updateBounds();
  }
  void changeCenter(float x, float y) {
    setCenter(center_x + x, center_y + y);
  }

  void setLeft(float coordinate) {
    setCenter(coordinate + w/2, center_y);
  }
  void setRight(float coordinate) {
    setCenter(coordinate - w/2, center_y);
  }
  void setTop(float coordinate) {
    setCenter(center_x, coordinate + h/2);
  }
  void setBottom(float coordinate) {
    setCenter(center_x, coordinate - h/2);
  }
}
