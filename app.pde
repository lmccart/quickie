import processing.video.*;
import java.io.FilenameFilter;

// assets
Movie clip;
Table data; // pos-f, eng-f, neg-f, pos-m, eng-m, neg-m
PShape menSVG, womenSVG, cannesSVG, eyesSVG;
PFont ralewayF, titilliumF;

// styling
float sc = 1280.0/1920.0; // scaler bc grid is 1920x1080 but vids are 1280x720?
color[] genderC = { 
  color(0, 255, 255), color(102, 255, 0)
};
color gridC = color(255, 61, 255);
float textY;
float subtextY;


void setup() {

  size(1280, 720);


  // load list of content directories, choose one
  println(System.getProperty("user.dir"));
  String rootDir = "/Users/lmccart/Documents/quickie/app/data/content/";
  File file = new File(rootDir); //pend
  String dirs[] = file.list(new FilenameFilter() {
    @Override
      public boolean accept(File current, String name) {
      return new File(current, name).isDirectory();
    }
  }
  );
  println("loaded "+dirs.length+" options");
  int i = floor(random(dirs.length));
  println("choosing "+i+": "+dirs[i]);

  // load content
  String path = rootDir+dirs[i]+"/";
  clip = new Movie(this, path+"clip.mp4");
  clip.loop();
  data = loadTable(path+"data.csv", "header");

  // load images
  menSVG = loadShape("Icon_Men.svg");
  womenSVG = loadShape("Icon_Women.svg");
  cannesSVG = loadShape("Logo_CannesLions.svg");
  eyesSVG = loadShape("Logo_Realeyes.svg");
  
  // load fonts
  ralewayF = loadFont("Raleway-Medium-22.vlw");
  titilliumF = loadFont("TitilliumWeb-Light-22.vlw");
  textY = height-265.0*sc;
  subtextY = height-235.0*sc;
  
  println(data.getRowCount() + " total rows in table"); 

}


void draw() {
  image(clip, 0, 0, width, height);
  drawBars();
  drawGraph();
  drawExtras();
  
  
  drawGrid();
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
  println("t2 "+clip.time());
}

void drawBars() {
  noStroke();
  float x = 1065.0*sc;
  float w = 80.0*sc;
  float y = height-65.0*sc;
  float maxH = 160.0*sc;
  for (int i=0; i<3; i++) { // pend where's surprise?
    for (int j=0; j<2; j++) { // men and women
      fill(genderC[j]);
      float h = maxH*getVal(getCol(j, i));
      rect(x, y-h, w, h);
      x += 90.0*sc;
    }
  }
}

void drawGraph() {
  
  strokeWeight(2.5);
  noFill();
  
  // draw curves
  for (int j=0; j<2; j++) {
    beginShape();
    stroke(genderC[j]);
    float y0 = 65.0*sc;
    float x0 = 245.0*sc;
    curveVertex(x0, height-y0);
    float maxH = 170.0*sc;
    float totalW = 710.0*sc;
    for (int i=0; i<data.getRowCount(); i++) {
       float x = x0 + i*totalW/data.getRowCount();
       float y = height - y0 - maxH*data.getFloat(i, getCol(j, 3));
       curveVertex(x, y);
    }
    endShape();
    
    // draw little circle
    float cX = x0 + clip.time()*totalW/data.getRowCount();
    float cY = height - y0 - maxH*getVal(getCol(j, 3));
    ellipse(cX, cY, 10, 10);
  }
}

void drawExtras() {
  shape(eyesSVG, 65*sc, 65*sc, 350*sc, 350*sc*eyesSVG.height/eyesSVG.width); 
  
  

  
  // gender - bottom left
  textAlign(LEFT);
  
  textFont(ralewayF);
  textSize(22.0*sc);
  fill(genderC[0]);
  text("Gender", 65*sc, textY);
  
  textFont(titilliumF);
  textSize(22.0*sc);
  
  shape(menSVG, 65*sc, height-195*sc, 130*sc, 130*sc); 
  text("Men", 65*sc, height-195*sc);
  fill(genderC[1]);
  shape(womenSVG, 65*sc, height-195*sc, 130*sc, 130*sc); 
  text("Women", 65*sc, height-195*sc);
  
  
  // cannes - bottom right
  fill(genderC[0]);
  shape(cannesSVG, 1705*sc, height-195*sc, 130*sc, 130*sc); 
  textAlign(CENTER);
  text("Award", 1770*sc, textY);
  
  textFont(titilliumF);
  textSize(22.0*sc);
  fill(genderC[0]);
  textAlign(CENTER);
  text("Gold", 1770*sc, subtextY);
}

int getCol(int gender, int emotion) {
  // 0-male, 1-female
  int col = 0;
  switch(emotion) {
    case 0: // positive
      col = 0;
      break;     
    case 1: // negative
      col = 2;
      break;
    case 2: // surprise
      col = 0; // pend
      break;
    case 3: // engagment
      col = 1;
      break;
  }
  
  if (gender == 0) { // male
    col += 3; 
  }
  
  return col;
}

float getVal(int col) {
  int t = floor(clip.time());
  if (t >= data.getRowCount()) {
    t = data.getRowCount()-1;
  }
  float val0 = data.getFloat(t, col);
  float val1 = val0;
  if (t+1 < data.getRowCount()) {
    val1 = data.getFloat(t+1, col);
  }
  return lerp(val0, val1, (clip.time()-t));
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

