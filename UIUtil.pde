/**
 * { @return mouse is over the compost button... }
 */
boolean overCompost() {
  return (mouseX > 10 && mouseX < 90 && mouseY > 410 && mouseY < 490);
}

/**
 * { @return mouse is over the watering can button... }
 */
boolean overWateringCan() {
  return (mouseX > 100 && mouseX < 180 && mouseY > 410 && mouseY < 490);
}