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

void setup() {
  size(400, 400);
  noLoop();

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
}

void draw() {
  background(0);

  // Draw all tiles in farm
  int jj = 0;
  for (FarmTile[] row : farm) {
    int ii = 0;
    for (FarmTile tile : row) {
      tile.draw(ii, jj);
      ++ii;
    }
    ++jj;
  }
}

void mouseReleased() {
  if (mouseX < 0 || mouseX > width || mouseY < 0 || mouseY > height) return;

  // Map mouse position to tile position
  int ii = floor(map(mouseX, 0, width, 0, 5));
  int jj = floor(map(mouseY, 0, height, 0, 5));
  
  println(ii, jj);
  
  farm[jj][ii].nextState(itemDictionary.get("lettuce"));
  redraw();
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
    redraw();
  } else if (keyCode == BACKSPACE || keyCode == DELETE) {
    // Clear farm of all plants (reset game)
    resetFarm();
    redraw();
  }
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
