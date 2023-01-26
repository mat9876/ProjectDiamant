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
      buffer.clear();
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
 *     new Menu(1,
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
    switchMenu(menu);
  }
}

// Text cell for displaying fancy text
public class TextCell extends MenuCell {
  private TextCellItem[] textItems;
  private int[] textY;
  public float lineHeight = 1.25;

  public TextCell(int size_x, TextCellItem... items) {
    super();
    textItems = items;

    this.size_x = size_x;
    size_y = 0;
    textY = new int[textItems.length];
    for (int i = 0; i < textItems.length; i++) {
      textY[i] = size_y + round(textItems[i].fontSize / 2);
      size_y += round(textItems[i].fontSize * lineHeight);
    }

    buffer = createGraphics(size_x, size_y);
    updateBuffer();
  }

  @Override
  public void updateBuffer() {
    int x = 0;

    buffer.beginDraw();
      buffer.clear();
      buffer.noStroke();

      for (int i = 0; i < textItems.length; i++) {
        buffer.textAlign(textItems[i].alignment, CENTER);
        buffer.textSize(textItems[i].fontSize);
        buffer.fill(textItems[i].textColor);
        switch (textItems[i].alignment) {
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

        textItems[i].update();
        buffer.text(textItems[i].txt, x, textY[i]);
      }
    buffer.endDraw();
  }

  @Override
  public void click() {
    return;
  }
}

// Text cell for an input field, with the specified item being considered the input field
public class InputTextCell extends TextCell {
  public int inputFieldIndex;
  public boolean isFocused = false;

  public InputTextCell(int size_x, int index, TextCellItem... items) {
    super(size_x, items);
    inputFieldIndex = index;
  }
}

// TODO: Text cell for a scoreboard
public class ScoreBoardCell extends TextCell {
  public ScoreBoardCell(int size_x, TextCellItem... items) {
    super(size_x, items);
  }
}

// Base text cell item
public class TextCellItem {
  public String txt;
  public float fontSize;
  public int alignment;
  public color textColor;

  public TextCellItem(String txt, float fontSize, int alignment, color textColor) {
    this.txt = txt;
    this.fontSize = fontSize;
    this.alignment = alignment;
    this.textColor = textColor;
  }

  public void update() {
    return;
  }
}

// Text cell item for displaying a score
public class VarTextCellItem<T> extends TextCellItem {
  public String formatString;
  public Ref<T>[] variables;

  public VarTextCellItem(float fontSize, int alignment, color textColor, String formatString, Ref<T>... variables) {
    super("", fontSize, alignment, textColor);
    this.formatString = formatString;
    this.variables = variables;
    update();
  }

  @Override
  public void update() {
    Object[] vars = new Object[variables.length];
    for (int i = 0; i < variables.length; i ++) {
      vars[i] = variables[i].value;
    }
    txt = String.format(formatString, vars);
  }
}
