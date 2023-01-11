//// PROCESSING EVENTS ////
// Logic that should run at start-up but cannot be run in `setup()`
public void settings() {
  // Disable DPI-scaling
  System.setProperty("prism.allowhidpi", "false");

  // Open in windowed mode if screen is larger than display, fullscreen if not.
  /*
  if (displayWidth > TARGET_DISPLAY_WIDTH || displayHeight > TARGET_DISPLAY_HEIGHT) {
    //size(1280, 720, P2D);
    size(TARGET_DISPLAY_WIDTH, TARGET_DISPLAY_HEIGHT, P2D);
  }
  else {
    fullScreen(P2D);
  }
  */

  fullScreen(FX2D);
}

// Logic that should run at start-up of the program
public void setup() {
  background(0); // Avoid flashbanging the user
  frameRate(TARGET_FRAMERATE);
  imageMode(CENTER);

  // Define center of screen
  screenCenter_x = pixelWidth / 2;
  screenCenter_y = pixelHeight / 2;

  // Initialise buffers with static size
  backgroundBuffer = createGraphics(pixelWidth, pixelHeight);

  //Define sound effects for use.
  fail = new SoundFile(this, "fail.wav");
  success = new SoundFile(this, "Success.wav");

  // Determine max amount of cells that the current screen resolution can display
  maxCells_x = pixelWidth / CELL_SIZE + 1;
  maxCells_y = pixelHeight / CELL_SIZE + 1;

  // Determine viewport shift bounds
  shiftZone_x = pixelWidth / 3;
  shiftZone_y = pixelHeight / 3;
  
  // Load the assest related to the playable character
  PImage[] player_stand_img = {loadImage("YSquare.png")};
  PImage[] player_move_img = {loadImage("YSquare_1.png"), loadImage("YSquare_2.png")};
  PImage[] player_jump_img = {loadImage("YSquare_Jump.png")};
  
  
  // Load the different assets used during the game.
  square_img = loadImage("Square.png");
  diamond_img = loadImage("Diamond.png");
  playerPlatform_img = loadImage("PlayerPlatform0.png");

  // Spawn the player in game
  player = new Player(player_stand_img, player_move_img, player_jump_img, 3.0);
  

  // Load the first level at the start of the program or next level after collecting the max amount of diamonds.
  loadLevel(levelNum);
}

