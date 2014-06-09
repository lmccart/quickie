import processing.video.*;
import java.io.FilenameFilter;

int curVid;

// assets
Movie[] clips;
Table[] datas; // pos-f, eng-f, neg-f, pos-m, eng-m, neg-m
PShape menSVG, womenSVG, cannesSVG, eyesSVG;
PImage gradient;
PFont ralewayF, titilliumF;
String[] awardTypes;

// styling
float sc; // scaler, design grid is 1920x1080
color[] genderC = { color(0, 255, 255), color(102, 255, 0) }; // cyan, green
color gridC = color(255, 61, 255);
float textY;
float subtextY;

// debug
boolean showGrid = false;


void setup() {

  size(displayWidth, round(1080.0*displayWidth/1920.0));
  sc = width/1920.0;

  // load list of content directories, choose one
  String contentPath = dataPath("content");
  File file = new File(contentPath); //pend
  String dirs[] = file.list(new FilenameFilter() {
    @Override
      public boolean accept(File current, String name) {
      return new File(current, name).isDirectory();
    }
  }
  );
  println("loaded "+dirs.length+" options");
  
  // load content
  datas = new Table[dirs.length];
  clips = new Movie[dirs.length];
  awardTypes = new String[dirs.length];
  
  for (int i=0; i<dirs.length; i++) {
    String path = contentPath+"/"+dirs[i]+"/";
    clips[i] = new Movie(this, path+"clip.mp4");
    datas[i] = loadTable(path+"data.csv", "header");
    awardTypes[i] = loadStrings(path+"award.txt")[0];
    awardTypes[i] = awardTypes[i].substring(0,1).toUpperCase() + awardTypes[i].substring(1);
  }

  // choose start
  curVid = floor(random(dirs.length));
  println("choosing "+curVid+": "+dirs[curVid]);
  clips[curVid].play();

  // load images
  menSVG = loadShape("Icon_Men.svg");
  womenSVG = loadShape("Icon_Women.svg");
  cannesSVG = loadShape("Logo_CannesLions.svg");
  eyesSVG = loadShape("Logo_Realeyes.svg");
  gradient = loadImage("gradient.png");

  // load fonts
  ralewayF = loadFont("Raleway-Medium-22.vlw");
  titilliumF = loadFont("TitilliumWeb-Light-22.vlw");
  textY = height-265.0*sc;
  subtextY = height-235.0*sc;
}


void draw() {
  noTint();
  image(clips[curVid], 0, 0, width, height);
  tint(255, 255*0.8);
  image(gradient, 0, 0, width, height);
  drawBars();
  drawGraph();
  drawExtras();

  if (showGrid) drawGrid();
  
  if (clips[curVid].time() == clips[curVid].duration()) { 
    curVid = floor(random(clips.length));
    clips[curVid].jump(0);
    clips[curVid].play();
  }
}




/**
 * DRAW PARTS
 **/
 
void drawBars() {

  String[] emotions = { "Positive", "Negative", "Surprise" };

  noStroke();
  float x = 1065.0*sc;
  float w = 80.0*sc;
  float y = height-65.0*sc;
  float maxH = 160.0*sc;
  for (int i=0; i<3; i++) { // pend where's surprise?
    float textX = x+85.0*sc;
    float totalV = 0;

    // emotion label
    setupText(CENTER);
    text(emotions[i], textX, textY);

    for (int j=0; j<2; j++) { // men and women

      float val = getLerpVal(getCol(j, emotions[i]));
      totalV += val;

      fill(genderC[j]);
      float h = maxH*val;
      rect(x, y-h, w, h);
      x += 90.0*sc;
    }

    // percentage label
    setupSubtext(CENTER);
    text(round(totalV*50.0)+"%", textX, subtextY);
  }
}

