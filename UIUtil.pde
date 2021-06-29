/**
 * { @return mouse is over the compost button... }
 */
boolean overCompost() {
  return (mouseX > 10 && mouseX < 90 && mouseY > 410 && mouseY < 490) && !isGameOver();
}

/**
 * { @return mouse is over the watering can button... }
 */
boolean overWateringCan() {
  return (mouseX > 100 && mouseX < 180 && mouseY > 410 && mouseY < 490) && !isGameOver();
}

/**
 * { @return mouse is over the seed selector... }
 */
boolean overSeedSelector() {
  return (mouseX > 190 && mouseX < 190 + width - 200 && mouseY > 410 && mouseY < 490) && !isGameOver();
}