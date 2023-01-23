//// PROCESSING EVENTS ////
// Logic that should run at start-up but cannot be run in `setup()`
public void settings() {
  // Disable DPI-scaling
  System.setProperty("prism.allowhidpi", "false");

  // Open in windowed mode if screen is larger than display, fullscreen if not.
  fullScreen(FX2D);
}

// Logic that should run at start-up of the program
public void setup() {
  background(0); // Avoid flashbanging the user
  frameRate(TARGET_FRAMERATE);
  imageMode(CENTER);
  // Load the assist while playing a game.
  loadAssest();

  // Define a player and the assists that need to be loaded.
  definePlayer();

  initialiseMenus();

  // Load the first level at the start of the program or next level after collecting the max amount of diamonds.
  loadLevel(levelNum);
}

// Logic that should run every frame 
public void draw() {
  // Stop if there's no map loaded
  if (noMap) {
    noMap();
    return;
  }

  // Run & display pause menu
  if (isPaused) {
    doMenuTick();
    displayLevel();
    displayMenu();
    return;
  }

  // Run & display game
  doGameTick();
  displayLevel();
  loadMouse();
}

// Logic that runs every keypress (including repeats)
public void keyPressed() {
  // Prevent closing on ESC-press
  key = 0;

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
  offsetMouseX = mouseX + (int) offset_x;
  offsetMouseY = mouseY + (int) offset_y;

  // Right mouse button
  if (mouseButton == 39){
    offsetMousePrevX = offsetMouseX;
    offsetMousePrevY = offsetMouseY;
  }

  inputQueue.add(-mouseButton); // Negating; conflicts with keyCode
}
public void mouseReleased() {
  inputQueue.remove((Integer) (-mouseButton));
}

//// UTILITY FUNCTIONS ////
// Advance game logic by 1 "tick"
public void doGameTick() {
  resolveGameInput();
  collectDiamond();
  touchedSpikes();
  progressMovement();
  calculateOffset();

  if (checkOutOfBounds(player)) {
    resetLevel();
  }
}

// Resolve menu logic
public void doMenuTick() {
  resolveMenuInput();
}

// Display the level in its current state
public void displayLevel() {
  imageMode(CORNER);
  // image(backgroundBuffer, 0, 0);
  image(backgroundImage, 0, 0, pixelWidth, pixelHeight);
  image(levelBuffer, -offset_x, -offset_y);
  imageMode(CENTER);
  drawSprites();
  imageMode(CORNER);
  image(letterPillarBoxesBuffer, 0, 0);
  imageMode(CENTER);
  // drawLevelStatText();
  drawDebugText();
}

// Display active menus
public void displayMenu() {
  image(activeMenu.getBuffer(), screenCenter_x, screenCenter_y);
}

// Perform actions based on currently pressed keys
public void resolveGameInput() {
  boolean canMoveLR = true;
  ArrayList<Integer> removalList = new ArrayList<>();

  for (int input : inputQueue) {
    switch (input) {
      // Right(D and ->)
      case 39:
      case 68:
        if (canMoveLR) {
          player.change_x = MOVE_SPEED;
          canMoveLR = false;
        }
        break;
      // Left (A and <-)
      case 65:
      case 37:
        if (canMoveLR) {
          player.change_x = -MOVE_SPEED;
          canMoveLR = false;
        }
        break;
      // Spacebar
      case 32:
        // Only count first press if not yet released
        if (isSpacebarActionable) {
          // On ground; jump
          if (isLanded(player, collidables)) {
            isSpacebarActionable = false;
            player.change_y = -JUMP_SPEED;
          }
          // In air, attempt to place platform
          else if (placePlatform(player.center_x, player.bottom + 16)) {
            isSpacebarActionable = false;
          }
        }
        break;
      // ESC
      case 27:
        isPaused = true;
        removalList.add(input);
        break;

      // Left mouse button
      case -37:
        placePlatform(offsetMouseX, offsetMouseY);
        removalList.add(input);
        break;
      // Right mouse button (remove platform)
      case -39:
        removePlatformWithMouse();
        break;
    }
  }
  // Stop left-right movement if no such key is pressed
  if (canMoveLR) {
    player.change_x = 0;
  }

  for (Integer k : removalList) {
    inputQueue.remove(k);
  }
}

