/**
 * Represents the current state of a farmland tile.
 */
enum FarmlandState {
  Soil,
  Tilled,
  Planted,
  Watered
};

/**
 * A container for planting and growing items.
 */
class FarmTile {

  // Array Positional information
  public final int index;

  // Tile state information
  private FarmlandState state;
  private Plant item;
  
  /**
   * Create a farm tile for planting.
   * 
   * @param _index in flattened array 
   * @param _item to be planted (if any)
   */
  private FarmTile(int _index, Plant _item) {
    this.index = _index;

    this.setPlant(_item);
  }

  /**
   * Create a farm tile for planting.
   * 
   * @param _index in flattened array 
   */
  public FarmTile(int _index) {
    this(_index, null);
  }
  
  /**
   * Create a farm tile from JSON data
   * 
   * @param tileData as JSON data
   * @param _index in flattened array 
   */
  public FarmTile(JSONObject tileData, int _index) {
    this(_index, loadPlant(tileData));
  }

  /**
   * Format tile for export as JSON data.
   * 
   * @return contained plant data
   */
  public JSONObject saveTile() {
    if (null == this.item) return null;
    return this.item.savePlant();
  }
  
  /**
   * Draw farm tile at corresponding position on the given graphics object.
   * 
   * @param pg graphic to be drawn on
   * @param ii column in grid
   * @param jj row in grid
   */
  public void draw(PGraphics pg, int ii, int jj) {
    pg.noStroke();
    pg.ellipseMode(CORNER);

    // Draw farmland depending on state
    switch (this.state) {
      case Tilled:
        pg.fill(#6b5640);
        pg.rect(ii * GRID_SCALE, jj * GRID_SCALE, GRID_SCALE, GRID_SCALE);
        pg.fill(#402b14);
        pg.ellipse(ii * GRID_SCALE, jj * GRID_SCALE, GRID_SCALE, GRID_SCALE);
        break;
      case Watered:
        pg.fill(#402b14);
        pg.rect(ii * GRID_SCALE, jj * GRID_SCALE, GRID_SCALE, GRID_SCALE);
        break;

      case Planted:
      case Soil:
      default:
        pg.fill(#6b5640);
        pg.rect(ii * GRID_SCALE, jj * GRID_SCALE, GRID_SCALE, GRID_SCALE);
    }

    if (this.state == FarmlandState.Planted || this.state == FarmlandState.Watered) {
      this.item.draw(pg, ii, jj);
    }
  }
  
  /**
   * Set contained planted item.
   * 
   * @param plant to be planted
   */
  public void setPlant(Plant plant) {
    this.state = (null == plant ? FarmlandState.Soil : FarmlandState.Planted);
    this.item = plant;
  }

  /**
   * { @return tile is tilled... }
   */
  public boolean isTilled() {
    return this.state == FarmlandState.Tilled;
  }
  /**
   * { @return tile is watered... }
   */
  public boolean isWatered() {
    return this.state == FarmlandState.Watered;
  }

  /**
   * { @return tile has a plant... }
   */
  public boolean hasPlant() {
    return this.state == FarmlandState.Planted || this.isWatered();
  }
  /**
   * { @return tile has a ripe plant... }
   */
  public boolean hasRipePlant() {
    return this.hasPlant() && this.item.isReady();
  }
  /**
   * { @return tile has a spoiled plant... }
   */
  public boolean hasBadPlant() {
    return this.hasPlant() && this.item.isBad();
  }

  /**
   * Remove the contained plant from the tile.
   * 
   * @return removed plant
   */
  public Plant transplant() {
    Plant temp = this.item;
    this.item = null;
    
    this.state = FarmlandState.Tilled;
    
    return temp;
  }
  
  /**
   * Get all recipies that the contained and given item share.
   * 
   * @param itemId item to be indexed
   */
  public HashSet<String> getSharedRecipes(String itemId) {
    if (!this.hasPlant()) return new HashSet<String>();
    return findRecipes(this.item.itemId, itemId);
  }
  
  /**
   * Advance the state of the tile and any contained item.
   */
  public void ageUp() {
    if (null != this.item) this.item.ageUp(this.state == FarmlandState.Planted);

    if (this.state == FarmlandState.Tilled) this.state = FarmlandState.Soil; 
    else if (this.state == FarmlandState.Watered) this.state = FarmlandState.Planted;
  }
  
  /**
   * Determine what effect the player had on the tile based on the current state.
   * 
   * @param g growable to be planted (if possible)
   * @param wateringCan if the watering can is currently equipped
   */
  public void nextState(Growable g, boolean wateringCan) {
    switch (this.state) {
      case Soil:
        this.state = FarmlandState.Tilled;
        break;
      case Tilled:
        this.setPlant(new Plant(g));
        break;
      case Planted:
        // Only water plants while watering can is equipped
        if (wateringCan) this.waterPlant();
        break;
      case Watered:
        break;
      default:
        this.state = FarmlandState.Soil;
    }
  }

  /**
   * Water the tile for any contained plant.
   */
  public void waterPlant() {
    if (this.hasPlant()) this.state = FarmlandState.Watered;
  }
}
