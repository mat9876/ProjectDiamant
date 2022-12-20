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

final static int GAME_DISPLAY_WIDTH = 1920;
final static int GAME_DISPLAY_HEIGHT = 1080;

//// GLOBAL VARIABLES ////
// Arraylist of platforms that appear in the game.
ArrayList<Sprite> platforms = new ArrayList<>();
ArrayList<Sprite> diamonds = new ArrayList<>();
ArrayList<Sprite> playerPlatforms = new ArrayList<>();

// ArrayList of things the player can collide with
ArrayList<Sprite> collidables = new ArrayList<>();

// Input queue for resolving conflicting inputs.
// Should be sorted by most recent (newer -> older)
ArrayList<Integer> inputQueue = new ArrayList<>();

// Sprites / Images
Sprite player;
PImage square_img, diamond_img, playerPlatform_img;

// Keep track of current level number
int levelNum = 0;
// Maximum amount of platforms the player can create
int maxPlayerPlatformAmount = 3;
// Int to count the amount of diamonds the player has collected.
int numDiamonds = 0;
// Int to count the amount of diamonds in the game.
int maxDiamonds = 0;
// Tracks whether the current spacebar press has done something
boolean isSpacebarActionable = true;
// Display if the player can still play the game or not.  
boolean isGameOver = false;
// Float to point to the origin of the game (0,0) (Top left)
float view_x = 0;
float view_y = 0;
// Background Color
color backgroundColor = color(55,44,44);

//// PROCESSING EVENTS ////
// Logic that should run before start-up
public void settings() {
  // Open in windowed mode if screen is larger than display, fullscreen if not.
  if (displayWidth > GAME_DISPLAY_WIDTH || displayHeight > GAME_DISPLAY_HEIGHT) {
    size(GAME_DISPLAY_WIDTH, GAME_DISPLAY_HEIGHT);
  }
  else {
    fullScreen();
  }
}

// Logic that should run at start-up
public void setup() {
  frameRate(60);
  imageMode(CENTER);

  // Spawn the player in game on the given x- and y-cordinates.
  player = new Sprite("YSquare.png", 1.0, DEFAULT_PLAYER_X, DEFAULT_PLAYER_Y);
  player.change_x = 0;
  player.change_y = 0;

  // Load the different assets for the game.
  square_img = loadImage("Square.png");
  diamond_img = loadImage("Diamond.png");
  playerPlatform_img = loadImage("PlayerPlatform0.png");

  // Load the first level
  loadLevel(levelNum);
}

// Logic that should run every frame 
public void draw() {
  // Calculations before display
  resolveInput();
  collectDiamond();
  progressMovement();
  
  // Display stuff
  background(backgroundColor);
  player.display();
  display();
  drawText();

  // Calculations after display

}

// Logic that runs every keypress (including repeats)
public void keyPressed() {
  // Add key to queue if pressed, but not if it's already pressed
  for (int input : inputQueue) {
    if (input == keyCode) {
      return;
    }
  }

  inputQueue.add(0, keyCode);
}
// Logic that runs every key release
public void keyReleased() {
  if (keyCode == 32) {
    isSpacebarActionable = true;
  }

  inputQueue.remove((Integer) keyCode);
}

//// UTILITY FUNCTIONS ////
// Perform actions based on currently pressed keys
public void resolveInput() {
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
    // Spacebar (only count first press if not yet released)
    else if (isSpacebarActionable && input == 32) {
      boolean isLanded = isLanded(player, collidables);

      // On ground; jump
      if (isLanded) {
        isSpacebarActionable = false;
        player.change_y = -JUMP_SPEED;
      }
      // In air, attempt to place platform
      else if (placePlatform(player.center_x, player.center_y + 64 + 12)) {
        isSpacebarActionable = false;
        // TODO: play sound on success
      }
      else {
        // TODO: play sound on failure
      }
    }
  }
  // Stop left-right movement if no such key is pressed
  if (canMoveLR) {
    player.change_x = 0;
  }
}

