public class Menu {
  private int[][] menuItemsBounds;

  public PGraphics buffer;
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

  public int shortcutCooldownDuration = 30;
  public int shortcutCooldownEnd = 0;

  public int escapeActionItemIndex;

  public Menu(int escapeActionItemIndex, MenuItem... items) {
    this.escapeActionItemIndex = escapeActionItemIndex;
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
      menuItemsBounds[0][i] = (max_x - menuItems[i].getSize_x()) / 2 + margin_x;
      menuItemsBounds[1][i] = menuItemsBounds[0][i] + menuItems[i].getSize_x();
    }

    size_x += max_x;
    size_y += (menuItems.length - 1) * padding_y;

    buffer = createGraphics(size_x, size_y);
    updateBuffer();
  }

  // Draw the menu image buffer
  private void updateBufferInit() {
    int menuItemPos_y = margin_y;
    float cornerRoundnessPx = cornerRoundnessFactor * min(size_x, size_y) / 2;

    buffer.beginDraw();
      buffer.clear();
      buffer.imageMode(CORNER);
      buffer.noStroke();
      buffer.fill(backgroundColor);

      // Menu background
      buffer.rect(0, 0, size_x, size_y, cornerRoundnessPx);

      // Menu items
      for (int i = 0; i < menuItems.length; i++) {
        buffer.image(menuItems[i].getBuffer(), menuItemsBounds[0][i], menuItemsBounds[2][i]);
      }
    buffer.endDraw();
  }

  // Redraw the buffer after initialisation
  public void updateBuffer() {
    for (MenuItem item : menuItems) {
      item.updateBuffer();
    }
    updateBufferInit();
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

  public void doEscapeAction() {
    if (frameCount >= shortcutCooldownEnd && escapeActionItemIndex >= 0 && escapeActionItemIndex < menuItems.length) {
      menuItems[escapeActionItemIndex].click();
    }
  }

  public void startCooldown() {
    shortcutCooldownEnd = frameCount + shortcutCooldownDuration;
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
    switchMenu(prev);
    return true;
  }
}