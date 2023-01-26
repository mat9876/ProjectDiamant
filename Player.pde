public class Player extends AnimatedSprite{
  boolean onPlatform;
  PImage[] jump;

  public Player(PImage[] stand_img, PImage[] move_img, PImage[] jump_img, float scale) {
    super(new PImage[0], stand_img, move_img, scale);

    setCenter(-200, -200);

    jump = jump_img;
    for (int i = 0; i < jump.length; i++) {
      jump[i] = scaleImageNoBlur(jump[i], (int)w, (int)h);
    }

    onPlatform = true;
  }

  // Extend relevant functions to discern between jump and stand states
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
