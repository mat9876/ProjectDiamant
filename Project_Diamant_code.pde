//Intengers for the player character
final static float MOVE_SPEED = 6;
final static float SPRITE_SCALE = 50.0/128;
final static float SPRITE_SIZE = 50;
final static float GRAVITY = 0.6;
final static float JUMP_SPEED = 10;
final static int DEFAULT_PLAYER_X = 200;
final static int DEFAULT_PLAYER_Y = 900;

final static float RIGHT_MARGIN = 400;
final static float LEFT_MARGIN = 60;
final static float VERTICAL_MARGIN = 40;

//Arraylist of platforms that appear in the game.
Sprite player;
PImage Square, Diamond;
ArrayList<Sprite> platforms = new ArrayList<Sprite>();
ArrayList<Sprite> diamonds = new ArrayList<Sprite>();

// Integer dictionary for resolving conflicting inputs
IntDict inputQueue = new IntDict();

//Global variables that can be used in the entire program.
  // Counter for the amount of frames that have passed.
  int frameNum = 0;
  // Keep track of current level number
  int levelNum = 0;
  //Int to count the amount of diamonds the player has collected.
  int numDiamonds = 0;
  //Int to count the amount of diamonds in the game.
  int maxDiamonds = 0;
  //Display if the player can still play the game or not.  
  boolean isGameOver = false;
  //Float to point to the origin of the game (0,0) (Top left)
  float view_x = 0;
  float view_y = 0;
  
//Load the main components for the game and run it in fullscreen.
void setup(){
  fullScreen();
  imageMode(CENTER);

  //Spawn the player in game on the given x- and y-cordinates.
  player = new Sprite("YSquare.png", 1.0, DEFAULT_PLAYER_X, DEFAULT_PLAYER_Y);
  player.change_x = 0;
  player.change_y = 0;
  //Load the different platforms for the game.
  Square = loadImage("Square.png");
  Diamond = loadImage("Diamond.png");
  //Load the first level
  loadLevel(levelNum);
}
//Draw backgrond for platforms to appear on during gameplay. 
void draw(){
  frameNum++;

  //Draw a gray background to make the game appear like it is taking place in a cave.
  background(55,44,44);
  //Draw sprites to display when playing the game.
  player.display();
 
  //Display platforms
  resolvePlatformCollisions(player, platforms);
  
  //Run two voids to display and collect diamonds.
  display();
  drawText();
  collectDiamond();
} 

//Code for handeling jumping and applying gravity to the player.
public boolean isOnPlatforms(Sprite s, ArrayList<Sprite>platforms){
  s.center_y += 5;
  ArrayList<Sprite> col_list = checkCollisionList(s, platforms);
  s.center_y -= 5;
  if(col_list.size() > 0){
    return true;
  }
  else {
    return false;
  }
}
public void drawText(){
  textSize(24);
  text("diamonds: " + numDiamonds + "/" + maxDiamonds, view_x + 50, view_y + 50);
  text("isGameOver: " + isGameOver, view_x + 50, view_y + 100); 
  text("frameNum: " + frameNum, view_x + 50, view_y + 150);
  fill(0, 408, 612);

}

