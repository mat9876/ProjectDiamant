public interface MenuInterface {
  void display(float x, float y);
  void updateBuffer();
  void processClick(float x, float y);
  void deactivate();
  boolean up();
}

public class Menu implements MenuInterface {
  private PGraphics buffer;
  public ArrayList<MenuItem> items;

  public ArrayList<Integer> state;
  public int margin_x = 50;
  public int margin_y = 50;
  public int padding_x = 20;
  public int padding_y = 20;
  public int size_x = 2 * margin_x;
  public int size_y = 2 * margin_y;

  public color backgroundColor;

  public Menu() {
    items = new ArrayList<>();
    state = new ArrayList<>();

    // TODO: Remove (temp. for test)
    items.add(new ResumeButtonItem());
    items.add(new ExitButtonItem());

    int max_x = 0;
    for (MenuItem item : items) {
      if (item.getSize_x() > max_x) {
        max_x = item.getSize_x();
      }

      size_y += item.getSize_y();
    }

    size_x += max_x;
    size_y += (items.size() - 1) * padding_y;

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

    for (int i = 0; i < items.size(); i++) {
      buffer.image(items.get(i).getBuffer(), margin_x, menuItemPos_y);
      menuItemPos_y += items.get(i).getSize_y() + padding_y;
    }
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
  }
}

public class StartMenu extends PauseMenu {
  // TODO: start menu
}

public class PauseMenu extends Menu {
  // TODO: pause menu
}

public class CompleteMenu extends Menu {
  // TODO: in-between menu
}

public class EndMenu extends Menu {
  // TODO: end menu
}