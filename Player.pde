public class Player extends AnimatedSprite{
  boolean onPlatform;
  PImage[] jump;
//Logic for selecting the right image based on the characters action
  public Player(PImage[] stand_img, PImage[] move_img, PImage[] jump_img, float scale) {
    super(new PImage[0], stand_img, move_img, scale);

    setCenter(-200, -200);

    jump = jump_img;
    for (int i = 0; i < jump.length; i++) {
      jump[i] = scaleImageNoBlur(jump[i], (int)w, (int)h);
    }

    onPlatform = true;
  }
//Override the current animation if the players changes action
  @Override
  public void selectDirection() {
    super.selectDirection();

    onPlatform = isLanded(this, collidables);
  }
//Override the current image based on the current player action
  @Override
  public void selectCurrentImages() {
    super.selectCurrentImages();

    if(!onPlatform) {
      currentImages = jump;
    }
  }
}
