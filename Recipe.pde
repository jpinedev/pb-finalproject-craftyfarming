// Recipe for creating new growable items
class Recipe {
  public final String PRODUCT;

  private String[] ingredients;

  Recipe(String id, String[] ingredients) {
    this.PRODUCT = id;
    this.ingredients = ingredients;
  }
}

// Load Recipes from JSON data
void loadRecipes(JSONObject recipes) {
  for (String id : ids) {
    if (recipes.isNull(id)) continue;
    JSONArray recipeData = recipes.getJSONArray(id);

    ArrayList<String> ingredients = new ArrayList<String>();

    for (int ii = 0; ii < recipeData.size(); ++ii) {
      ingredients.add(
        recipeData.getString(ii)
      );
    }

    /* Code snippet from https://www.geeksforgeeks.org/arraylist-array-conversion-java-toarray-methods/ :
        Integer[] arr = new Integer[al.size()];
        arr = al.toArray(arr);
    */
    String[] arr = new String[ingredients.size()];
    arr = ingredients.toArray(arr);

    Recipe recipe = new Recipe(id, arr);

    recipeLibrary.put(id, recipe);
  }
}