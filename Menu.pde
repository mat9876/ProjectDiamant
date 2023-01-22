public class Menu {
  private PGraphics buffer;
  private int[][] menuItemsBounds;
  public MenuItem[] menuItems;
  public Menu prev = null;

  public int margin_x = 32;
  public int margin_y = 32;
  public int padding_x = 16;
  public int padding_y = 16;
  public float cornerRoundnessFactor = 0.33;
  public color backgroundColor = color(0,0,0,128);

  public int size_x = 2 * margin_x;
  public int size_y = 2 * margin_y;

  public Menu(MenuItem... items) {
    menuItems = items;
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

    buffer = createGraphics(size_x, size_y);
    updateBuffer();
  }

  // Redraw the menu image buffer
  public void updateBuffer() {
    int menuItemPos_y = margin_y;
    float cornerRoundnessPx = cornerRoundnessFactor * min(size_x, size_y) / 2;

    buffer.beginDraw();
      buffer.imageMode(CORNER);
      buffer.noStroke();

      buffer.fill(backgroundColor);
      buffer.rect(0, 0, size_x, size_y, cornerRoundnessPx);

      for (int i = 0; i < menuItems.length; i++) {
        buffer.image(menuItems[i].getBuffer(), menuItemsBounds[0][i], menuItemsBounds[2][i]);
      }
    buffer.endDraw();
  }

  // Process a click
  public void processClick(int x, int y) {
    // Get mouse position relative to the menu
    int menuMouseX = x - screenCenter_x + (size_x / 2);
    int menuMouseY = y - screenCenter_y + (size_y / 2);

    // Check if a menuItem has been clicked
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

  // Close this menu and all parent menus
  public void close() {
    if (up()) {
      prev.close();
    }
  }

  // Step back from a submenu
  // Returns true if able, false if already at root
  public boolean up() {
    if (prev == null) {
      isPaused = false;
      return false;
    }
    activeMenu = prev;
    return true;
  }

  public PGraphics getBuffer() {
    return buffer;
  }
}