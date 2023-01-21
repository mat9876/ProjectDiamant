public interface MenuItem {
  void updateBuffer();
  void click();

  PGraphics getBuffer();
  int getSize_x();
  int getSize_y();
}

/*
// Base text class
public class TextItem implements MenuItem {

}
*/

// Base button class
// Should be used only as a base; it has no functionality beyond that.
public class ButtonItem implements MenuItem {
  private PGraphics buffer;

  public String text;

  public float fontSize = 24;
  public float cornerRoundnessFactor = 0.33;
  public color textColor = color(255,255,255,255);
  public color backgroundColor = color(64,64,64,192);

  public int size_x = 192;
  public int size_y = 64;

  public ButtonItem(String buttonText) {
    text = buttonText;

    buffer = createGraphics(size_x, size_y);
    updateBuffer();
  }

  public void updateBuffer() {
    float cornerRoundnessPx = cornerRoundnessFactor * min(size_x, size_y) / 2;

    buffer.beginDraw();
      buffer.noStroke();
      buffer.textAlign(CENTER, CENTER);
      buffer.textSize(fontSize);

      buffer.fill(backgroundColor);
      buffer.rect(0, 0, size_x, size_y, cornerRoundnessPx);

      buffer.fill(textColor);
      buffer.text(text, size_x/2, size_y/2);
    buffer.endDraw();
  }
  
  public void click() {
    println("Clicked a placeholder!");
  }

  // Workaround for sometimes being unable to fetch non-interface variables
  // For example, when in an ArrayList 
  public PGraphics getBuffer() {
    return buffer;
  }
  public int getSize_x() {
    return size_x;
  }
  public int getSize_y() {
    return size_y;
  }
}

// Button for going back in a menu and/or closing the menu
public class BackButtonItem extends ButtonItem {
  public BackButtonItem(String buttonText) {
    super(buttonText);
  }

  @Override
  public void click() {
    activeMenu.up();
  }
}

// Button for exiting the game
public class ExitButtonItem extends ButtonItem {
  public ExitButtonItem(String buttonText) {
    super(buttonText);
  }

  @Override
  public void click() {
    exit();
  }
}

// Button for resetting the current level
public class ResetButtonItem extends ButtonItem {
  public ResetButtonItem(String buttonText) {
    super(buttonText);
  }

  @Override
  public void click() {
    resetLevel();
    activeMenu.close();
  }
}

/**
 * Button for opening another menu.
 * Proper initialisation of this button should look like this:
 *   new SubmenuButtonItem(
 *     "BUTTON_TEXT",
 *     new Menu(
 *       new ButtonItem("SUBMENU_BUTTON_TEXT")
 *       new BackButtonItem("Back")
 *     )
 *   )
 */
public class SubmenuButtonItem extends ButtonItem {
  Menu menu = null;

  public SubmenuButtonItem(String buttonText, Menu submenu) {
    super(buttonText);

    menu = submenu;
  }

  @Override
  public void click() {
    menu.prev = activeMenu;
    activeMenu = menu;
  }
}