// Perform menu actions based on pressed keys
public void resolveMenuInput() {
  ArrayList<Integer> removalList = new ArrayList<>();
  
  for (int input : inputQueue) {
    removalList.add(input);

    switch (input) {
      // ESC / Right mouse button (return)
      case 27:
      case -39:
        if (!activeMenu.up()) {
          isPaused = false;
        }
        break;
      // Left mouse button (interact)
      case -37:
        activeMenu.processClick(mouseX, mouseY);
        break;
      // - (temporary exit)
      case 45:
        exit();
        break;
    }
  }

  for (Integer k : removalList) {
    inputQueue.remove(k);
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
public void removePlatformWithMouse() {
  ArrayList<Sprite> removalList = new ArrayList<>();
  offsetMouseX = mouseX + (int) offset_x;
  offsetMouseY = mouseY + (int) offset_y;

  for (Sprite platform : playerPlatforms) {
    if (
        // Mouse is inside platform
        (offsetMouseX > platform.left && offsetMouseX < platform.right && offsetMouseY > platform.top && offsetMouseY < platform.bottom)
        // Mouse went over the platform
        || checkLineCollision(offsetMouseX, offsetMouseY, offsetMousePrevX, offsetMousePrevY, platform.right, platform.top, platform.right, platform.bottom)
        || checkLineCollision(offsetMouseX, offsetMouseY, offsetMousePrevX, offsetMousePrevY, platform.right, platform.top, platform.left, platform.top)
        || checkLineCollision(offsetMouseX, offsetMouseY, offsetMousePrevX, offsetMousePrevY, platform.left, platform.bottom, platform.left, platform.top)
        || checkLineCollision(offsetMouseX, offsetMouseY, offsetMousePrevX, offsetMousePrevY, platform.left, platform.bottom, platform.right, platform.bottom)
      ) {
        removalList.add(platform);
    }
  }
  for (Sprite platform : removalList) {
    removePlatform(platform);
  }
  offsetMousePrevX = offsetMouseX;
  offsetMousePrevY = offsetMouseY;
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

// Text shown to player during level play
public void drawLevelStatText() {
  textSize(24);
  textAlign(LEFT, TOP);
  fill(0, 408, 612);
  

  String iQueue = "";
  for (int input : inputQueue) {
    iQueue += input + ";";
  }

  String[] textToDisplay = {
    "Level: " + levelNum,
    "Diamonds: " + collected_diamonds.size() + "/" + maxDiamonds,
    "Platforms: " + playerPlatforms.size() + "/" + maxPlayerPlatformAmount,
    "Score: " + scoreForCurrentPlayer
  };

  for (int i = 0; i < textToDisplay.length; i++) {
    text(textToDisplay[i], LEFT_MARGIN, VERTICAL_MARGIN + 28*i);
  }
}

// Text shown to player during level play, for debugging
public void drawDebugText() {
  textSize(24);
  fill(0, 408, 612);

  String iQueue = "";
  for (int input : inputQueue) {
    iQueue += input + ";";
  }

  String[] textToDisplay = {
    "Level: " + levelNum,
    "Diamonds: " + collected_diamonds.size() + "/" + maxDiamonds,
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

  // Check out-of-bounds
  if (player.left < 0) {
    player.setLeft(0);
  }
  else if (player.right > levelSizePx_x) {
    player.setRight(levelSizePx_x);
  }
  if (player.top < 0) {
    player.setTop(0);
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

// Check if the given coordinates are out of bounds
public boolean checkOutOfBounds(float x, float y) {
  return x < 0 || x > levelSizePx_x || y < 0 || y > levelSizePx_y;
}
// OOB check for sprites
public boolean checkOutOfBounds(Sprite sprite) {
  return sprite.left < 0 || sprite.right > levelSizePx_x || sprite.top < 0 || sprite.bottom > levelSizePx_y;
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
      diamonds.remove(diamond);
      collected_diamonds.add(diamond);
      scoreForCurrentPlayer = (scoreForCurrentPlayer + 50);
    }
  }
  if(collected_diamonds.size() == maxDiamonds){
    levelComplete();
  }
}

public void touchedSpikes() {
  ArrayList<Sprite> spikes_collision_list = checkCollisionList(player, spikes);
  if(spikes_collision_list.size() > 0){
      resetPlayer();
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
      
      else if(values[col].equals("S")){
        Sprite sprite = new Sprite(spikes_img, SPRITE_SCALE);
        sprite.setCenter(CELL_SIZE/2 + col * CELL_SIZE, CELL_SIZE/2 + row * CELL_SIZE);
        platforms.add(sprite);
        spikes.add(sprite);
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
  enablePillarBoxing = pixelWidth > levelSizePx_x; 
  enableLetterBoxing = pixelHeight > levelSizePx_y;

  // Center the viewport if level scrolling is not enabled
  if (!enableScrollingX) {
    offset_x = (levelSizePx_x - pixelWidth) / 2;
  }
  if (!enableScrollingY) {
    offset_y = (levelSizePx_y - pixelHeight) / 2;
  }

  player.setCenter(playerSpawnX, playerSpawnY);
  activeMenu = pauseMenu;

  // Generate image buffers
  generateLevelBuffer();
  // generateBackgroundBuffer();
  generateLetterPillarBoxes();
}

// Completely unload (and reset) any and all data of the level
public void unloadLevel() {
  platforms.clear();
  diamonds.clear();
  collidables.clear();
  collected_diamonds.clear();
  maxDiamonds = 0;
  scoreForCurrentPlayer = (scoreForCurrentPlayer + 100);
  resetPlayer();
}

// Reset level to base
public void resetLevel() {
  resetPlayer();
  
  for (Sprite diamond : collected_diamonds) {
    diamonds.add(diamond);
  }
  collected_diamonds.clear();

  for (Sprite platform : playerPlatforms) {
    collidables.remove(platform);
  }
  playerPlatforms.clear();
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

// Generate buffer image for letter- and pillarboxes
public void generateLetterPillarBoxes() {
  letterPillarBoxesBuffer.beginDraw();
    letterPillarBoxesBuffer.noStroke();
    letterPillarBoxesBuffer.fill(0);

    if (enablePillarBoxing) {
      // left
      letterPillarBoxesBuffer.rect(0, 0, (pixelWidth - levelSizePx_x) / 2, pixelHeight);
      // right
      letterPillarBoxesBuffer.rect(pixelWidth - (pixelWidth - levelSizePx_x) / 2, 0, pixelWidth, pixelHeight);
    }
    if (enableLetterBoxing) {
      // top
      letterPillarBoxesBuffer.rect(0, 0, pixelWidth, (pixelHeight - levelSizePx_y) / 2);
      // bottom
      letterPillarBoxesBuffer.rect(0, pixelHeight - (pixelHeight - levelSizePx_y) / 2, pixelWidth, pixelHeight);
    }
  letterPillarBoxesBuffer.endDraw();
}

// Reset the player position when the level is loaded(Also used when a player falls off the map)
public void resetPlayer() {
  //  Unload the collision and sprite of the playerplatform from the game when the user resets the game.
  ArrayList<Sprite> removalList = new ArrayList<>();
  for (Sprite platform : removalList) {
    removePlatform(platform);
  }
  fail.play();
  scoreForCurrentPlayer = (scoreForCurrentPlayer - 100);
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

public void definePlayer(){
   // Load the assest related to the playable character
  PImage[] player_stand_img = {loadImage("YSquare.png")};
  PImage[] player_move_img = {loadImage("YSquare_1.png"), loadImage("YSquare_2.png")};
  PImage[] player_jump_img = {loadImage("YSquare_Jump.png")};

  // Spawn the player in game
  player = new Player(player_stand_img, player_move_img, player_jump_img, 3.0); 
}

public void loadAssest() {
  // Define center of screen
  screenCenter_x = pixelWidth / 2;
  screenCenter_y = pixelHeight / 2;

  // Initialise buffers with static size
  backgroundBuffer = createGraphics(pixelWidth, pixelHeight);
  letterPillarBoxesBuffer = createGraphics(pixelWidth, pixelHeight);

  backgroundImage = loadImage("Background_00.png");

  // Load the different assets used during the game.
  square_img = loadImage("Square.png");
  diamond_img = loadImage("Diamond.png");
  spikes_img = loadImage("Spikes.png");
  mouseCursor = loadImage("Cursor.png");
  playerPlatform_img = loadImage("PlayerPlatform0.png");

  //Define sound effects for use.
  fail = new SoundFile(this, "fail.wav");
  success = new SoundFile(this, "Success.wav");

  // Determine max amount of cells that the current screen resolution can display
  maxCells_x = pixelWidth / CELL_SIZE + 1;
  maxCells_y = pixelHeight / CELL_SIZE + 1;

  // Determine viewport shift bounds
  shiftZone_x = pixelWidth / 3;
  shiftZone_y = pixelHeight / 3;
  
  cursor(mouseCursor);
}

// Initialise menus
public void initialiseMenus() {
  startMenu = new Menu();
  pauseMenu = new Menu(
    new BackButtonItem("Resume"),
    new ResetButtonItem("Reset"),
    new ExitButtonItem("Exit")
  );
  completeMenu = new Menu();
  endMenu = new Menu();

  activeMenu = startMenu;
}

public void noMap() {
  noLoop();
  background(backgroundColor);
  text(String.format("\"map_%02d.csv\" could not be loaded.", levelNum), LEFT_MARGIN, VERTICAL_MARGIN);
}
public void loadMouse() {
 //Keep reloading the mouse cursor every 3000 frameCount because Processing keeps unloading the main cursor due to a bug.
  if ((frameCount % 3000) == 0) {
  cursor(mouseCursor);
  }  
 }
