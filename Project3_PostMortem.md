## Project 3: Crafty Farmer - Post Mortem
*Jake Pine*

**Preface:**
I did not make a trivia game so I will try to adapt my implementation to the graded criteria. My game is a work in progress, as I intend to continue this for my final project.

### How To Play:
Controls:
- Click on a tile to interact (see *Result of Interacting with Tiles* for details)
- Enter/Return - advance time by one day
- Backspace/Delete - reset farm (must advance time to apply reset)

> Tile States:
> - Soil (light brown)
> - Tilled (light brown with circle of dark brown)
> - Planted (light brown with growing plant over it)
> - Watered (dark brown with growing plant over it)

> Result of Interacting with Tiles:
> - Soil -> Tilled
> - Tilled -> Planted (with a Lettuce plant)
> - Planted -> Watered

**Disclaimer:** *plants must be watered overnight to grow/delay spoiling until ripe*

---

### Code Information Detail:
Criteria:
- Answer 10 or more questions
  - 25 interactable tiles to grow crops on
- The questions and answers must be loaded from an external file
  - All item and recipe data is loaded from `./data.JSON`
- There must be a visual/animation with each question and each answer
  - Many visual states for each tile and different plant stages
- Must use inheritance and 2 subclasses
  - Plant is an extension of Growable that can grow, spoil, and be drawn
- It must keep track of the score
  - Grow plant until ripe
  - Improper care for plant (forgetting to water) will cause premature spoilage
- It must have a way to reset/start the game
  - Clear the whole farm by pressing backspace/delete

Extras:
- Used HashMaps for global resources (eg. item ids, growables, and recipes)
  - global resources fully populated by `./data.JSON`
- Used 2D Array for tile grid
- Loading Farm - Mapping functions from JSON
  - load previous save data from `./farm.JSON`
  - if no previous save data exists, clear farm will be loaded from `./farmDefault.JSON`
- Saving Farm - Mapping functions to JSON
  - advance time to autosave farm

---

### Reflection on Process:
The structure of my code and my data diverged greatly from my original pseudocode outline. The main change in my data structures involved scrapping the idea of action-based recipes (a Recipe used to be a Growable + Action[]). Recipes became a list of ingredients to combine with to make a given item. Despite recipes existing, in the code and in the loaded JSON, I have yet to implement combining ingredients (crafting) or harvesting plants.

I ran into a few issues with the inability in Processing to make static methods in non-static classes, otherwise I would've been able to include the loadX functions inside of the classes themselves as would be necessary with regular Java.

I had a question about what you would recommend for how to interact with JSON data between loading and saving. If my game saves the whole board every night (time advance), does it make sense to have each plant object keep an instance of the corresponding JSONObject and constantly update it? Or does it make more sense to keep it the way I have now with mapping the data for each tile from/to JSON every load/save?