import java.util.Map;

// Farm Grid Settings
final int GRID_SIZE = 5;
final int GRID_SCALE = 80;

// Global Resources
ArrayList<String> ids;
HashMap<String, Growable> itemDictionary;
HashMap<String, Recipe> recipeLibrary;

// 5x5 Tile Farm (aka "Game Board")
FarmTile[][] farm;
ArrayList<Growable> availableSeeds;
int activeSeed;

// Drawing Variables
PGraphics farmRender;
PFont uiFont;

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
  activeSeed = 0;

  farmRender = createGraphics(400, 400);
  drawFarm();
  
  uiFont = createFont("Monospaced", 32);
  textFont(uiFont); 
}

void draw() {
  background(0);
  
  image(farmRender, 0, 0);
  
  text(availableSeeds.get(activeSeed).itemName, width / 2, 450);
}

void drawFarm() {
  farmRender.beginDraw();

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

void mouseReleased() {
  if (mouseX < 0 || mouseX > width || mouseY < 0 || mouseY > height) return;

  if (mouseX < farmRender.height) {
    // Map mouse position to tile position
    final int ii = floor(map(mouseX, 0, farmRender.width, 0, GRID_SIZE));
    final int jj = floor(map(mouseY, 0, farmRender.height, 0, GRID_SIZE));
    
    farm[jj][ii].nextState(availableSeeds.get(activeSeed));
    drawFarm();
  } else {
    // TODO: Handle UI click events
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
        
        farm[jj][ii] = loadFarmTile(tileData);
      } else {
        farm[jj][ii] = new FarmTile();
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
}

// Load Global Data
void loadData(JSONObject data) {
  // Load IDs for all growable items
  JSONArray idsData = data.getJSONArray("ids");
  ids = new ArrayList<String>();
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
