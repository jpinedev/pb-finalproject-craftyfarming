/**
 * Recipe for combining items to create new growable items.
 */
class Recipe {
  public final String PRODUCT;
  
  private HashSet<String> ingredients;

  /**
   * Create a crafting recipe.
   */
  private Recipe(String id, ArrayList<String> _ingredients) {
    this.PRODUCT = id;
    this.ingredients = new HashSet<String>(_ingredients);
  }

  /**
   * Recipe requires given ingredient.
   * 
   * @param id itemId of the ingredient
   * 
   * @return recipe requires ingredient
   */
  boolean needsIngredient(String id) {
    return this.ingredients.contains(id);
  }
}

/**
 * Load Recipes from JSON data and populate recipe book.
 * 
 * @param recipesData json object to be mapped
 */
void loadRecipes(JSONObject recipesData) {
  for (String id : ids) {
    if (recipesData.isNull(id)) continue;
    JSONArray recipeData = recipesData.getJSONArray(id);

    ArrayList<String> ingredients = new ArrayList<String>();

    for (int ii = 0; ii < recipeData.size(); ++ii) {
      ingredients.add(
        recipeData.getString(ii)
      );
    }

    Recipe recipe = new Recipe(id, ingredients);

    recipeBook.put(id, recipe);
  }
}

/**
 * Find recipes that contain all the given ingredients.
 * 
 * @param _ingredients in potential recipes
 * 
 * @return recipes that contain all ingredients
 */
HashSet<String> findRecipes(String... _ingredients) {
  HashSet<String> recipes = new HashSet<String>();
  
  for (Recipe recipe : recipeBook.values()) {
    boolean containsAll = true;
    
    for (int index = 0; index < _ingredients.length && containsAll; ++index)
      if (!recipe.needsIngredient(_ingredients[index]))
        containsAll = false;
    
    if (containsAll) recipes.add(recipe.PRODUCT);
  }
  
  return recipes;
}
