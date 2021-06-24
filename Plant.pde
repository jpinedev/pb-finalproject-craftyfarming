/**
 * An instance of a Growable item with age/decay.
 */
final class Plant extends Growable {

  // Drawing Constants
  private final color SPROUTING = color(#38d14f);
  private final color SPOILED = color(#2e2720);

  // Plant age/decay information
  private int growthStage;
  private int spoilStage;

  /**
   * Create a plant with previous age information.
   * 
   * @param _item to be modeled after
   * @param _growthStage of the new plant
   * @param _spoilStage of the new plant
   */
  Plant(Growable _item, int _growthStage, int _spoilStage) {
    super(_item);

    this.growthStage = (_growthStage > this.growthTime ? this.growthTime : _growthStage);
    this.spoilStage = (_spoilStage > this.spoilTime ? this.spoilTime : _spoilStage);
  }

  /**
   * Create a new plant.
   * 
   * @param _item to be modeled after
   */
  Plant(Growable _item) {
    super(_item);

    this.growthStage = 0;
    this.spoilStage = 0;
  }

  /**
   * Format plant for export as JSON data.
   * 
   * @return plant status data
   */
  public JSONObject savePlant() {
    JSONObject plantData = new JSONObject();

    plantData.setString("growable", this.itemId);
    plantData.setInt("growthStage", this.growthStage);
    plantData.setInt("spoilStage", this.spoilStage);

    return plantData;
  }

  /**
   * { @return plant is fully grown and ready for harvest... }
   */
  public boolean isReady() { return this.growthStage == this.growthTime && !this.isBad(); }
  /**
   * { @return plant is completely spoiled... }
   */
  public boolean isBad() { return this.spoilStage == this.spoilTime; }

  /**
   * Advance age of plant by one day.
   * 
   * @param spoil if the plant should spoil instead of ripening
   */
  public void ageUp(boolean spoil) {
    if (spoil) this.spoilUp();
    else {
      if (this.growthStage < this.growthTime) this.growUp();
      else this.spoilUp();
    }
  }

  /**
   * Ripen plant by one day.
   */
  public void growUp() {
    ++this.growthStage;
  }

  /**
   * Spoil plant by one day.
   */
  public void spoilUp() {
    if (this.spoilStage < this.spoilTime) ++this.spoilStage;
  }
  
  /**
   * Average the growth stage of this and another plant.
   * 
   * @param _plant to be averaged with
   * 
   * @return average growth stage
   */
  public float getAvgGrowthStage(Plant _plant) {
    float numer = this.growthStage + _plant.growthStage;
    return numer / 2f;
  }
  /**
   * Average the spoil stage of this and another plant.
   * 
   * @param _plant to be averaged with
   * 
   * @return average spoil stage
   */
  public float getAvgSpoilStage(Plant _plant) {
    float numer = this.spoilStage + _plant.spoilStage;
    return numer / 2f;
  }
  
  /**
   * { @return display name of plant... }
   */
  public String getName() {
    return (this.isBad() ? "Spoiled\n" : "") + this.itemName;
  }
  
  /**
   * Draw plant at corresponding position on the given graphics object.
   * 
   * @param pg graphic to be drawn on
   * @param ii column in grid
   * @param jj row in grid
   */
  public void draw(PGraphics pg, int ii, int jj) {
    // Determine height of rect based on plant age
    float growthPerc = (float) this.growthStage / (float) this.growthTime;
    float h = growthPerc * GRID_SCALE;
    float rectOffset = GRID_SCALE - h;
    float textOffset = rectOffset;

    // Determine fill color based on plant spoil state
    if (this.isBad()) {
      pg.fill(this.SPOILED);
      h = GRID_SCALE;
      rectOffset = GRID_SCALE - h;
      textOffset = rectOffset + 16;
    } else if (this.spoilStage > 0) {
      float spoiledPerc = (float) this.spoilStage / (float) this.spoilTime;
      
      float r = map(spoiledPerc, 0, 1, red(this.SPROUTING), red(this.SPOILED));
      float g = map(spoiledPerc, 0, 1, green(this.SPROUTING), green(this.SPOILED));
      float b = map(spoiledPerc, 0, 1, blue(this.SPROUTING), blue(this.SPOILED));
      
      pg.fill(r, g, b);
    }
    else pg.fill(this.SPROUTING);
    
    pg.rect(ii * GRID_SCALE, jj * GRID_SCALE + rectOffset, GRID_SCALE, h);

    pg.fill(#ffffff);
    pg.text(this.getName(), (ii + 0.5f) * GRID_SCALE, jj * GRID_SCALE + textOffset);
  }
}

/**
 * Load plant from JSON save data.
 * 
 * @param plantData as JSON data
 * 
 * @return corresponding plant
 */
Plant loadPlant(JSONObject plantData) {
  if (plantData.isNull("growable")) return null;

  String growableKey = plantData.getString("growable");
  Growable _growable = itemDictionary.get(growableKey);
  
  return new Plant(_growable, plantData.getInt("growthStage"), plantData.getInt("spoilStage"));
}
