import java.util.SortedSet;
import java.util.TreeSet;
import java.util.Map;
import java.util.List;
import java.util.Collection;
import java.util.Collections;
import java.util.Arrays;
import g4p_controls.*;

// Farm Grid Settings
final int GRID_SIZE = 5;
final int GRID_SCALE = 80;

// Global Resources
SortedSet<String> ids;
HashMap<String, Growable> itemDictionary;
HashMap<String, Recipe> recipeBook;

// Game State
FarmGame farmGame;
List<Growable> availableSeeds; // Plantable items
SortedSet<String> grownPlants;

// User Interaction
int activeSeed;
boolean hasWateringCan = false;

boolean lmbDown = false;

// Drawing Variables
PFont uiFont;
PShape compost;
PShape wateringCan;

// Plantpedia UI
GPanel pediaPanel;
GPanel seedListSidebar;
GLabel seedListLabel;
GToggleGroup seedListGroup;
ArrayList<GOption> seedList;
GPanel selectedSeedPanel;
GLabel selectedSeedGrowth;
GLabel selectedSeedSpoil;
GCheckbox selectedSeedIsBase;
GPanel selectedSeedRecipe;
GLabel selectedSeedRecipeItems;

void setup() {
  size(400, 500);

  JSONObject jsonData = loadJSONObject("data.JSON");
  loadData(jsonData);

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

  initPlantpedia();
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
  if (overSeedSelector() && !pediaPanel.isVisible()) {
    fill(#00ff00);
  } else {
    fill(#007700);
  }
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

  if (isGameOver()) {
    push();
    textAlign(CENTER, CENTER);
    textSize(24);
    rectMode(CENTER);
    int boxWidth = (int)textWidth("Congradulations!\nYou have harvested\nevery type of plant!") + GRID_SCALE;
    int boxHeight = 24 * 6;

    fill(#007700);
    noStroke();
    rect(width / 2, farmGame.height / 2 + 6, boxWidth, boxHeight, GRID_SCALE / 2);

    fill(#ffffff);
    text("Congradulations!\nYou have harvested\nevery type of plant!", width / 2, farmGame.height / 2);
    pop();
  }
  else if (!pediaPanel.isVisible()) farmGame.hoverOverFarm();
}

void mousePressed() {
  if (isGameOver() || mouseX < 0 || mouseX > width || mouseY < 0 || mouseY > height) return;

  if (mouseButton == LEFT) {
    if (!pediaPanel.isVisible()) farmGame.mousePressed();
  }
}

void mouseReleased() {
  if (isGameOver() || mouseButton != LEFT) return;
  
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
    if (!pediaPanel.isVisible()) farmGame.mouseReleased(wasDragged, lmbWasDown);

    farmGame.endDrag();
  } else {
    if (wasDragged) {
      // Dragging an item over UI
      if (overCompost()) farmGame.endDrag();
      else farmGame.cancelDrag();

    } else if (!lmbWasDown) {
      // Clicked on UI
      if (pediaPanel.isVisible()) pediaPanel.setVisible(false);
      else if (overSeedSelector()) openPediaPanel();
      else if (hasWateringCan) hasWateringCan = false;
      else if (overWateringCan()) hasWateringCan = true;
    }
  }

  farmGame.drawFarm();
}

void mouseDragged() {
  if (isGameOver()) return;
  lmbDown = true;

  if (!pediaPanel.isVisible()) farmGame.mouseDragged();
}

void keyReleased() {
  if (!isGameOver()) {
    if (keyCode == ENTER || keyCode == RETURN) {
      farmGame.nextDay();
  
      saveGame();
      farmGame.drawFarm();
    } else if (keyCode == LEFT) {
      prevSeed();
    } else if (keyCode == RIGHT) {
      nextSeed();
    }
  } else if (keyCode == BACKSPACE || keyCode == DELETE) {
    // Clear farm of all plants (reset game)
    resetSave();
  }
}

void harvestPlant(Growable g) {
  grownPlants.add(g.itemId);

  if (!availableSeeds.contains(g)) {
    availableSeeds.add(g);
    Collections.sort(availableSeeds);

    activeSeed = availableSeeds.indexOf(g);
  }
}

/**
 * { @return is game over...}
 */
boolean isGameOver() {
  return grownPlants.size() == ids.size();
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
  ids = new TreeSet<String>();
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
  JSONArray unlockedSeeds;
  JSONArray grownData;
  JSONArray farmData;
  
  // Load default when no prior save is found
  try {
    saveData = loadJSONObject("save.JSON");
  } catch (Exception e) {
    saveData = loadJSONObject("saveDefault.JSON");
  }

  unlockedSeeds = saveData.getJSONArray("seeds");
  loadSeeds(unlockedSeeds);

  grownData = saveData.getJSONArray("grown");
  grownPlants = new TreeSet<String>();
  for (int ii = 0; ii < grownData.size(); ++ii) {
    String id = grownData.getString(ii);
    if (ids.contains(id)) grownPlants.add(id);
  }

  farmData = saveData.getJSONArray("farm");
  farmGame = new FarmGame(farmData);
}

/**
 * Reset game save and clear farm.
 */
void resetSave() {
  JSONObject saveData = loadJSONObject("saveDefault.JSON");
  JSONArray unlockedSeeds = saveData.getJSONArray("seeds");
  JSONArray grownData = saveData.getJSONArray("grown");
  JSONArray farmData = saveData.getJSONArray("farm");

  loadSeeds(unlockedSeeds);
  grownPlants = new TreeSet<String>(fromJSONArray(grownData));

  hasWateringCan = false;
  
  pediaPanel.setVisible(false);

  farmGame.resetFarm(farmData);
}

/**
 * Compile farm game state information and save to external file.
 */
void saveGame() {
  JSONObject saveData = new JSONObject();
  JSONArray unlockedSeeds = new JSONArray();
  JSONArray grownData = fromCollection(grownPlants);

  int index = 0;
  for (Growable g : availableSeeds) {
    unlockedSeeds.setString(index++, g.itemId);
  }
  saveData.setJSONArray("seeds", unlockedSeeds);
  saveData.setJSONArray("grown", grownData);
  saveData.setJSONArray("farm", farmGame.asJSONArray());

  saveJSONObject(saveData, "save.JSON");
}

void loadSeeds(JSONArray unlockedSeeds) {
  availableSeeds = new ArrayList<Growable>();
  activeSeed = 0;

  for (int ii = 0; ii < unlockedSeeds.size(); ++ii) {
    String id = unlockedSeeds.getString(ii);
    
    Growable item = itemDictionary.get(id);
    if (null != item) availableSeeds.add(item);
  }
}


JSONArray fromCollection(Collection<String> cc) {
  JSONArray result = new JSONArray();
  for (String item : cc) result.setString(result.size(), item);
  return result;
}

Collection<String> fromJSONArray(JSONArray arr) {
  SortedSet cc = new TreeSet<String>();
  for (int ii = 0; ii < arr.size(); ++ii) {
    cc.add(arr.getString(ii));
  }
  return cc;
}
