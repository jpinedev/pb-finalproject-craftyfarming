# Crafty Farmer
## Project Description
Plant fruits, vegetables, and ...meat?

How you grow your plants matters; take steps to process the food before it finishes growing. Eg. when growing wheat, if you crush it, it will turn into flower.

Combine two plants by dragging one on the other.

Choose to harvest the item in it's intermediate state or continue crafting.

Unlock access to new seeds (ingredient checkpoints), to make longer recipies easier.

Goal: Grow all food items in the game.
Keep an encyclopedia of all successfully grown foods (shows progress until completion)


## How To Play:
> #### Alert:
> Some controls and features listed below are not yet implemented.

#### Controls:
- Select active tool using mouse
- Select seed to plant with left and right arrow keys
- Click on a tile to interact (see *[Result of Interacting with Tiles](#result-of-interacting-with-tiles)* for details)
- Click and Drag plants onto each other to craft
- Enter/Return - advance time by one day
- Backspace/Delete - reset farm (must advance time to apply reset)

> ###### Tile States:
> - Soil (light brown)
> - Tilled (light brown with circle of dark brown)
> - Planted (light brown with growing plant over it)
> - Watered (dark brown with growing plant over it)

> ###### Result of Interacting with Tiles:
> - Soil -> Tilled
> - Tilled + Growable -> Planted
> - Planted + Watering Can -> Watered
> - Planted (ready to harvest) -> Soil

#### Disclaimer:
*Plants must be watered overnight to grow/delay spoiling until ripe.*


## Roadmap:
#### HIGH PRIORITY
- [x] Choose what growable to Plant
- [x] Craft new growables by dragging one plant onto another
- [x] Ability to compost any Plants
- [ ] Harvest Plants
#### medium priority
- [ ] Unlock access new seeds
- [x] Tool selecting (watering can; compost)
- [ ] Keep an encyclopedia (with UI) of all successfully grown Growables (shows progress until completion)
#### low priority
- [ ] Plants have grace period before starting to spoil
- [ ] Plant visuals overhaul
#### *extras*
- [ ] Title Screen
- [ ] Multi-plant recipes
- [x] Transplant into Tilled Soil
###### *daydreaming...*
- [ ] analyze crafted seeds to learn/record what you created