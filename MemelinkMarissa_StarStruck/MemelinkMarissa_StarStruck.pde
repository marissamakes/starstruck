import processing.sound.*; // audio library

boolean endGame, alreadyClicked, played;
int score, frame;
int starAmount = 13;  // the amount of stars can be adjusted for more easier/challenging gameplay
int startTime = 30; // count till game actually starts after welcome message
float maxTime = 10*60; // maximum playing time (10 sec * 60 frames p/s)
float margin = 30;
float px, py;

FloatList allXs, allYs; // hard to let the vertices shapes (stars) not overlap. Saw online this could be done by floatlists, and it works :)

SoundFile[] soundFiles = new SoundFile[4]; // all images and soundfiles in array, to initialise and load them all at once at start of the programme
PImage[] allImages = new PImage[5];
Star[] starArr = new Star[starAmount];
int[] xpos = new int[50];
int[] ypos = new int[50];


void setup() {
  loadSoundFiles();
  loadImages();
  fullScreen(); // I like the fullscreen mode, but I'm not sure if Mees is going to kill me..
  frameRate(60);
  allXs=new FloatList();
  allYs=new FloatList();
  intStars();
  soundFiles[0].play();

  // for the smoke of the rocket
  smooth();
  for (int i = 0; i < xpos.length; i++) {
    xpos[i] = 0;
    ypos[i] = 0;
  }
}


void draw() {
  background(0);
  welcome();
  timerFuelBar();
  showStars();
  scoreBoard();
  rocket();
  checkScore();

  if (endGame == false) {
    frame++;
  }
}

void loadSoundFiles() {
  soundFiles[0] = new SoundFile (this, "magic-wand-1.wav");
  soundFiles[1] = new SoundFile (this, "sound39.mp3");
  soundFiles[2] = new SoundFile (this, "round_end.wav");
  soundFiles[3] = new SoundFile (this, "death.wav");
}

void loadImages() {
  allImages[0] = loadImage ("welcome_fuel.png");
  allImages[1] = loadImage("rocket.png");
  allImages[2] = loadImage ("winning.png");
  allImages[3] = loadImage ("losing.png");
  allImages[4] = loadImage("scoreboard.png");
}


void intStars() {

  for (int i = 0; i < starArr.length; i++) {
    starArr[i] = new Star();
    float starDiam = 50;
    boolean overlap = true;

    //placing a star will only happen if there is no overlap
    while (overlap) {   
      overlap = false;
      px = random(starDiam/2, width-starDiam/2);         // saving some borders from the edge of the frame to not place stars on scoreboard or timerFuelBar
      py = random(50 + starDiam/2, height-(starDiam/2)- 20 );
      for (int j=0; j<allXs.size(); j++) {
        float fnx = allXs.get(j);
        float fny = allYs.get(j);

        // checks overlap between current "about to be generated" star and already existing star
        if (dist(fnx, fny, px, py) < starDiam) { 
          overlap = true;
        }
      }
    }
    allXs.append(px);
    allYs.append(py);

    starArr[i].init(px, py, starDiam);
  }
}

// welcome message + explanation. Dissappears after 3 sec
void welcome() {
  imageMode(CENTER);
  if (frame <= startTime) {
    allImages[0].resize(width, 0);
    image(allImages[0], width/2, height/2);
  }
}

// timer/fuel bar visualising time passing
void timerFuelBar() {
  if (endGame == false) {
    if (frame > startTime) {

      float barWidth = -1*((width/2) - ((width/2 * frame)/ (600))) ;   // rectangle's width/length getting smaller with every frame rate
      color c;
      if (frame + startTime < maxTime/3 ) {          // changing colour in three steps
        c = color(0, 255, 0);                        // green colour
      } else if (frame + startTime >= maxTime/3 && frame + startTime <= maxTime/3*2) {
        c = color(225, 150, 0);                     // orange colour
      } else { 
        c = color(255, 0, 0);                        // red colour
      }

      fill(c); 
      rect(width - margin, height - margin, barWidth, -20 );
    }
  }
}

void rocket() {
  // smoke effect of the rocket
  for (int i = 0; i < xpos.length -1; i++) {
    xpos[i] = xpos[i+1];
    ypos[i] = ypos[i+1];
  }

  xpos[xpos.length-1] = mouseX;
  ypos[ypos.length-1] = mouseY;

  for (int i = 0; i < xpos.length; i++) {
    noStroke();
    fill(255-i*5);
    ellipse(xpos[i], ypos[i], i, i);
  }

  imageMode(CENTER);
  allImages[1].resize(80, 80);
  image(allImages[1], mouseX, mouseY);
}

// to actually display the stars
void showStars() {
  if (frame > startTime) {
    for (int i = 0; i < starArr.length; i++) {
      starArr[i].display();
    }
  }
}

// displaying the current score
void scoreBoard() {
  if (frame > startTime) {
    imageMode(CORNER);
    image(allImages[4], margin, margin);
    fill(0);
    textSize(30);
    text(score, allImages[4].width - (margin + 10), allImages[4].height + (margin/2)); // used margin again to position text correctly in the scoreboard bar
  }
}

// checks what's the status, and if the game is won or lost
void checkScore() {
  if (score == starAmount && frame < maxTime) {
    win();
  } else if (score < starAmount && frame > maxTime) {
    lose();
  }
}


void mousePressed() {
  if (endGame == false) {
    for (int i = 0; i < starArr.length; i++) {
      if (starArr[i].alreadyClicked == false) { // to prevent from score being added if a star is already clicked on
        // checks collision/if mouse is touching a star at moment of clicking
        if (dist(starArr[i].starX, starArr[i].starY, mouseX, mouseY) < starArr[i].starDiam/2) {
          starArr[i].changeColor();
          starArr[i].alreadyClicked = true; 
          score ++;
          println(score);
          soundFiles[1].play();
        }
      }
    }
  }
}


void win() {

  allImages[2].resize(width, 0);
  image(allImages[2], width/2, height/2);
  endGame = true;
  if (!played) { // to only let audio play once!
    soundFiles[2].play();
    played = true;
  }
}

void lose() {

  allImages[3].resize(width, 0);
  image(allImages[3], width/2, height/2);
  endGame = true;
  if (!played) { // to only let audio play once!
    soundFiles[3].play();
    played = true;
  }
}

void keyPressed() {
  if (key == ' ' && endGame) {
    resetGame();
  }
}

// to reset the game back to 0 values, to start over again
void resetGame() {
  frame = 0;
  score = 0;
  endGame = false;
  alreadyClicked = false;
  played = false;
  setup(); // I didn't knew this was possible, calling setup in a function! Feels a bit tricky, but it keeps on working n_n
}
