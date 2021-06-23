// Recipe for creating new growable items
class Recipe {
  public final String PRODUCT;
  
  private HashSet<String> ingredients;

  Recipe(String id, ArrayList<String> _ingredients) {
    this.PRODUCT = id;
    this.ingredients = new HashSet<String>(_ingredients);
  }

  boolean needsIngredient(String id) {
    return this.ingredients.contains(id);
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

    Recipe recipe = new Recipe(id, ingredients);

    recipeLibrary.put(id, recipe);
  }
}

HashSet<String> findRecipes(String... _ingredients) {
  HashSet<String> recipes = new HashSet<String>();
  
  for (Recipe recipe : recipeLibrary.values()) {
    boolean containsAll = true;
    
    for (int index = 0; index < _ingredients.length && containsAll; ++index)
      if (!recipe.needsIngredient(_ingredients[index]))
        containsAll = false;
    
    if (containsAll) recipes.add(recipe.PRODUCT);
  }
  
  return recipes;
}
