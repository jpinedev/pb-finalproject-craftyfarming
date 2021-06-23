enum FarmlandState {
  Soil,
  Tilled,
  Planted,
  Watered
};

// A container for a growable item to be planted 
class FarmTile {
  // Array Positional information
  public final int index;

  // Tile state information
  private FarmlandState state;
  private Plant item;
  
  private FarmTile(int _index, Plant _item) {
    this.index = _index;

    this.setPlant(_item);
  }

  public FarmTile(int _index) {
    this(_index, null);
  }

  // Export Tile as JSON
  public JSONObject saveTile() {
    if (null == this.item) return null;
    return this.item.savePlant();
  }
  
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
  
  // Set contained planted item
  public void setPlant(Plant plant) {
    this.state = (null == plant ? FarmlandState.Soil : FarmlandState.Planted);
    this.item = plant;
  }

  public boolean hasPlant() {
    return this.state == FarmlandState.Planted || this.state == FarmlandState.Watered;
  }
  public boolean hasBadPlant() {
    return this.hasPlant() && this.item.isBad();
  }

  public boolean isTilled() {
    return this.state == FarmlandState.Tilled;
  }

  public Plant transplant() {
    Plant temp = this.item;
    this.item = null;
    
    this.state = FarmlandState.Tilled;
    
    return temp;
  }
  
  public HashSet<String> getSharedRecipes(String itemId) {
    if (!this.hasPlant()) return new HashSet<String>();
    return findRecipes(this.item.itemId, itemId);
  }
  
  // Advance age of contained plant by one day
  public void ageUp() {
    if (null != this.item) this.item.ageUp(this.state == FarmlandState.Planted);

    if (this.state == FarmlandState.Tilled) this.state = FarmlandState.Soil; 
    else if (this.state == FarmlandState.Watered) this.state = FarmlandState.Planted;
  }
  
  // Determine what effect the player had on the tile based on the current state
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

  public void waterPlant() {
    if (this.hasPlant()) this.state = FarmlandState.Watered;
  }
}

// Create FarmTile from JSON data
FarmTile loadFarmTile(JSONObject tileData, int index) {
  Plant _item = loadPlant(tileData);
  return new FarmTile(index, _item);
}
