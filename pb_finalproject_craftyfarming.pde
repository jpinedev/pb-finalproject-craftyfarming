import java.util.HashSet;
import java.util.Map;

// Farm Grid Settings
final int GRID_SIZE = 5;
final int GRID_SCALE = 80;

// Global Resources
HashSet<String> ids;
HashMap<String, Growable> itemDictionary;
HashMap<String, Recipe> recipeLibrary;

// 5x5 Tile Farm (aka "Game Board")
FarmTile[][] farm;

// Plantable items
ArrayList<Growable> availableSeeds;
int activeSeed;

// Tile interaction
FarmTile draggedFrom; // should never be null while dragging is true
Plant draggedItem; // should never be null while dragging is true
boolean dragging;
boolean lmbDown = false;
boolean hasWateringCan = false;

// Drawing Variables
PGraphics farmRender;
PFont uiFont;
PShape compost;
PShape wateringCan;

void setup() {
  size(400, 500);

  JSONObject jsonData = loadJSONObject("data.JSON");
  loadData(jsonData);
  
  JSONArray farmData;
  
  // Load default when no prior farm is found
  try {
    farmData = loadJSONArray("farm.JSON");
  } catch (Exception e) {
    farmData = loadJSONArray("farmDefault.JSON");
  }
  loadFarm(farmData);
  
  availableSeeds = new ArrayList<Growable>();
  for (String id : ids) {
    // TODO: Limit starting seeds... maybe tie in with save data?
    availableSeeds.add(itemDictionary.get(id));
  }

  resetFarm();
  
  uiFont = createFont("Monospaced", 32);
  textFont(uiFont);
  
  farmRender = createGraphics(400, 400);
  drawFarm();

  compost = loadShape("compost.svg");
  compost.disableStyle();
  compost.scale(0.8);
  
  wateringCan = loadShape("watering-can.svg");
  wateringCan.disableStyle();
  wateringCan.scale(1.5);
}

