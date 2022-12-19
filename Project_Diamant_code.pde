// Intengers for the player character
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

//// GLOBAL VARIABLES ////
// Arraylist of platforms that appear in the game.
ArrayList<Sprite> platforms = new ArrayList<Sprite>();
ArrayList<Sprite> diamonds = new ArrayList<Sprite>();

// Input queue for resolving conflicting inputs.
// Should be sorted by most recent (newer -> older)
ArrayList<Integer> inputQueue = new ArrayList<>();

// Sprites / Images
Sprite player;
PImage square_img, diamond_img;

// Counter for the amount of frames that have passed.
int frameNum = 0;
// Keep track of current level number
int levelNum = 0;
// Int to count the amount of diamonds the player has collected.
int numDiamonds = 0;
// Int to count the amount of diamonds in the game.
int maxDiamonds = 0;
// Display if the player can still play the game or not.  
boolean isGameOver = false;
// Float to point to the origin of the game (0,0) (Top left)
float view_x = 0;
float view_y = 0;

//// PROCESSING EVENTS ////
// Load the main components for the game and run it in fullscreen.
void setup(){
  fullScreen();
  imageMode(CENTER);

  // Spawn the player in game on the given x- and y-cordinates.
  player = new Sprite("YSquare.png", 1.0, DEFAULT_PLAYER_X, DEFAULT_PLAYER_Y);
  player.change_x = 0;
  player.change_y = 0;
  // Load the different platforms for the game.
  square_img = loadImage("Square.png");
  diamond_img = loadImage("Diamond.png");
  // Load the first level
  loadLevel(levelNum);
}
// Logic that should run every frame 
void draw(){
  frameNum++;
  resolveInput();

  // Draw a gray background to make the game appear like it is taking place in a cave.
  background(55,44,44);
  // Draw sprites to display when playing the game.
  player.display();
 
  // Display platforms
  resolvePlatformCollisions(player, platforms);
  
  // Run two voids to display and collect diamonds.
  display();
  drawText();
  collectDiamond();
}

// Add key to queue if pressed
void keyPressed(){
  // But not if it's already pressed
  for (int input : inputQueue) {
    if (input == keyCode) {
      return;
    }
  }
  inputQueue.add(0, keyCode);
}
// Remove key from queue if released
void keyReleased(){
  inputQueue.remove((Integer) keyCode);
}

//// UTILITY FUNCTIONS ////
// Code for handeling jumping and applying gravity to the player.
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
  
  String iQueue = "";
  for (int input : inputQueue) {
    iQueue = iQueue + input + ";";
  }
  text("inputQueue: " + iQueue, view_x + 50, view_y + 200);

  fill(0, 408, 612);

}

public void resolvePlatformCollisions(Sprite s, ArrayList<Sprite> walls){
  s.change_y += GRAVITY;
  // Check the top and bottom of the player
   s.center_y += s.change_y;
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  if (col_list.size() > 0) {
    Sprite collided = col_list.get(0);
    // Check if player is colliding with the top of a collision.
    if (s.change_y > 0) {
      s.setBottom(collided.getTop());
    }
    // Check if player is colliding with the bottom of a collision.
    else if (s.change_y < 0) {
      s.setTop(collided.getBottom());
  }
  s.change_y = 0;
} 
  // Check the left and right of the player.
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
// Run a simple check for collision to make platforms solid.
boolean checkCollision(Sprite s1, Sprite s2){
  return !(s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight() || s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom());
}
// Check the amount of sprites the player is colliding and add them to an ArrayList.
public ArrayList<Sprite> checkCollisionList(Sprite s, ArrayList<Sprite> list){
  ArrayList<Sprite> collision_list = new ArrayList<Sprite>();
  for(Sprite p: list){
    if(checkCollision(s, p))
      collision_list.add(p);
  }
  return collision_list;
}
// Display platforms.
void display(){
  for(Sprite s: platforms) {
    s.display();
  }
    //Display diamonds.
    for(Sprite diamond: diamonds) {
    diamond.display();
  }
}
// Script for collecting diamonds.
void collectDiamond(){
  ArrayList<Sprite> diamond_collision_list = checkCollisionList(player, diamonds);
  if(diamond_collision_list.size() > 0){
    for(Sprite diamond: diamond_collision_list){
      numDiamonds++;
      diamonds.remove(diamond);
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
        Sprite s = new Sprite(square_img, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }   
      //Create diamonds depending on the position of the letter 2.
      else if(values[col].equals("2")){
        Sprite s = new Sprite(diamond_img, SPRITE_SCALE);
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

// Perform actions based on currently pressed keys
void resolveInput() {
  boolean canMoveLR = true;

  for (int input : inputQueue) {
    // Right(D and ->)
    if (canMoveLR && (input == 68 || input == 39)) {
      player.change_x = MOVE_SPEED;
      canMoveLR = false;
    }
    // Left (A and <-)
    else if (canMoveLR && (input == 65 || input == 37)) {
      player.change_x = -MOVE_SPEED;
      canMoveLR = false;
    }
    // Jump (spacebar)
    else if(input == 32 && isOnPlatforms(player, platforms)){
      player.change_y = -JUMP_SPEED;
    }
    // TODO: Place a platform underneath the playet when pressing 
    else if(input == 32 && !isOnPlatforms(player, platforms)){
      
    }
  }
  // Stop left-right movement if no such key is pressed
  if (canMoveLR) {
    player.change_x = 0;
  }
}