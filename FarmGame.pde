/**
 * A FarmGame is a collection of farm tiles that make up the entire farm.
 * 
 * FarmGame
 */
class FarmGame {

  public final int width = GRID_SIZE * GRID_SCALE;
  public final int height = GRID_SIZE * GRID_SCALE;

  // 5x5 Tile Farm (aka "Game Board")
  private FarmTile[][] farm;

  // Tile interaction
  private FarmTile draggedFrom; // should never be null while dragging is true
  private Plant draggedItem; // should never be null while dragging is true
  private boolean dragging;
  private boolean lmbDown = false;

  // Drawing Variables
  private PGraphics farmRender;

  /**
   * Build a farm from previous save data.
   * 
   * @param farmData farm save data as JSON
   */
  public FarmGame(JSONArray farmData) {
    this.farmRender = createGraphics(width, height);
    this.loadFarm(farmData);
    this.drawFarm();
  }

  /**
   * Get the flattened array index of the Tile at the given grid position.
   * @deprecated due to delegating some mouse event handling to FarmGame
   * 
   * @param ii column in grid
   * @param jj row in grid
   * 
   * @return -1 for invald grid position
   * @return tile index at the given position
   */
  public int indexOf(int ii, int jj) {
    if (ii < 0 || ii >= GRID_SIZE || jj < 0 || jj >= GRID_SIZE) return -1;

    return this.farm[jj][ii].index;
  }

  /**
   * Get the Tile at the with the given index.
   * @deprecated due to delegating some mouse event handling to FarmGame
   * 
   * @param index flattened array index (see this.indexOf() for calculation)
   * 
   * @return null for invalid index
   * @return tile with given index
   */
  public FarmTile getTile(int index) {
    if (index < 0 || index >= GRID_SIZE * GRID_SIZE) return null;

    final int ii = index % GRID_SIZE;
    final int jj = index / GRID_SIZE;

    return this.farm[jj][ii];
  }

  /**
   * Delegate mousePressed() method for left mouse presses on the farmRender.
   */
  public void mousePressed() {
    final int ii = mapMouseXToGrid();
    final int jj = mapMouseYToGrid();

    if (jj < GRID_SIZE)
      if (!hasWateringCan && this.farm[jj][ii].hasPlant())
        this.draggedFrom = this.farm[jj][ii]; // select active tile for dragging
    
    // todo: maybe add a click/drag deadzone
  }

  /**
   * Delegate mouseDragged() method for left mouse dragging over the farmRender.
   */
  public void mouseDragged() {
    if (null != this.draggedFrom) {
      if (null == this.draggedItem) {
        // Begin dragging item
        this.draggedItem = this.draggedFrom.transplant();
      }
      
      this.dragging = true;
    } else this.endDrag();

    if (hasWateringCan) {
      final int ii = mapMouseXToGrid();
      final int jj = mapMouseYToGrid();

      if (ii >= 0 && ii < GRID_SIZE && jj >= 0 && jj < GRID_SIZE) {
        if (this.farm[jj][ii].hasPlant()) {
          this.farm[jj][ii].waterPlant();

          this.drawFarm();
        }
      }
    }
  }

  /**
   * Delegate mouseReleased() method for releasing left mouse above the farm.
   * 
   * @param wasDragged is letting go from a drag
   * @param lmbWasDown was the mouse pressed longer than a click
   */
  public void mouseReleased(boolean wasDragged, boolean lmbWasDown) {
    final int ii = mapMouseXToGrid();
    final int jj = mapMouseYToGrid();
    
    if (wasDragged) {
      // Let go of dragged plant
      if (this.draggedFrom.index == this.farm[jj][ii].index || this.farm[jj][ii].hasBadPlant()) {
        // Replant in same spot
        this.cancelDrag();
      } else if (this.farm[jj][ii].isTilled()) {
        // Replant in new spot at drop location
        this.farm[jj][ii].setPlant(this.draggedItem);
      } else {
        // Plant already exists in drop location
        SortedSet<String> recipes = this.farm[jj][ii].getSharedRecipes(this.draggedItem.itemId);
        if (recipes.size() == 0) this.cancelDrag();
        else {
          String growableKey = recipes.iterator().next();
          Growable _growable = itemDictionary.get(growableKey);
          
          Plant _plant = this.farm[jj][ii].transplant();
          
          // Calculate new adjusted growth and spoil stages
          float avgGrowthStage = this.draggedItem.getAvgGrowthStage(_plant);
          float avgSpoilStage = this.draggedItem.getAvgSpoilStage(_plant);
          float avgGrowthTime = this.draggedItem.getAvgGrowthTime(_plant);
          float avgSpoilTime = this.draggedItem.getAvgSpoilTime(_plant);
          
          int growthStage = floor(map(avgGrowthStage, 0, avgGrowthTime, 0, _growable.growthTime));
          int spoilStage = floor(map(avgSpoilStage, 0, avgSpoilTime, 0, _growable.spoilTime));
          
          this.farm[jj][ii].setPlant(new Plant(_growable, growthStage, spoilStage));
        }
      }
    } else if (!lmbWasDown) {
      // Clicked on tile
      if (!hasWateringCan && this.farm[jj][ii].hasRipePlant()) harvestPlant(this.farm[jj][ii].transplant());
      else this.farm[jj][ii].nextState(availableSeeds.get(activeSeed), hasWateringCan);
    }
  }

