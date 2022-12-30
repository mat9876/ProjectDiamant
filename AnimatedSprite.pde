public class AnimatedSprite extends Sprite{
  PImage[] currentImages = null;
  PImage[] neutral;
  PImage[] stand;
  PImage[] move;
  int index;
  int frame;
  int direction;
  boolean has_neutral;
  boolean inPlace;
  
// Define an animated sprite and its location
  public AnimatedSprite(PImage[] neutral_img, PImage[] stand_img, PImage[] move_img, float scale) {
    super(stand_img[0], scale);
    
    neutral = neutral_img;
    stand = stand_img;
    move = move_img;

    index = 0;
    frame = 0;
    has_neutral = neutral_img.length > 0;
    inPlace = true;

    if (has_neutral) {
      currentImages = neutral;
      direction = NEUTRAL_FACING;
    }
    else {
      currentImages = stand;
      direction = RIGHT_FACING;
    }
  }

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
 // Check every 5 frames (1/20 of a second) if the animation needs to be updated(saves resources)
  public void updateAnimation() {
    selectDirection();
    selectCurrentImages();

    if(frame % 5 == 0) {
      advanceToNextImage();
    }

    frame++;
  }
  // Find the action the player is performing and display the next image
  public void selectDirection() {
    inPlace = change_x == 0 && change_y == 0;
    if(change_x > 0) {
      direction = RIGHT_FACING;
    }
    else if(change_x < 0) {
      direction = LEFT_FACING;
    }
    else if (has_neutral) {
      direction = NEUTRAL_FACING;  
    }
  }
  // Find the right action that suits the player currents action
  public void selectCurrentImages() {
    if (inPlace) {
      currentImages = stand;
    }
    else {
      currentImages = move;
    }
  }
// Continue the animation if the player hasn't changed an action
  public void advanceToNextImage() {
    image = currentImages[index % currentImages.length];   
    index++;
  }
}