// Logic that should run every frame 
public void draw() {
  // Stop if there's no map loaded
  if (noMap) {
    noLoop();
    background(backgroundColor);
    text(String.format("\"map_%02d.csv\" could not be loaded.", levelNum), LEFT_MARGIN, VERTICAL_MARGIN);
    return;
  }

  // Calculations before display
  resolveInput();
  collectDiamond();
  progressMovement();
  calculateOffset();
  
  // Display stuff
  imageMode(CORNER);
  image(backgroundBuffer, 0, 0);
  image(levelBuffer, -offset_x, -offset_y);
  imageMode(CENTER);
  drawSprites();
  drawDebugText();

  // Calculations after display
    fallenOfMap();
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

// Logic that runs every mouse press
public void mousePressed() {
  realMouseX = mouseX + offset_x;
  realMouseY = mouseY + offset_y;

  // Left mouse button
  if (mouseButton == 37) {
    placePlatform(realMouseX, realMouseY);
  }

  // Right mouse button
  if (mouseButton == 39){
    realMousePrevX = realMouseX;
    realMousePrevY = realMouseY;
    inputQueue.add(-mouseButton); // Negating; conflicts with keyCode
  }
}
public void mouseReleased() {
  if (mouseButton == 39) {
    inputQueue.remove((Integer) (-mouseButton));
  }
}

//// UTILITY FUNCTIONS ////
// Perform actions based on currently pressed keys
public void resolveInput() {
  boolean canMoveLR = true;

  for (int input : inputQueue) {
    // Right(D and ->)
    if (canMoveLR && (input == 68 || input == 39)) {
     if(player.right < (levelSizePx_x)){
       player.change_x = MOVE_SPEED;
      canMoveLR = false;
     }
    }
    // Left (A and <-)
    else if (canMoveLR && (input == 65 || input == 37)) {
      if(player.left > 0){
      player.change_x = -MOVE_SPEED;
      canMoveLR = false;
      }
    }
    // Spacebar (only count first press if not yet released)
    else if (isSpacebarActionable && input == 32) {
      // On ground; jump
      if (isLanded(player, collidables)) {
        isSpacebarActionable = false;
        player.change_y = -JUMP_SPEED;
      }
      // In air, attempt to place platform
      else if (placePlatform(player.center_x, player.center_y + 64 + 12)) {
        isSpacebarActionable = false;
      }
    }
    // Right mouse button (remove platform)
    else if (input == -39) {
      ArrayList<Sprite> removalList = new ArrayList<>();
      realMouseX = mouseX + offset_x;
      realMouseY = mouseY + offset_y;

      for (Sprite platform : playerPlatforms) {
        if (
            // Mouse is inside platform
            (realMouseX > platform.left && realMouseX < platform.right && realMouseY > platform.top && realMouseY < platform.bottom)
            // Mouse went over the platform
            || checkLineCollision(realMouseX, realMouseY, realMousePrevX, realMousePrevY, platform.right, platform.top, platform.right, platform.bottom)
            || checkLineCollision(realMouseX, realMouseY, realMousePrevX, realMousePrevY, platform.right, platform.top, platform.left, platform.top)
            || checkLineCollision(realMouseX, realMouseY, realMousePrevX, realMousePrevY, platform.left, platform.bottom, platform.left, platform.top)
            || checkLineCollision(realMouseX, realMouseY, realMousePrevX, realMousePrevY, platform.left, platform.bottom, platform.right, platform.bottom)
          ) {
            removalList.add(platform);
        }
      }
      for (Sprite platform : removalList) {
        removePlatform(platform);
      }
      realMousePrevX = realMouseX;
      realMousePrevY = realMouseY;
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
  Sprite platform = new Sprite(playerPlatform_img, SPRITE_SCALE, x, y);
  if (
    playerPlatforms.size() >= maxPlayerPlatformAmount
    || x < 0
    || x > levelSizePx_x
    || y < 0
    || y > levelSizePx_y
    || checkCollision(player, platform)
    || checkCollisionList(platform, collidables).size() > 0
  ) {
    fail.play();
    return false;
  }

  playerPlatforms.add(platform);
  collidables.add(platform);
  success.play();
  return true;
}
public void removePlatform(Sprite playerPlatform) {
  playerPlatforms.remove(playerPlatform);
  collidables.remove(playerPlatform);
}

// Checks if `sprite` is directly on top of any items in `platforms`
public boolean isLanded(Sprite sprite, ArrayList<Sprite>platforms) {
  sprite.changeCenter(0, 5);
  ArrayList<Sprite> col_list = checkCollisionList(sprite, platforms);
  sprite.changeCenter(0, -5);

  if(col_list.size() > 0) {
    return true;
  }
  return false;
}

public void drawDebugText() {
  textSize(24);
  fill(0, 408, 612);

  String iQueue = "";
  for (int input : inputQueue) {
    iQueue += input + ";";
  }

  String[] textToDisplay = {
    "Level: " + levelNum,
    "Diamonds: " + numDiamonds + "/" + maxDiamonds,
    "Platforms: " + playerPlatforms.size() + "/" + maxPlayerPlatformAmount,
    "isGameOver: " + isGameOver,
    "Collidables: " + collidables.size(),
    String.format("Player location: %.1f; %.1f", player.center_x, player.center_y),
    String.format("Screen Dimensions: %d x %d (%d x %d)", pixelWidth, pixelHeight, maxCells_x, maxCells_y),
    String.format("Level Dimensions: %d x %d (%d x %d)", levelSizePx_x, levelSizePx_y, levelSize_x, levelSize_y),
    "Viewport offset: " + offset_x + ", " + offset_y,
    String.format("Speed: %01.1f (%02dfps)", frameRate/TARGET_FRAMERATE, round(frameRate)),
    "frameCount: " + frameCount,
    "inputQueue: " + iQueue,
    "Animation debug:",
    "Direction: " + player.direction,
    "Change_X: " + player.change_x,
    "World collision debug: ",
    "fallenOfTheMap: " + falllenOfMap,
    "Ground Level: " + levelSizePx_x
  };

  for (int i = 0; i < textToDisplay.length; i++) {
    text(textToDisplay[i], LEFT_MARGIN, VERTICAL_MARGIN + 28*i);
  }
}

// Handles movement that should happen per frame, including collisions with the ground and walls
public void progressMovement() {
  player.change_y += GRAVITY;

  // Check the top and bottom of the player
  player.changeCenter(0, player.change_y);
  ArrayList<Sprite> col_list = checkCollisionList(player, collidables);
  if (col_list.size() > 0) {
    Sprite collided = col_list.get(0);

    // Check if player is colliding with the top of a collision.
    if (player.change_y > 0) {
      player.setBottom(collided.top);
    }

    // Check if player is colliding with the bottom of a collision.
    else if (player.change_y < 0) {
      player.setTop(collided.bottom);
    }
    player.change_y = 0;
  }

  // Check the left and right of the player.
  player.changeCenter(player.change_x, 0);
  col_list = checkCollisionList(player, collidables);
  if (col_list.size() > 0) {
    Sprite collided = col_list.get(0);

    //Check if player is colliding with the right of a collision.
    if (player.change_x > 0) {
      player.setRight(collided.left);
    }

    //Check if player is colliding with the left of a collision.
    else if (player.change_x < 0) {
      player.setLeft(collided.right);
    }
  }
}

// Run a simple check for collision to make platforms solid.
public boolean checkCollision(Sprite s1, Sprite s2) {
  return s1.right > s2.left && s1.left < s2.right && s1.bottom > s2.top && s1.top < s2.bottom;
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
public void fallenOfMap() {
//Run code to check if the player has fallen of the map and then restart the player
boolean falllenOffMap = player.bottom > (levelSizePx_y);
if(falllenOffMap){
  resetPlayer();
  }
}

// Display sprites
public void drawSprites() {
  for (Sprite diamond : diamonds) {
    diamond.display(-offset_x, -offset_y);
  }
  for (Sprite playerPlatform : playerPlatforms) {
    playerPlatform.display(-offset_x, -offset_y);
  }
  player.updateAnimation();
  player.display(-offset_x, -offset_y);
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
  int maxRowLen = 0;

  unloadLevel();

  // Load map file into memory
  String[] lines = loadStrings(String.format("map_%02d.csv", levelNum));

  // Prevent loading if the file couldn't be read
  if (lines == null) {
    noMap = true;
    return;
  }

  playerSpawnX = DEFAULT_PLAYER_X;
  playerSpawnY = DEFAULT_PLAYER_Y;

  // Create platforms on canvas for players
  for(int row = 0; row < lines.length; row++){
    String[] values = split(lines[row], ",");
    if (values.length > maxRowLen) {
      maxRowLen = values.length;
    }

    for(int col = 0; col < values.length; col++){
      //Create ground depending on the position of the number 1 in the .csv file.
      if(values[col].equals("1")){
        Sprite sprite = new Sprite(square_img, SPRITE_SCALE);
        sprite.setCenter(CELL_SIZE/2 + col * CELL_SIZE, CELL_SIZE/2 + row * CELL_SIZE);
        platforms.add(sprite);
        collidables.add(sprite);
      }

      //Create diamonds depending on the position of the number 2 in the .csv file.
      else if(values[col].equals("2")){
        Sprite sprite = new Sprite(diamond_img, SPRITE_SCALE);
        sprite.setCenter(CELL_SIZE/2 + col * CELL_SIZE, CELL_SIZE/2 + row * CELL_SIZE);
        diamonds.add(sprite);
        maxDiamonds++;
      }
      //Set player spawn point based on the position of the letter P in the .csv file.
      else if(values[col].equals("P")){
        playerSpawnX = CELL_SIZE/2 + col * CELL_SIZE;
        playerSpawnY = CELL_SIZE/2 + row * CELL_SIZE;
      }
    }
  }

  // Determine level size
  levelSize_x = maxRowLen;
  levelSize_y = lines.length;
  levelSizePx_x = levelSize_x * CELL_SIZE;
  levelSizePx_y = levelSize_y * CELL_SIZE;

  // Determine whether to enable level scrolling
  enableScrollingX = levelSize_x > maxCells_x;
  enableScrollingY = levelSize_y > maxCells_y;

  // Determine whether to enable boxing
  enablePillarBoxing = pixelWidth > levelSize_x; 
  enableLetterBoxing = pixelHeight > levelSize_y;

  // Center the viewport if level scrolling is not enabled
  if (!enableScrollingX) {
    offset_x = (levelSizePx_x - pixelWidth) / 2;
  }
  if (!enableScrollingY) {
    offset_y = (levelSizePx_y - pixelHeight) / 2;
  }

  player.setCenter(playerSpawnX, playerSpawnY);

  // Generate image buffers
  generateLevelBuffer();
  generateBackgroundBuffer();
}

public void unloadLevel() {
  // Clear level
  platforms.clear();
  diamonds.clear();
  playerPlatforms.clear();
  collidables.clear();
  numDiamonds = 0;
  maxDiamonds = 0;
  resetPlayer();
}

// Generate buffer image for the static parts of the level
public void generateLevelBuffer() {
  levelBuffer = createGraphics(levelSizePx_x, levelSizePx_y);
  levelBuffer.beginDraw();
  levelBuffer.imageMode(CENTER);
  for (Sprite sprite : platforms) {
    levelBuffer.image(sprite.image, sprite.center_x, sprite.center_y, sprite.w, sprite.h);
  }
  levelBuffer.endDraw();
}

// Generate buffer image for the background
public void generateBackgroundBuffer() {
  backgroundBuffer.beginDraw();
  backgroundBuffer.noStroke();
  backgroundBuffer.fill(backgroundColor);
  backgroundBuffer.background(0);
  backgroundBuffer.rect((pixelWidth - levelSizePx_x) / 2, (pixelHeight - levelSizePx_y) / 2, levelSizePx_x, levelSizePx_y);
  backgroundBuffer.endDraw();
}

// Reset the player position when the level is loaded(Also used when a player falls off the map)
public void resetPlayer() {
  player.setCenter(playerSpawnX, playerSpawnY);
  player.change_x = 0;
  player.change_y = 0;
}

// Logic for when the player completes a level
public void levelComplete() {
  levelNum++;
  loadLevel(levelNum);
}

// Calculate viewport offset for level scrolling
public void calculateOffset() {
  // Scroll horizontally
  if (enableScrollingX) {
    // Scroll left
    if (player.center_x - offset_x < shiftZone_x) {
      offset_x = player.center_x - shiftZone_x;
      if (offset_x < 0) {
        offset_x = 0;
      }
    }
    
    // Scroll right
    else if (player.center_x - offset_x > pixelWidth - shiftZone_x) {
      offset_x = player.center_x + shiftZone_x - pixelWidth;
      if (offset_x + pixelWidth > levelSizePx_x) {
        offset_x = levelSizePx_x - pixelWidth;
      }
    }
  }

  // Scroll vertically
  if (enableScrollingY) {
    // Scroll up
    if (player.center_y - offset_y < shiftZone_y) {
      offset_y = player.center_y - shiftZone_y;
      if (offset_y < 0) {
        offset_y = 0;
      }
    }
    
    // Scroll down
    else if (player.center_y - offset_y > pixelHeight - shiftZone_y) {
      offset_y = player.center_y + shiftZone_y - pixelHeight;
      if (offset_y + pixelHeight > levelSizePx_y) {
        offset_y = levelSizePx_y - pixelHeight;
      }
    }
  }
}

// Scale an image without blurring it
PImage scaleImageNoBlur(PImage img, int w, int h){
  PGraphics buffer = createGraphics(w, h);
  buffer.noSmooth();
  buffer.beginDraw();
  buffer.image(img, 0, 0, w, h);
  buffer.endDraw();

  return buffer.get();
}

// Check for collision between line segments
boolean checkLineCollision(float x1a, float y1a, float x1b, float y1b, float x2a, float y2a, float x2b, float y2b) {
  float denominator = ((x1b - x1a) * (y2b - y2a)) - ((y1b - y1a) * (x2b - x2a));
  float numerator1 = ((y1a - y2a) * (x2b - x2a)) - ((x1a - x2a) * (y2b - y2a));
  float numerator2 = ((y1a - y2a) * (x1b - x1a)) - ((x1a - x2a) * (y1b - y1a));

  // Prevent 0-division if lines are parralel
  if (denominator == 0) {
    return numerator1 == 0 && numerator2 == 0;
  }

  float r = numerator1 / denominator;
  float s = numerator2 / denominator;
  return ((r >= 0 && r <= 1) && (s >= 0 && s <= 1));
}
