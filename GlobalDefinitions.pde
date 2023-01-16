// Import logic for sound effects
import processing.sound.*;
import processing.javafx.*;

//// GLOBAL DEFINITIONS ////
// Integers for displaying the amount of pixels the screen should take up.
final static int TARGET_DISPLAY_WIDTH = 1920;
final static int TARGET_DISPLAY_HEIGHT = 1080;
// Integers for displaying the amount of frames per second during testing fase(Delete in the final version).
final static int TARGET_FRAMERATE = 60;

// Alignment / Scaling
final static float RIGHT_MARGIN = 400;
final static float LEFT_MARGIN = 60;
final static float VERTICAL_MARGIN = 40;
final static float SPRITE_SCALE = 50.0/128;
final static int CELL_SIZE = 50;
final static float BASE_OFFSET_X = 15;
final static float BASE_OFFSET_Y = 10;

// Integers for calculating the positions of the player character to use during animation
final static int NEUTRAL_FACING = 0;
final static int RIGHT_FACING = 1;
final static int LEFT_FACING = 2;

// Intengers for the player character
final static float MOVE_SPEED = 6;
final static float GRAVITY = 0.8;
final static float JUMP_SPEED = 12;
final static float DEFAULT_PLAYER_X = 200;
final static float DEFAULT_PLAYER_Y = 900;

//// GLOBAL VARIABLES ////
// Indicator on whether or not a map is loaded
boolean noMap = false;
// Arraylist of platforms that appear in the game.
ArrayList<Sprite> platforms = new ArrayList<>();
ArrayList<Sprite> diamonds = new ArrayList<>();
ArrayList<Sprite> collected_diamonds = new ArrayList<>();
ArrayList<Sprite> playerPlatforms = new ArrayList<>();

// ArrayList of things the player can collide with
ArrayList<Sprite> collidables = new ArrayList<>();

// Input queue for resolving conflicting inputs.
// Should be sorted by most recent (newer -> older)
ArrayList<Integer> inputQueue = new ArrayList<>();

// Sprites / Images
Player player;
PImage square_img, diamond_img, playerPlatform_img;

// Keep track of current level number
int levelNum = 0;
// Maximum amount of platforms the player can create
int maxPlayerPlatformAmount = 1;
// Int to count the amount of diamonds in the game.
int maxDiamonds = 0;
// Tracks whether the current spacebar press has done something
boolean isSpacebarActionable = true;
// Display if the player can still play the game or not.  
boolean isGameOver = false;
// Center coordinates of the screen
int screenCenter_x;
int screenCenter_y;
// Maximum amount of cells that can fit on the screen
int maxCells_x;
int maxCells_y;
// Keep track of level size
int levelSize_x = 0;
int levelSize_y = 0;
int levelSizePx_x = TARGET_DISPLAY_WIDTH;
int levelSizePx_y = TARGET_DISPLAY_HEIGHT;
// Define the size of the zones (from edges of viewport) in which the level will scroll
float shiftZone_x;
float shiftZone_y;
// Offsets for the viewport
float offset_x = BASE_OFFSET_X;
float offset_y = BASE_OFFSET_Y;
boolean enableScrollingX = false;
boolean enableScrollingY = false;
// Pillar- and letterboxing stuff
boolean enablePillarBoxing = false;
boolean enableLetterBoxing = false;
// Background Color
color backgroundColor = color(55,44,44);
// Boolean used to display if the player is still on the map(delete in the final version)
boolean falllenOfMap;
// Spawn point of player
float playerSpawnX;
float playerSpawnY;

// Mouse position in relation to the level
float realMouseX;
float realMouseY;
// Moouse position from the previous frame
float realMousePrevX;
float realMousePrevY;

// Graphics buffers
PGraphics levelBuffer;
PGraphics backgroundBuffer;

// Load sound effects in memory
SoundFile fail;
SoundFile success;