void drawGraph() {

  strokeWeight(2.5);
  noFill();

  // label
  float x0 = 245.0*sc;
  setupText(LEFT);
  text("Engagement", x0, textY);

  // draw curves
  noFill();
  for (int j=0; j<2; j++) {
    float y0 = 65.0*sc;
    beginShape();
    stroke(genderC[j]);
    curveVertex(x0, height-y0);
    float maxH = 170.0*sc;
    float totalW = 710.0*sc;
    for (int i=0; i<= datas[curVid].getRowCount(); i++) {
      float x = x0 + i*totalW/datas[curVid].getRowCount();
      float y = height - y0 - maxH*datas[curVid].getFloat(min(i, datas[curVid].getRowCount()-1), getCol(j, "Engagement"));
      curveVertex(x, y);
      if (i == datas[curVid].getRowCount()) {
        curveVertex(x, y);
        println("curve x = "+x);
      }
    }
    endShape();

    // draw little circle
    float cX = x0 + clips[curVid].time()*totalW/datas[curVid].getRowCount();
    float cY = height - y0 - maxH*getLerpVal(getCol(j, "Engagement"));
    ellipse(cX, cY, 10*sc, 10*sc);
    println("circle x = "+cX);
  }
}

void drawExtras() {
  
  // EYES - top left
  shape(eyesSVG, 65*sc, 65*sc, 350*sc, 350*sc*eyesSVG.height/eyesSVG.width); 

  // GENDER - bottom left
  setupText(LEFT);
  text("Gender", 65*sc, textY);

  setupSubtext(LEFT);
  shape(menSVG, 65*sc, height-215*sc, 42*sc, 42*sc*menSVG.height/menSVG.width); 
  text("Men", 125*sc, height-172*sc);

  fill(genderC[1]);
  shape(womenSVG, 65*sc, height-135*sc, 42*sc, 42*sc*womenSVG.height/womenSVG.width); 
  text("Women", 125*sc, height-92*sc);


  // CANNES - bottom right
  shape(cannesSVG, 1705*sc, height-195*sc, 130*sc, 130*sc);   
  setupText(CENTER);
  text("Award", 1770*sc, textY);

  setupSubtext(CENTER);
  text(awardTypes[curVid], 1770*sc, subtextY);
}


void drawGrid() {
  pushStyle();
  stroke(gridC);
  strokeWeight(1);
  for (int i=0; i<11; i++) {
    float x = sc*(65.0+i*180.0);
    line(x, 0, x, height);
    if (i > 0 && i < 10) {
      float x2 = x-10.0*sc;
      line(x2, 0, x2, height);
    }
  }
  float y = 65.0*sc;
  line(0, y, width, y);
  y = height - y;
  line(0, y, width, y);
  popStyle();
}

/**
 * HELPERS
 **/
 
int getCol(int gender, String emotion) {
  // 0-male, 1-female
  int col = 0;
  if (emotion == "Positive") {
    col = 0;
  } else if (emotion == "Negative") {
    col = 2;
  } else if (emotion == "Surprise") {
    col = 0; // pend
  } else if (emotion == "Engagement") {
    col = 1;
  }

  if (gender == 0) { // male
    col += 3;
  }

  return col;
}

// uses data in csv to lerp inbetween values based on current playtime
float getLerpVal(int col) {
  int t = floor(clips[curVid].time());
  if (t >= datas[curVid].getRowCount()) {
    t = datas[curVid].getRowCount()-1;
  }
  float val0 = datas[curVid].getFloat(t, col);
  float val1 = val0;
  if (t+1 < datas[curVid].getRowCount()) {
    val1 = datas[curVid].getFloat(t+1, col);
  }
  return lerp(val0, val1, (clips[curVid].time()-t));
}

// 22pt Raleway, cyan
void setupText(int align) {
  textAlign(align);
  textFont(ralewayF);
  textSize(22.0*sc);
  fill(genderC[0]);
}

// 22pt Titillium, cyan
void setupSubtext(int align) {
  textAlign(align);
  textFont(titilliumF);
  textSize(22.0*sc);
  fill(genderC[0]);
}

/**
 * AUTO HELPERS
 **/

// automatically start in fullscreen
boolean sketchFullScreen() {
  return true;
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}

// Toggle grid
void keyPressed() {
  if (key == ' ') {
    showGrid = !showGrid;
  }
}

