public class Menu {
  private PGraphics buffer;
  private int[][] menuItemsBounds;
  public MenuItem[] menuItems;

  public ArrayList<Integer> state;
  public int margin_x = 50;
  public int margin_y = 50;
  public int padding_x = 20;
  public int padding_y = 20;
  public int size_x = 2 * margin_x;
  public int size_y = 2 * margin_y;

  public color backgroundColor;

  public Menu(MenuItem... items) {
    menuItems = items;
    state = new ArrayList<>();
    menuItemsBounds = new int[4][menuItems.length];

    int max_x = 0;
    int menuItemPos_y = margin_y;
    for (int i = 0; i < menuItems.length; i++) {
      // Determine maximum width
      if (menuItems[i].getSize_x() > max_x) {
        max_x = menuItems[i].getSize_x();
      }

      // Set y-coordinates of top & bottom edges of the item
      menuItemsBounds[2][i] = menuItemPos_y;
      menuItemsBounds[3][i] = menuItemsBounds[2][i] + menuItems[i].getSize_y();

      size_y += menuItems[i].getSize_y();
      menuItemPos_y += menuItems[i].getSize_y() + padding_y;
    }

    for (int i = 0; i < menuItems.length; i++) {
      // Set x-coordinates of left & right edges of the item
      menuItemsBounds[0][i] = max_x - menuItems[i].getSize_x() + margin_x;
      menuItemsBounds[1][i] = menuItemsBounds[0][i] + menuItems[i].getSize_x();
    }

    size_x += max_x;
    size_y += (menuItems.length - 1) * padding_y;

    backgroundColor = color(0,0,0);

    buffer = createGraphics(size_x, size_y);
    updateBuffer();
  }

  public void display(float x, float y) {
    image(buffer, x, y);
  }

  public void updateBuffer() {
    int menuItemPos_y = margin_y;

    buffer.beginDraw();
    buffer.imageMode(CORNER);
    buffer.background(backgroundColor);
    for (int i = 0; i < menuItems.length; i++) {
      buffer.image(menuItems[i].getBuffer(), menuItemsBounds[0][i], menuItemsBounds[2][i]);
    }
    buffer.endDraw();
  }

  public void processClick(int x, int y) {
    // Get mouse position relative to the menu
    float menuMouseX = x - screenCenter_x + (size_x / 2);
    float menuMouseY = y - screenCenter_y + (size_y / 2);
    for (int i = 0; i < menuItems.length; i++) {
      if (
        menuMouseX > menuItemsBounds[0][i] && menuMouseX < menuItemsBounds[1][i]
        && menuMouseY > menuItemsBounds[2][i] && menuMouseY < menuItemsBounds[3][i]
      ) {
        menuItems[i].click();
        return;
      }
    }
  }

  // Step back from a submenu
  // Returns true if able, false if already at root
  public boolean up() {
    if (state.size() == 0) {
      return false;
    }
    // Expand if multiple levels are needed
    return true;
  }

  public void deactivate() {
    state.clear();
    isPaused = false;
  }
}