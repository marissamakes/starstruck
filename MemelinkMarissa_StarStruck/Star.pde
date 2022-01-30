class Star {
  color starC;
  float starX, starY;
  float starDiam = 50;
  boolean alreadyClicked;


  Star() {
    starX = random(0 + starDiam, width - starDiam);
    starY = random(0 + starDiam, height - starDiam);
    starC = color(255, 255, random(30, 200), 200);
  }

  void init(float xinit, float yinit, float dinit) {
    starX = xinit;
    starY = yinit;
    starDiam = dinit;
  }

  void display() {
    smooth();
    noStroke();
    fill(starC);

// yes, this was a bit of a pain in the ass. But wanted to try to draw vertices, and use them instead of images!
    beginShape();
    vertex(starX, starY-starDiam);
    vertex(starX+14, starY-20);
    vertex(starX+47, starY-15);
    vertex(starX+23, starY+7);
    vertex(starX+29, starY+40);
    vertex(starX, starY+25);
    vertex(starX-29, starY+40);
    vertex(starX-23, starY+7);
    vertex(starX-47, starY-15);
    vertex(starX-14, starY-20);
    endShape(CLOSE);
  }

  void changeColor() {
    starC = color(100, 180, 0); // star changes to green star, if clicked on
  }
}
