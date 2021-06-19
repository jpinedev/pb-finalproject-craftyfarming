import java.util.Map;

// Structure for a Growable Item
class Growable {
  // Item Information
  public final String itemId;
  public final String itemName;

  // Item Stats
  protected final int growthTime;
  protected final int spoilTime;

  public Growable(String _itemId, String _itemName, int _growthTime, int _spoilTime) {
    this.itemId = _itemId;
    this.itemName = _itemName;
    this.growthTime = _growthTime;
    this.spoilTime = _spoilTime;
  }

  protected Growable(Growable _item) {
    this(_item.itemId, _item.itemName, _item.growthTime, _item.spoilTime);
  }

}

// Load Growable Items
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
