public class Player extends AnimatedSprite{
  boolean onPlatform, inPlace;
  PImage[] stand;
  PImage[] jump;
  public Player(PImage img, float scale) {
    super(img, scale);
    direction = RIGHT_FACING;
    onPlatform = true;
    inPlace = true;
    stand = new PImage[1];
    stand[0] = loadImage("YSquare.png");
    move = new PImage[2];
    move[0] = loadImage("YSquare_1.png");
    move[1] = loadImage("YSquare_2.png"); 
    jump = new PImage[1];
    jump[0] = loadImage("YSquare_Jump.png");
    currentImages = stand;
  }

  @Override
  public void updateAnimation() {
    onPlatform = isLanded(this, collidables);
    inPlace = change_x == 0 && change_y == 0;
    super.updateAnimation();
  }

  @Override
  public void selectDirection() {
    if(change_x > 0) {
      direction = RIGHT_FACING;
    }
    else if(change_x < 0) {
      direction = LEFT_FACING;
    }
  }

  @Override
  public void selectCurrentImages() {
    if(inPlace) {
      currentImages = stand;
    }
    else if(!onPlatform) {
      currentImages = jump;
    }
    else {
      currentImages = move;
    }
  }
}