public void resolvePlatformCollisions(Sprite s, ArrayList<Sprite> walls){
  s.change_y += GRAVITY;
  //Check the top and bottom of the player
   s.center_y += s.change_y;
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  if (col_list.size() > 0) {
    Sprite collided = col_list.get(0);
    //Check if player is colliding with the top of a collision.
    if (s.change_y > 0) {
      s.setBottom(collided.getTop());
    }
    //Check if player is colliding with the bottom of a collision.
    else if (s.change_y < 0) {
      s.setTop(collided.getBottom());
  }
  s.change_y = 0;
} 
  //Check the left and right of the player.
   s.center_x += s.change_x;
  col_list = checkCollisionList(s, walls);
  if (col_list.size() > 0) {
    Sprite collided = col_list.get(0);
    //Check if player is colliding with the right of a collision.
    if (s.change_x > 0) {
      s.setRight(collided.getLeft());
    }
    //Check if player is colliding with the left of a collision.
    else if (s.change_x < 0) {
      s.setLeft(collided.getRight());
  }
 
 } 
}
//Run a simple check for collision to make platforms solid.
boolean checkCollision(Sprite s1, Sprite s2){
  boolean noXOverlap = s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight();
  boolean noYOverlap = s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom();
  if(noXOverlap || noYOverlap){
    return false;
  }
  else{
    return true;
  }
}
//Check the amount of sprites the player is colliding and add them to an ArrayList.
public ArrayList<Sprite> checkCollisionList(Sprite s, ArrayList<Sprite> list){
  ArrayList<Sprite> collision_list = new ArrayList<Sprite>();
  for(Sprite p: list){
    if(checkCollision(s, p))
      collision_list.add(p);
  }
  return collision_list;
}
//Display platforms.
void display(){
  for(Sprite s: platforms) {
    s.display();
  }
    //Display diamonds.
    for(Sprite Diamond: diamonds) {
    Diamond.display();
  }
}
//Script for collecting diamonds.
void collectDiamond(){
  ArrayList<Sprite> Dia_list = checkCollisionList(player, diamonds);
  if(Dia_list.size() > 0){
    for(Sprite Diamond: Dia_list){
      numDiamonds++;
      diamonds.remove(Diamond);
    }
  }
  if(numDiamonds == maxDiamonds){
    levelComplete();
  }
}
// Load a level
void loadLevel(int levelNum) {
  // Clear level
  platforms.clear();
  diamonds.clear();
  numDiamonds = 0;
  maxDiamonds = 0;

  // Reset player
  player.center_x = DEFAULT_PLAYER_X;
  player.center_y = DEFAULT_PLAYER_Y;
  player.change_x = 0;
  player.change_y = 0;

  // Create platforms on canvas for players
  String[] lines = loadStrings(String.format("map_%02d.csv", levelNum));
  for(int row = 0; row < lines.length; row++){
    String[] values = split(lines[row], ",");
    for(int col = 0; col < values.length; col++){
      //Create ground depending on the position of the letter 1.
      if(values[col].equals("1")){
        Sprite s = new Sprite(Square, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }   
      //Create diamonds depending on the position of the letter 2.
      else if(values[col].equals("2")){
        Sprite s = new Sprite(Diamond, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        diamonds.add(s);
        maxDiamonds++;
      }
    }
  }
}

// Logic for when the player completes a level
void levelComplete(){
  levelNum++;
  loadLevel(levelNum);
}

// TODO: perform actions based on currently pressed keys
void resolveInput() {

}

//Move the player when a certain key is pressed.
void keyPressed(){
  //Right(D and ->)
 if(keyCode == 68 || keyCode == 39){
    player.change_x = MOVE_SPEED;
    inputQueue.set("moveRight", frameNum);
  }
  //Left (A and <-)
  else if(keyCode == 65 || keyCode == 37){
    player.change_x = -MOVE_SPEED;
    inputQueue.set("moveLeft", frameNum);
  }
  //Jump (spacebar)
  else if(keyCode == 32 && isOnPlatforms(player, platforms)){
    player.change_y = -JUMP_SPEED;
  }
  //Place a platform underneath the playet when pressing 
  else if(keyCode == 32 && !isOnPlatforms(player, platforms)){
    
  }
}
//Stop moving the player when the user let's go off the key.
void keyReleased(){
  //Right(D and ->)
  if(player.change_x > 0 && (keyCode == 68 || keyCode == 39)){
    player.change_x = 0;
  }
  //Left (A and <-)
  else if(player.change_x < 0 && (keyCode == 65 || keyCode == 37)){
    player.change_x = 0;
  } 
}
