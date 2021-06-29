String seedDetails = "";

void initPlantpedia() {
  int pX = GRID_SCALE / 2, pY = GRID_SCALE / 2;
  int pWidth = GRID_SCALE * 4, pHeight = GRID_SCALE * 4;
  
  int spacerSM = 5;
  int spacerMD = 10;
  int spacerLG = 20;


  pediaPanel = new GPanel(this, pX, pY, pWidth, pHeight, "Plantpedia");
  pediaPanel.setOpaque(true);
  pediaPanel.setCollapsed(false);
  pediaPanel.setDraggable(false);
  pediaPanel.setCollapsible(false);

  int slsWidth = pWidth / 3 - spacerSM;
  seedListSidebar = new GPanel(this, spacerMD, spacerLG + spacerMD, slsWidth, pHeight - (spacerLG * 2), "Seeds:");
  seedListSidebar.setVisible(true);
  seedListSidebar.setOpaque(true);
  seedListSidebar.setCollapsed(false);
  seedListSidebar.setDraggable(false);
  seedListSidebar.setCollapsible(false);
  
  seedListGroup = new GToggleGroup();
  seedList = new ArrayList<GOption>();

  int index = 0;
  ArrayList<Growable> _seeds = new ArrayList<Growable>(itemDictionary.values());
  Collections.sort(_seeds);
  for (Growable _seed : _seeds) {
    GOption seedOption = new GOption(this, spacerSM, spacerLG + spacerLG * (index++), slsWidth - spacerMD, spacerLG);
    seedOption.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
    seedOption.setText(_seed.itemName);
    seedOption.tag = _seed.itemId;
    seedList.add(seedOption);

    seedListGroup.addControl(seedList.get(index - 1));
    seedListSidebar.addControl(seedList.get(index - 1));
  }

  pediaPanel.addControl(seedListSidebar);

  int sspWidth = (2 * pWidth / 3) - (spacerLG + spacerSM);
  int sspHeight = pHeight - (spacerLG * 2);
  selectedSeedPanel = new GPanel(this, pWidth / 3 + spacerMD + spacerSM, spacerLG + spacerMD, sspWidth, sspHeight);
  selectedSeedPanel.setVisible(false);
  selectedSeedPanel.setOpaque(true);
  selectedSeedPanel.setCollapsed(false);
  selectedSeedPanel.setDraggable(false);
  selectedSeedPanel.setCollapsible(false);

  selectedSeedGrowth = new GLabel(this, spacerMD, spacerLG, sspWidth - spacerMD * 2, spacerLG, "Growth Time: ");
  selectedSeedSpoil = new GLabel(this, spacerMD, spacerLG * 2, sspWidth - spacerMD * 2, spacerLG, "Spoil Time: ");
  selectedSeedIsBase = new GCheckbox(this, spacerMD, spacerLG * 3, sspWidth - spacerMD * 2, spacerLG, "Base Level Crafting Seed");
  selectedSeedIsBase.setEnabled(false);

  int ssrWidth = sspWidth - spacerMD * 2;
  selectedSeedRecipe = new GPanel(this, spacerMD, spacerLG * 4, ssrWidth, spacerLG * 4, "Recipe:");
  selectedSeedRecipeItems = new GLabel(this, spacerMD, spacerLG, ssrWidth - spacerMD * 2, spacerLG);

  selectedSeedRecipe.addControl(selectedSeedRecipeItems);

  selectedSeedPanel.addControl(selectedSeedGrowth);
  selectedSeedPanel.addControl(selectedSeedSpoil);
  selectedSeedPanel.addControl(selectedSeedIsBase);
  selectedSeedPanel.addControl(selectedSeedRecipe);

  pediaPanel.addControl(selectedSeedPanel);
  
  pediaPanel.setLocalColorScheme(1, true);
  pediaPanel.setVisible(false);
}

void selectPediaSeed() {
  if (!itemDictionary.containsKey(seedDetails)) return;
  
  Growable _seed = itemDictionary.get(seedDetails);
  boolean hasRecipe = recipeBook.containsKey(_seed.itemId);

  selectedSeedPanel.setText(_seed.itemName);

  if (!availableSeeds.contains(_seed)) {
    selectedSeedGrowth.setText("Unlock seed to learn more...");
    selectedSeedSpoil.setVisible(false);
    selectedSeedIsBase.setVisible(false);
    selectedSeedRecipe.setVisible(false);
  } else if (!grownPlants.contains(_seed.itemId)) {
    selectedSeedGrowth.setText("Harvest plant to learn more...");
    selectedSeedSpoil.setVisible(false);
    selectedSeedIsBase.setVisible(false);
    selectedSeedRecipe.setVisible(false);
  } else {
    selectedSeedGrowth.setText("Growth Time: " + _seed.growthTime + (_seed.growthTime == 1 ? " day":" days"));
    selectedSeedSpoil.setText("Spoil Time: " + _seed.spoilTime + (_seed.spoilTime == 1 ? " day":" days"));
    selectedSeedSpoil.setVisible(true);
    selectedSeedIsBase.setSelected(!hasRecipe);
    selectedSeedRecipe.setVisible(hasRecipe);
    if (hasRecipe) {
      List<String> _ingredients = new ArrayList<String>(recipeBook.get(_seed.itemId).getIngredients());
      Growable _ingredient0 = itemDictionary.get(_ingredients.get(0));
      Growable _ingredient1 = itemDictionary.get(_ingredients.get(1));
      String _recipe = _ingredient0.itemName + " + " + _ingredient1.itemName;
      selectedSeedRecipeItems.setText(_recipe);
      selectedSeedIsBase.setVisible(false);
    } else {
      selectedSeedRecipeItems.setText("");
      selectedSeedIsBase.setVisible(true);
    }
  }

  selectedSeedPanel.setVisible(true);
}

void openPediaPanel() {
  selectPediaSeed();
  pediaPanel.setVisible(true);
}

public void handleToggleControlEvents(GToggleControl option, GEvent event) {
  if (event.getType().equals("SELECTED")) {
    seedDetails = option.tag;
    selectPediaSeed();
  }
}