void draw() {
  background(0);
  
  if (dragging) drawFarm();
  image(farmRender, 0, 0);
  
  // Draw UI
  push();
  noStroke();

  // UI Backgrounds
  // - Compost Background
  if (dragging) {
    if (draggedItem.isBad()) fill(overCompost() ? #00ff00 : #007700);
    else fill(overCompost() ? #ff0000 : #770000);
  }
  else fill(#770000);
  rect(10, 410, 80, 80, 10);

  // - Watering Can Background
  fill(overWateringCan() ? #0055FF : #001166);
  rect(100, 410, 80, 80, 10);

  // - Seeds Background
  push();
  stroke(#007700);
  noFill();
  rect(190, 410, width - 200, 80, 10);
  pop();


  fill(#ffffff);
  shape(compost, 29, 425);

  push();
  if (hasWateringCan) fill(#888888);
  shape(wateringCan, 106, 425);
  pop();

  textAlign(RIGHT);
  text(availableSeeds.get(activeSeed).itemName, width - 25, 462);

  pop();

  final int ii = floor(map(mouseX, 0, farmRender.width, 0, GRID_SIZE));
  final int jj = floor(map(mouseY, 0, farmRender.height, 0, GRID_SIZE));

  if (jj < GRID_SIZE) {
    // Highlight hovered tile
    color hoverColor;
    
    if (!hasWateringCan) hoverColor = color(255, 255, 255, 32);
    else hoverColor = color(64, 128, 255, 64);

    push();
    fill(hoverColor);
    noStroke();
    rect(ii * GRID_SCALE, jj * GRID_SCALE, GRID_SCALE, GRID_SCALE);
    pop();
  }
}

void drawFarm() {
  farmRender.beginDraw();
  farmRender.textAlign(CENTER);
  farmRender.textFont(uiFont);
  farmRender.textSize(14);

  // Draw all tiles in farm
  int jj = 0;
  for (FarmTile[] row : farm) {
    int ii = 0;
    for (FarmTile tile : row) {
      tile.draw(farmRender, ii, jj);
      ++ii;
    }
    ++jj;
  }
  
  farmRender.endDraw();
}

void mousePressed() {
  if (mouseX < 0 || mouseX > width || mouseY < 0 || mouseY > height) return;

  if (mouseButton == LEFT) {
    // Map mouse position to tile position
    final int ii = floor(map(mouseX, 0, farmRender.width, 0, GRID_SIZE));
    final int jj = floor(map(mouseY, 0, farmRender.height, 0, GRID_SIZE));

    if (jj < GRID_SIZE)
      if (!hasWateringCan && farm[jj][ii].hasPlant())
        draggedFrom = farm[jj][ii];
    
    // todo: maybe add a click/drag deadzone
  }
}

void mouseReleased() {
  if (mouseButton != LEFT) return;
  
  boolean wasDragged = dragging;
  boolean lmbWasDown = lmbDown;
  lmbDown = false;

  // Offscreen release
  if (mouseX < 0 || mouseX > width || mouseY < 0 || mouseY > height) {
    if (wasDragged) cancelDrag();
    else endDrag();

    drawFarm();
    return;
  }
  
  if (mouseY < farmRender.height) {
    // Mouse is over the Farm
    
    // Map mouse position to farm tile position
    final int ii = floor(map(mouseX, 0, farmRender.width, 0, GRID_SIZE));
    final int jj = floor(map(mouseY, 0, farmRender.height, 0, GRID_SIZE));
    
    if (wasDragged) {
      // Let go of dragged plant
      if (draggedFrom.index == farm[jj][ii].index || farm[jj][ii].hasBadPlant()) {
        // Replant in same spot
        cancelDrag();
      } else if (farm[jj][ii].isTilled()) {
        // Replant in new spot at drop location
        farm[jj][ii].setPlant(draggedItem);
      } else {
        // Plant already exists in drop location
        HashSet<String> recipes = farm[jj][ii].getSharedRecipes(draggedItem.itemId);
        if (recipes.size() == 0) cancelDrag();
        else {
          String growableKey = recipes.iterator().next();
          Growable _growable = itemDictionary.get(growableKey);
          
          Plant _plant = farm[jj][ii].transplant();
          
          // Calculate new adjusted growth and spoil stages
          float avgGrowthStage = draggedItem.getAvgGrowthStage(_plant);
          float avgSpoilStage = draggedItem.getAvgSpoilStage(_plant);
          float avgGrowthTime = draggedItem.getAvgGrowthTime(_plant);
          float avgSpoilTime = draggedItem.getAvgSpoilTime(_plant);
          
          int growthStage = floor(map(avgGrowthStage, 0, avgGrowthTime, 0, _growable.growthTime));
          int spoilStage = floor(map(avgSpoilStage, 0, avgSpoilTime, 0, _growable.spoilTime));
          
          farm[jj][ii].setPlant(new Plant(_growable, growthStage, spoilStage));
        }
      }
    } else if (!lmbWasDown) {
      // Clicked on tile
      farm[jj][ii].nextState(availableSeeds.get(activeSeed), hasWateringCan);
    }

    endDrag();
  } else {
    if (wasDragged) {
      if (overCompost()) endDrag();
      else cancelDrag();

    } else if (!lmbWasDown) {
      // Clicked on UI
      if (hasWateringCan) hasWateringCan = false;
      else if (overWateringCan()) hasWateringCan = true;
    }
  }

  drawFarm();
}

void mouseDragged() {
  lmbDown = true;

  if (null != draggedFrom) {
    if (null == draggedItem) {
      draggedItem = draggedFrom.transplant();
    }
    
    dragging = true;
  } else endDrag();

  if (hasWateringCan) {
    final int ii = floor(map(mouseX, 0, farmRender.width, 0, GRID_SIZE));
    final int jj = floor(map(mouseY, 0, farmRender.height, 0, GRID_SIZE));

    if (jj < GRID_SIZE) {
      if (farm[jj][ii].hasPlant()) farm[jj][ii].waterPlant();
    }
  }
}

void keyReleased() {
  if (keyCode == ENTER || keyCode == RETURN) {
    // Advance Game/Day Cycle
    for (FarmTile[] row : farm) {
      for (FarmTile tile : row) {
        tile.ageUp();
      }
    }

    saveFarm();
    drawFarm();
  } else if (keyCode == BACKSPACE || keyCode == DELETE) {
    // Clear farm of all plants (reset game)
    resetFarm();
    drawFarm();
  } else if (keyCode == LEFT) {
    prevSeed();
  } else if (keyCode == RIGHT) {
    nextSeed();
  }
}

void cancelDrag() {
  if (null != draggedItem) draggedFrom.setPlant(draggedItem);

  endDrag();
}

void endDrag() {
  draggedItem = null;
  draggedFrom = null;
  dragging = false;
}

void prevSeed() {
  if (--activeSeed < 0) activeSeed = availableSeeds.size() - 1;
}
void nextSeed() {
  if (++activeSeed >= availableSeeds.size()) activeSeed = 0;
}

// Load Farm from JSON Save Data
void loadFarm(JSONArray farmData) {
  farm = new FarmTile[GRID_SIZE][GRID_SIZE];
  
  for (int jj = 0; jj < GRID_SIZE; ++jj) {
    for (int ii = 0; ii < GRID_SIZE; ++ii) {
      final int index = jj * GRID_SIZE + ii;

      // Load each Tile and containing Plants
      if (!farmData.isNull(index)) {
        JSONObject tileData = farmData.getJSONObject(index);
        
        farm[jj][ii] = loadFarmTile(tileData, index);
      } else {
        farm[jj][ii] = new FarmTile(index);
      }
    }
  }
}

// Save Farm to JSON Save Data
void saveFarm() {
  JSONArray farmData = new JSONArray();
  for (int jj = 0; jj < GRID_SIZE; ++jj) {
    for (int ii = 0; ii < GRID_SIZE; ++ii) {
      final int index = jj * GRID_SIZE + ii;

      // Save each Tile and containing Plants
      JSONObject tile = farm[jj][ii].saveTile();
      farmData.setJSONObject(index, tile);
    }
  }
  
  saveJSONArray(farmData, "farm.JSON");
}

// Clear farm of all plants (reset farm to default state)
void resetFarm() {
  JSONArray farmData = loadJSONArray("farmDefault.JSON");

  loadFarm(farmData);

  activeSeed = 0;

  draggedFrom = null;
  draggedItem = null;
  dragging = false;
}

// Load Global Data
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
  recipeLibrary = new HashMap<String, Recipe>();
  loadRecipes(recipesData);
}
