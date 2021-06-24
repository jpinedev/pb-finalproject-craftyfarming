import java.util.Map;

/**
 * Structure for a Growable Item.
 */
class Growable {
  // Item Information
  public final String itemId;
  public final String itemName;

  // Item Stats
  protected final int growthTime;
  protected final int spoilTime;

  /**
   * Create a new growable item with the given stats.
   * 
   * @param _itemId
   * @param _itemName
   * @param _growthTime in in-game days
   * @param _spoilTime in in-game days
   */
  public Growable(String _itemId, String _itemName, int _growthTime, int _spoilTime) {
    this.itemId = _itemId;
    this.itemName = _itemName;
    this.growthTime = _growthTime;
    this.spoilTime = _spoilTime;
  }

  /**
   * Create another instance of a growable with the same stats.
   * 
   * @param _item to copy
   */
  protected Growable(Growable _item) {
    this(_item.itemId, _item.itemName, _item.growthTime, _item.spoilTime);
  }
  
  /**
   * Average the growth times of this and another growable.
   * 
   * @param _growable to be averaged with
   * 
   * @return average growth time
   */
  public float getAvgGrowthTime(Growable _growable) {
    float numer = this.growthTime + _growable.growthTime;
    return numer / 2f;
  }
  /**
   * Average the spoil times of this and another growable.
   * 
   * @param _growable to be averaged with
   * 
   * @return average spoil time
   */
  public float getAvgSpoilTime(Growable _growable) {
    float numer = this.spoilTime + _growable.spoilTime;
    return numer / 2f;
  }

}

/**
 * Load growable items from JSON data and populate item dictionary.
 * 
 * @param items to be indexed
 */ 
void loadGrowables(JSONObject items) {
  for (String id : ids) {
    JSONObject itemData = items.getJSONObject(id);

    Growable item = new Growable(
      id,
      itemData.getString("name"),
      itemData.getInt("growthTime"),
      itemData.getInt("spoilTime")
    );

    itemDictionary.put(id, item);
  }
}
