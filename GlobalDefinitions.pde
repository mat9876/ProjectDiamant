//// MODULES ////
import processing.sound.SoundFile;
import processing.javafx.PGraphicsFX2D;

//// GLOBAL DEFINITIONS ////
// Desired framerate whereby the game will run at full speed
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
final static float MOVE_SPEED = 8;
final static float GRAVITY = 0.8;
final static float JUMP_SPEED = 12;
final static float DEFAULT_PLAYER_X = 200;
final static float DEFAULT_PLAYER_Y = 900;

final static int MAX_PLAYERNAME_LENGTH = 16;

//// GLOBAL VARIABLES ////
// Indicator on whether or not a map is loaded
boolean noMap = false;
// Arraylist of platforms that appear in the game.
ArrayList<Sprite> platforms = new ArrayList<>();
ArrayList<Sprite> diamonds = new ArrayList<>();
ArrayList<Sprite> spikes = new ArrayList<>();
ArrayList<Sprite> collected_diamonds = new ArrayList<>();
ArrayList<Sprite> playerPlatforms = new ArrayList<>();

// ArrayList of things the player can collide with
ArrayList<Sprite> collidables = new ArrayList<>();

// Input queue for resolving conflicting inputs.
// Should be sorted by most recent (newer -> older)
ArrayList<Integer> inputQueue = new ArrayList<>();

// Sprites / Images
Player player;
PImage square_img, square_img1, square_img2, square_img3, diamond_img, playerPlatform_img, spikes_img;

// Keep track of current level number
int levelNum = -1;
int levelFrameCount = 0;
// Maximum amount of platforms the player can create
int maxPlayerPlatformAmount = 1;
// Int to count the amount of diamonds in the game.
int maxDiamonds = 0;
// Tracks whether the current spacebar press has done something
boolean isSpacebarActionable = true;
// Display if the player can still play the game or not.  
boolean isGameOver = false;
boolean isPaused = true;
// Center coordinates of the screen
int screenCenter_x = 0;
int screenCenter_y = 0;
// Maximum amount of cells that can fit on the screen
int maxCells_x = 0;
int maxCells_y = 0;
// Keep track of level size
int levelSize_x = 0;
int levelSize_y = 0;
int levelSizePx_x = 0;
int levelSizePx_y = 0;
// Define the size of the zones (from edges of viewport) in which the level will scroll
float shiftZone_x = 0;
float shiftZone_y = 0;
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
PImage backgroundImage;
// Spawn point of player
float playerSpawnX = DEFAULT_PLAYER_X;
float playerSpawnY = DEFAULT_PLAYER_Y;

// Mouse position in relation to the level
int offsetMouseX = 0;
int offsetMouseY = 0;
// Moouse position from the previous frame
int offsetMousePrevX = 0;
int offsetMousePrevY = 0;

// Graphics buffers
PGraphics levelBuffer;
PGraphics backgroundBuffer;
PGraphics letterPillarBoxesBuffer;

// Load image off the custom cursor in memory;
PImage mouseCursor;

// Value to keep track of meta stats
Ref<String> playerName = new Ref<>("ANON");

int baseScore = 5000;
int timesReset = 0;
int totalPlatformsPlaced = 0;

Ref<Integer> playerScoreRef = new Ref<>(0);
Ref<Integer> teacherScoreRef = new Ref<>(0);
Ref<Integer> lesserScoreRef = new Ref<>(0);
int[] totalScores = {0,0,0};

// Define menus for playing
Menu nameInputMenu;
Menu startMenu;
Menu pauseMenu;
Menu completeMenu;
Menu endMenu;

Menu activeMenu;

// Load sound effects in memory
SoundFile fail;
SoundFile success;
