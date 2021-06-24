import java.util.HashSet;
import java.util.Map;

// Farm Grid Settings
final int GRID_SIZE = 5;
final int GRID_SCALE = 80;

// Global Resources
HashSet<String> ids;
HashMap<String, Growable> itemDictionary;
HashMap<String, Recipe> recipeBook;

// Game State
FarmGame farmGame;
ArrayList<Growable> availableSeeds; // Plantable items

// User Interaction
int activeSeed;
boolean hasWateringCan = false;

boolean lmbDown = false;

// Drawing Variables
PFont uiFont;
PShape compost;
PShape wateringCan;

void setup() {
  size(400, 500);

  JSONObject jsonData = loadJSONObject("data.JSON");
  loadData(jsonData);

  availableSeeds = new ArrayList<Growable>();
  for (String id : ids) {
    // TODO: Limit starting seeds... maybe tie in with save data?
    availableSeeds.add(itemDictionary.get(id));
  }

  uiFont = createFont("Monospaced", 32);
  textFont(uiFont);
  
  loadSave();
  
  // Load UI Icons
  compost = loadShape("compost.svg");
  compost.disableStyle();
  compost.scale(0.8);
  
  wateringCan = loadShape("watering-can.svg");
  wateringCan.disableStyle();
  wateringCan.scale(1.5);
}

void draw() {
  background(0);

  image(farmGame.getImage(), 0, 0);
  
  // Draw UI
  push();
  noStroke();

  // UI Backgrounds
  // - Compost Background
  if (farmGame.isDraggingItem()) {
    if (farmGame.isDraggingBadItem()) fill(overCompost() ? #00ff00 : #007700);
    else fill(overCompost() ? #ff0000 : #770000);
  }
  else fill(#770000);
  rect(10, 410, 80, 80, 10);

  // - Watering Can Background
  fill(overWateringCan() && !farmGame.isDraggingItem() ? #0055FF : #001166);
  rect(100, 410, 80, 80, 10);

  // - Seeds Background
  push();
  stroke(#007700);
  noFill();
  rect(190, 410, width - 200, 80, 10);
  pop();


  // UI Elements
  // - Compost Icon
  fill(#ffffff);
  shape(compost, 29, 425);

  // - Watering Can Icon
  push();
  if (hasWateringCan) fill(#888888);
  shape(wateringCan, 106, 425);
  pop();

  // - Active Seed
  textAlign(RIGHT);
  text(availableSeeds.get(activeSeed).itemName, width - 25, 462);

  pop();

  farmGame.hoverOverFarm();
}

void mousePressed() {
  if (mouseX < 0 || mouseX > width || mouseY < 0 || mouseY > height) return;

  if (mouseButton == LEFT) farmGame.mousePressed();
}

void mouseReleased() {
  if (mouseButton != LEFT) return;
  
  boolean wasDragged = farmGame.isDraggingItem();
  boolean lmbWasDown = lmbDown;
  lmbDown = false;

  if (mouseX < 0 || mouseX > width || mouseY < 0 || mouseY > height) {
    // Offscreen release
    if (wasDragged) farmGame.cancelDrag();
    else farmGame.endDrag();

    farmGame.drawFarm();
    return;
  }
  
  if (mouseY < farmGame.height) {
    // Mouse is over the Farm
    farmGame.mouseReleased(wasDragged, lmbWasDown);

    farmGame.endDrag();
  } else {
    if (wasDragged) {
      // Dragging an item over UI
      if (overCompost()) farmGame.endDrag();
      else farmGame.cancelDrag();

    } else if (!lmbWasDown) {
      // Clicked on UI
      if (hasWateringCan) hasWateringCan = false;
      else if (overWateringCan()) hasWateringCan = true;
    }
  }

  farmGame.drawFarm();
}

void mouseDragged() {
  lmbDown = true;

  farmGame.mouseDragged();
}

void keyReleased() {
  if (keyCode == ENTER || keyCode == RETURN) {
    farmGame.nextDay();

    saveGame();
    farmGame.drawFarm();
  } else if (keyCode == BACKSPACE || keyCode == DELETE) {
    // Clear farm of all plants (reset game)
    resetSave();
  } else if (keyCode == LEFT) {
    prevSeed();
  } else if (keyCode == RIGHT) {
    nextSeed();
  }
}

void prevSeed() {
  if (--activeSeed < 0) activeSeed = availableSeeds.size() - 1;
}
void nextSeed() {
  if (++activeSeed >= availableSeeds.size()) activeSeed = 0;
}

/**
 * Load global data and prepare dictionaries.
 */
void loadData(JSONObject data) {
  // Load IDs for all growable items
  JSONArray idsData = data.getJSONArray("ids");
  ids = new HashSet<String>();
  for (int ii = 0; ii < idsData.size(); ++ii) {
    ids.add(idsData.getString(ii));
  }

  // Load a growable item for each ID
  JSONObject itemsData = data.getJSONObject("items");
  itemDictionary = new HashMap<String, Growable>();
  loadGrowables(itemsData);

  // Load recipes for each growable item
  JSONObject recipesData = data.getJSONObject("recipes");
  recipeBook = new HashMap<String, Recipe>();
  loadRecipes(recipesData);
}

/**
 * Load game save (if any) and build corresponding farm.
 */
void loadSave() {
  JSONObject saveData;
  JSONArray farmData;
  
  // Load default when no prior save is found
  try {
    saveData = loadJSONObject("save.JSON");
  } catch (Exception e) {
    saveData = loadJSONObject("saveDefault.JSON");
  }

  farmData = saveData.getJSONArray("farm");

  farmGame = new FarmGame(farmData);
}

/**
 * Reset game save and clear farm.
 */
void resetSave() {
  JSONObject saveData = loadJSONObject("saveDefault.JSON");
  JSONArray farmData = saveData.getJSONArray("farm");

  activeSeed = 0;
  hasWateringCan = false;

  farmGame.resetFarm(farmData);
}

/**
 * Compile farm game state information and save to external file.
 */
void saveGame() {
  JSONObject saveData = new JSONObject();
  saveData.setJSONArray("farm", farmGame.asJSONArray());

  saveJSONObject(saveData, "save.JSON");
}
