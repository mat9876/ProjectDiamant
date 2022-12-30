public class Player extends AnimatedSprite{
  boolean onPlatform;
  PImage[] jump;

  public Player(PImage[] stand_img, PImage[] move_img, PImage[] jump_img, float scale) {
    super(new PImage[0], stand_img, move_img, scale);

    jump = jump_img;
    onPlatform = true;
  }

  @Override
  public void selectDirection() {
    super.selectDirection();

    onPlatform = isLanded(this, collidables);
  }

  @Override
  public void selectCurrentImages() {
    super.selectCurrentImages();

    if(!onPlatform) {
      currentImages = jump;
    }
  }
}
