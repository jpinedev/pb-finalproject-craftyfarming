/**
 * Recipe for combining items to create new growable items.
 */
class Recipe {
  public final String PRODUCT;
  
  private SortedSet<String> ingredients;

  /**
   * Create a crafting recipe.
   * 
   * @param id itemId of the product
   * @param _ingredients as JSON
   */
  private Recipe(String id, JSONArray _ingredients) {
    this.PRODUCT = id;
    this.ingredients = new TreeSet(fromJSONArray(_ingredients));
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

  /**
   * { @return recipe ingredients... }
   */
  List<String> getIngredients() {
    List<String> _sortedIngredients = new ArrayList(this.ingredients);
    return _sortedIngredients;
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

    Recipe recipe = new Recipe(id, recipeData);

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
SortedSet<String> findRecipes(String... _ingredients) {
  List<String> ingredients = new ArrayList<String>(Arrays.asList(_ingredients));
  Collections.sort(ingredients);

  SortedSet<String> recipes = new TreeSet<String>();
  
  for (Recipe recipe : recipeBook.values()) {
    List<String> recipeIngredients = new ArrayList(recipe.getIngredients());

    boolean containsAll = (ingredients.size() == recipeIngredients.size());

    for (int index = 0; index < ingredients.size() && containsAll; ++index)
      if (!recipeIngredients.get(index).equals(ingredients.get(index)))
        containsAll = false;
    
    if (containsAll) recipes.add(recipe.PRODUCT);
  }
  
  return recipes;
}