// Attempts to place a platform at the given location
// Returns true if successful, false if not.
public boolean placePlatform(float x, float y) {
  if (playerPlatforms.size() >= maxPlayerPlatformAmount) {
    return false;
  }

  Sprite platform = new Sprite(playerPlatform_img, SPRITE_SCALE, x, y);
  if (checkCollisionList(platform, collidables).size() > 0) {
    return false;
  }

  playerPlatforms.add(platform);
  collidables.add(platform);
  return true;
}
public void removePlatform(Sprite playerPlatform) {
  playerPlatforms.remove(playerPlatform);
  collidables.remove(playerPlatform);
}

// Checks if `sprite` is directly on top of any items in `platforms`
public boolean isLanded(Sprite sprite, ArrayList<Sprite>platforms) {
  sprite.center_y += 5;
  ArrayList<Sprite> col_list = checkCollisionList(sprite, platforms);
  sprite.center_y -= 5;

  if(col_list.size() > 0) {
    return true;
  }
  return false;
}

public void drawText() {
  textSize(24);

  String iQueue = "";
  for (int input : inputQueue) {
    iQueue += input + ";";
  }

  String[] textToDisplay = {
    "Level: " + levelNum,
    "Diamonds: " + numDiamonds + "/" + maxDiamonds,
    "Platforms: " + playerPlatforms.size() + "/" + maxPlayerPlatformAmount,
    "isGameOver: " + isGameOver,
    "FPS: " + (int) round(frameRate),
    "frameCount: " + frameCount,
    "inputQueue: " + iQueue,
  };

  for (int i = 0; i < textToDisplay.length; i++) {
    text(textToDisplay[i], view_x + LEFT_MARGIN, view_y + VERTICAL_MARGIN + 28*i);
  }

  fill(0, 408, 612);
}

// Handles movement that should happen per frame, including collisions
public void progressMovement() {
  player.change_y += GRAVITY;

  // Check the top and bottom of the player
  player.center_y += player.change_y;
  ArrayList<Sprite> col_list = checkCollisionList(player, collidables);
  if (col_list.size() > 0) {
    Sprite collided = col_list.get(0);

    // Check if player is colliding with the top of a collision.
    if (player.change_y > 0) {
      player.setBottom(collided.getTop());
    }

    // Check if player is colliding with the bottom of a collision.
    else if (player.change_y < 0) {
      player.setTop(collided.getBottom());
    }
    player.change_y = 0;
  }

  // Check the left and right of the player.
  player.center_x += player.change_x;
  col_list = checkCollisionList(player, collidables);
  if (col_list.size() > 0) {
    Sprite collided = col_list.get(0);

    //Check if player is colliding with the right of a collision.
    if (player.change_x > 0) {
      player.setRight(collided.getLeft());
    }

    //Check if player is colliding with the left of a collision.
    else if (player.change_x < 0) {
      player.setLeft(collided.getRight());
    }
  }
}

// Run a simple check for collision to make platforms solid.
public boolean checkCollision(Sprite s1, Sprite s2) {
  return !(s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight() || s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom());
}

// Check the amount of sprites the player is colliding and add them to an ArrayList.
public ArrayList<Sprite> checkCollisionList(Sprite sprite_1, ArrayList<Sprite> list){
  ArrayList<Sprite> collision_list = new ArrayList<Sprite>();
  for(Sprite sprite_2: list){
    if(checkCollision(sprite_1, sprite_2)) {
      collision_list.add(sprite_2);
    }
  }
  return collision_list;
}

// Display sprites
public void display() {
  for (Sprite sprite : platforms) {
    sprite.display();
  }
  for (Sprite diamond : diamonds) {
    diamond.display();
  }
  for (Sprite playerPlatform : playerPlatforms) {
    playerPlatform.display();
  }
}

// Script for collecting diamonds.
public void collectDiamond() {
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
public void loadLevel(int levelNum) {
  // Clear level
  platforms.clear();
  diamonds.clear();
  playerPlatforms.clear();
  collidables.clear();
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
        Sprite sprite = new Sprite(square_img, SPRITE_SCALE);
        sprite.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        sprite.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(sprite);
        collidables.add(sprite);
      }

      //Create diamonds depending on the position of the letter 2.
      else if(values[col].equals("2")){
        Sprite sprite = new Sprite(diamond_img, SPRITE_SCALE);
        sprite.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        sprite.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        diamonds.add(sprite);
        maxDiamonds++;
      }
    }
  }
}

// Logic for when the player completes a level
public void levelComplete() {
  levelNum++;
  loadLevel(levelNum);
}
