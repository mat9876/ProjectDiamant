public class Menu {
  private PGraphics buffer;
  public ArrayList<Integer> state;
  public boolean isActive;

  public Menu() {
    buffer = createGraphics(pixelWidth, pixelHeight);
    state = new ArrayList<>();
    isActive = false;
  }

  public void display() {
    imageMode(CORNER);
    image(buffer, 0, 0);
  }

  public void updateBuffer() {
    buffer.beginDraw();
    // TODO: draw menu elements
    buffer.endDraw();
  }

  public void processClick(float x, float y) {
    // TODO: process click logic
  }

  // Step back from a submenu
  // Returns true if able, false if already at root
  public boolean up() {
    if (state.size() == 0) {
      return false;
    }
    // TODO
    return true;
  }

  public void deactivate() {
    state.clear();
    isActive = false;
  }
}

public class PauseMenu extends Menu {
  // TODO: pause menu
}

public class StartMenu extends PauseMenu {
  // TODO: start menu
}

public class CompleteMenu extends Menu {
  // TODO: in-between menu
}

public class EndMenu extends Menu {
  // TODO: end menu
}