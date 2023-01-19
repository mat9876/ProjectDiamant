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
  public String text;
  public color textColor;
  public color backgroundColor;
  public float fontSize;

  public int size_x;
  public int size_y;
  
  private PGraphics buffer;

  public ButtonItem(String buttonText) {
    text = buttonText;
    textColor = color(255,255,255);
    backgroundColor = color(48,48,48);
    fontSize = 24;

    size_x = 256;
    size_y = 92;

    buffer = createGraphics(size_x, size_y);
    updateBuffer();
  }

  public void updateBuffer() {
    buffer.beginDraw();

    buffer.textAlign(CENTER, CENTER);
    buffer.textSize(fontSize);
    buffer.fill(textColor);

    buffer.background(backgroundColor);
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

public class ResumeButtonItem extends ButtonItem {
  public ResumeButtonItem() {
    super("Resume");
  }

  @Override
  public void click() {
    activeMenu.deactivate();
  }
}

public class ExitButtonItem extends ButtonItem {
  public ExitButtonItem() {
    super("Exit");
  }

  @Override
  public void click() {
    exit();
  }
}

public class ResetButtonItem extends ButtonItem {
  public ResetButtonItem() {
    super("Reset");
  }

  @Override
  public void click() {
    resetLevel();
    activeMenu.deactivate();
  }
}