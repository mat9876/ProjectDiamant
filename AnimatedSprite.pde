public class AnimatedSprite extends Sprite{
  PImage[] currentImages;
  PImage[] standNeutral;
  PImage[] move;
  int index;
  int frame;
  int direction;

  @Override
  public void display(float offset_x, float offset_y) {
    if (direction == LEFT_FACING) {
      pushMatrix();
      scale(-1, 1);
      image(image, -center_x - offset_x, center_y + offset_y, w, h);
      popMatrix();
    }
    else {
      super.display(offset_x, offset_y);
    }
  }
  
  public AnimatedSprite(PImage img, float scale) {
    super(img, scale);
    direction = NEUTRAL_FACING;
    index = 0;
    frame = 0;
  }
  
  public void updateAnimation() {
    selectDirection();
    selectCurrentImages();

    if(frame % 5 == 0) {
      advanceToNextImage();
    }

    frame++;
  }
  
  public void selectDirection() {
    if(change_x > 0) {
      direction = RIGHT_FACING;
    }
    else if(change_x < 0) {
      direction = LEFT_FACING;
    }
    else {
      direction = NEUTRAL_FACING;  
    }
  }
  
  public void selectCurrentImages() {
    if (direction != NEUTRAL_FACING) {
      currentImages = move;
    }
    else {
      currentImages = standNeutral;
    }
  }

  public void advanceToNextImage() {
    image = currentImages[index % currentImages.length];   
    index++;
  }
}
