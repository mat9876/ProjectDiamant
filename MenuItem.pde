public interface MenuItem {
  void updateBuffer();
  void click();

  PGraphics getBuffer();
  int getSize_x();
  int getSize_y();
}

// Base menu cell class
// Should be used only as a base; should not have functionality beyond that.
public class MenuCell implements MenuItem {
  public PGraphics buffer;

  public String text;

  public float fontSize;
  public float cornerRoundnessFactor;
  public color textColor;
  public color backgroundColor;

  public int size_x;
  public int size_y;

  public MenuCell() {
    fontSize = 24;
    cornerRoundnessFactor = 0.33;
    textColor = color(255,255,255,255);
    backgroundColor = color(255,255,255,64);

    size_x = 192;
    size_y = 64;
  }

  public MenuCell(String buttonText) {
    this();
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
public class BackButtonCell extends MenuCell {
  public BackButtonCell(String buttonText) {
    super(buttonText);
  }

  @Override
  public void click() {
    activeMenu.up();
  }
}

// Button for exiting the game
public class ExitButtonCell extends MenuCell {
  public ExitButtonCell(String buttonText) {
    super(buttonText);
  }

  @Override
  public void click() {
    exit();
  }
}

// Button for resetting the current level
public class ResetButtonCell extends MenuCell {
  public ResetButtonCell(String buttonText) {
    super(buttonText);
  }

  @Override
  public void click() {
    resetLevel();
    activeMenu.close();
  }
}

// Button for advancing to the next level
public class AdvanceButtonCell extends MenuCell {
  public AdvanceButtonCell(String buttonText) {
    super(buttonText);
  }

  @Override
  public void click() {
    activeMenu.close();

    levelNum += 1;
    loadLevel(levelNum);
  }
}

/**
 * Button for opening another menu.
 * Proper initialisation of this button should look like this:
 *   new SubmenuButtonCell(
 *     "BUTTON_TEXT",
 *     new Menu(
 *       new ExitButtonCell("Exit")
 *       new BackButtonCell("Back")
 *     )
 *   )
 */
public class SubmenuButtonCell extends MenuCell {
  Menu menu = null;

  public SubmenuButtonCell(String buttonText, Menu submenu) {
    super(buttonText);

    menu = submenu;
  }

  @Override
  public void click() {
    menu.prev = activeMenu;
    activeMenu = menu;
  }
}

public class textCell extends MenuCell {
  public float lineHeight = 1.25;

  public textCell(int size_x, textCellItem... items) {
    super();

    int x = 0;

    this.size_x = size_x;
    size_y = 0;
    int[] textY = new int[items.length];
    for (int i = 0; i < items.length; i++) {
      textY[i] = size_y + round(items[i].fontSize / 2);
      size_y += round(items[i].fontSize * lineHeight);
    }

    buffer = createGraphics(size_x, size_y);

    buffer.beginDraw();
      buffer.noStroke();

      for (int i = 0; i < items.length; i++) {
        buffer.textAlign(items[i].alignment, CENTER);
        buffer.textSize(items[i].fontSize);
        buffer.fill(items[i].textColor);
        switch (items[i].alignment) {
          case LEFT:
            x = 0;
            break;
          case CENTER:
            x = size_x / 2;
            break;
          case RIGHT:
            x = size_x;
            break;
        }

        buffer.text(items[i].txt, x, textY[i]);
      }
    buffer.endDraw();
  }

  @Override
  public void click() {
    return;
  }
}

public class textCellItem {
  public String txt;
  public float fontSize;
  public int alignment;
  public color textColor;

  public textCellItem(String txt, float fontSize, int alignment, color textColor) {
    this.txt = txt;
    this.fontSize = fontSize;
    this.alignment = alignment;
    this.textColor = textColor;
  }
}