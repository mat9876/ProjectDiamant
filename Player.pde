public class Player extends AnimatedSprite{
  boolean onPlatform, inPlace;
  PImage[] standLeft;
  PImage[] standRight;
  PImage[] jumpLeft;
  PImage[] jumpRight;
  public Player(PImage img, float scale){
    super(img, scale);
    direction = RIGHT_FACING;
    onPlatform = true;
    inPlace = true;
    standLeft = new PImage[1];
    standLeft[0] = loadImage("YSquare_left.png");
    standRight = new PImage[1];
    standRight[0] = loadImage("YSquare.png");
    moveLeft = new PImage[2];
    moveLeft[0] = loadImage("YSquare_1_left.png");
    moveLeft[1] = loadImage("YSquare_2_left.png");
    moveRight = new PImage[2];
    moveRight[0] = loadImage("YSquare_1.png");
    moveRight[1] = loadImage("YSquare_2.png"); 
    jumpRight = new PImage[1];
    jumpRight[0] = loadImage("YSquare_Jump.png");
    jumpLeft = new PImage[1];
    jumpLeft[0] = loadImage("YSquare_Jump_Left.png");
    currentImages = standRight;
  }
  @Override
  public void updateAnimation(){
    onPlatform = isLanded(this, platforms);
    inPlace = change_x == 0 && change_y == 0;
    super.updateAnimation();

  }
  @Override
  public void selectDirection(){
    if(change_x > 0)
      direction = RIGHT_FACING;
    else if(change_x < 0)
      direction = LEFT_FACING;    
  }
  @Override
  public void selectCurrentImages(){
  
    if(direction == RIGHT_FACING) {
      if(inPlace){
        currentImages = standRight;
      }
      else if(!isSpacebarActionable){
        currentImages = jumpRight;
    }  
      else {
        currentImages = moveRight;
    }  
  }
  else if(direction == LEFT_FACING){
      if(inPlace){
        currentImages = standLeft;
      }
      else if(!onPlatform)
        currentImages = jumpLeft;
     
      else
        currentImages = moveLeft;
    }  
  }
}