  /**
   * Let go of any plant in hand, and return it to its latest tile.
   */
  public void cancelDrag() {
    if (null != this.draggedItem) this.draggedFrom.setPlant(this.draggedItem);
  
    this.endDrag();
  }

  /**
   * Reset dragging state variables for next drag.
   */
  public void endDrag() {
    this.draggedItem = null;
    this.draggedFrom = null;
    this.dragging = false;
  }

  /**
   * { @return is dragging left mouse button... }
   */
  public boolean isDragging() {
    return this.lmbDown;
  }

  /**
   * { @return is dragging an item... }
   */
  public boolean isDraggingItem() {
    return this.dragging;
  }

  /**
   * { @return is dragging a bad (spoiled) item... }
   */
  public boolean isDraggingBadItem() {
    return this.isDraggingItem() && this.draggedItem.isBad();
  }

  /**
   * Draw the farm on the farmRender.
   */
  void drawFarm() {
    this.farmRender.beginDraw();
    this.farmRender.textAlign(CENTER);
    this.farmRender.textFont(uiFont);
    this.farmRender.textSize(14);

    // Draw all tiles in farm
    int jj = 0;
    for (FarmTile[] row : this.farm) {
      int ii = 0;
      for (FarmTile tile : row) {
        tile.draw(this.farmRender, ii, jj);
        ++ii;
      }
      ++jj;
    }
    
    this.farmRender.endDraw();
  }

  /**
   * Mouse is over the farm, highlight hovered tile
   */
  void hoverOverFarm() {
    final int ii = this.mapMouseXToGrid();
    final int jj = this.mapMouseYToGrid();

    if (ii >= 0 && ii < GRID_SIZE && jj >= 0 && jj < GRID_SIZE) {
      // Highlight hovered tile
      color hoverColor;
      
      if (!hasWateringCan) {
        if (this.farm[jj][ii].isTilled() && !farmGame.isDraggingBadItem()) {
          // Moving plant from one tile to another tilled tile
          hoverColor = color(0, 255, 0, 64); // Green
        }
        else if (this.farm[jj][ii].hasRipePlant()) {
          // Has plant ready to harvest
          hoverColor = color(255, 255, 0, 96); // Goldish
        }
        else hoverColor = color(255, 255, 255, 32); // White
      }
      else {
        if (this.farm[jj][ii].isWatered()) {
          // Tile is already watered today
          hoverColor = color(255, 255, 255, 32); // White
        }
        else if (!this.farm[jj][ii].hasPlant()) {
          // Tile does not have any plants to be watered
          hoverColor = color(64, 128, 255, 32); // Translucent Blue
        }
        else {
          // Plant can be watered
          hoverColor = color(64, 128, 255, 96); // Blue
        }
      }

      // Display tile hover
      push();
      fill(hoverColor);
      noStroke();
      rect(ii * GRID_SCALE, jj * GRID_SCALE, GRID_SCALE, GRID_SCALE);
      pop();
    }
  }

  /**
   *  Age all plants by one day (tick).
   */
  void nextDay() {
    for (FarmTile[] row : farm)
      for (FarmTile tile : row)
        tile.ageUp();
  }

  /**
   * { @return rendered farm image... }
   */
  PImage getImage() {
    return this.farmRender;
  }

  /**
   * Load Farm from JSON Save Data.
   * 
   * @param farmData json array containing all farm tile information
   */
  private void loadFarm(JSONArray farmData) {
    this.farm = new FarmTile[GRID_SIZE][GRID_SIZE];
    
    for (int jj = 0; jj < GRID_SIZE; ++jj) {
      for (int ii = 0; ii < GRID_SIZE; ++ii) {
        final int index = this.mapGridToIndex(ii, jj);

        // Load each Tile and containing Plants
        if (!farmData.isNull(index)) {
          JSONObject tileData = farmData.getJSONObject(index);
          
          this.farm[jj][ii] = new FarmTile(tileData, index);
        } else {
          this.farm[jj][ii] = new FarmTile(index);
        }
      }
    }
  }

  /**
   * Format farm tiles to export as JSON data.
   * 
   * @return farm tiles' contained plants as flattened JSON Array
   */
  JSONArray asJSONArray() {
    JSONArray farmData = new JSONArray();
    for (int jj = 0; jj < GRID_SIZE; ++jj) {
      for (int ii = 0; ii < GRID_SIZE; ++ii) {
        final int index = this.mapGridToIndex(ii, jj);

        // Save each Tile and containing Plants
        JSONObject tile = this.farm[jj][ii].saveTile();
        farmData.setJSONObject(index, tile);
      }
    }
    
    return farmData;
  }

  /**
   * Clear farm of all plants (reset farm to default state).
   */
  void resetFarm(JSONArray farmData) {
    loadFarm(farmData);

    this.endDrag();

    this.drawFarm();
  }

  /**
   * { @return the mouse's x coordinate in the grid... }
   */
  private int mapMouseXToGrid() {
    return floor(map(mouseX, 0, this.farmRender.width, 0, GRID_SIZE));
  }
  /**
   * { @return the mouse's y coordinate in the grid... }
   */
  private int mapMouseYToGrid() {
    return floor(map(mouseY, 0, this.farmRender.height, 0, GRID_SIZE));
  }

  /**
   * { @return index in flattened array from coordinate in the grid... }
   */
  private int mapGridToIndex(int ii, int jj) {
    return jj * GRID_SIZE + ii;
  }
}
