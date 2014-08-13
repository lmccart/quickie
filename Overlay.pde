import processing.video.*;
import java.io.FilenameFilter;

int curVid;

boolean zoomGraph = true;
PGraphics graphBuffer;
PImage graphImg;
float graphWidth = 710, graphHeight = 150, graphPad = 10;
float circleSize = 15;

// assets
Movie[] clips;
Table[] datas; // pos-f, eng-f, neg-f, pos-m, eng-m, neg-m
float[][] emoLimits;
float[][] engageLimits;
PShape menSVG, womenSVG, eyesSVG;
PShape shortlistSVG, bronzeSVG, silverSVG, goldSVG, grandPrixSVG; 
PImage gradient;
PFont ralewayF, titilliumF;
String[] awardTypes;
boolean noAward[];

// styling
float refScale, refWidth = 1920, refHeight = 1080;
color[] genderC = { 
  color(0, 255, 255), color(102, 255, 0)
}; // cyan, green
color gridC = color(255, 61, 255);
float textY;
float subtextY;

void setup() {
//  size(1280, 720, OPENGL);

  size(displayWidth, round(refHeight * displayWidth / refWidth), OPENGL);
  smooth(8);
  ortho(0, width, 0, height);
  refScale = width / refWidth;

  // load list of content directories, choose one
  String contentPath = dataPath("content");
  File file = new File(contentPath);
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
  noAward = new boolean[dirs.length];
  awardTypes = new String[dirs.length];

  for (int i=0; i<dirs.length; i++) {
    String path = contentPath+"/"+dirs[i]+"/";
    clips[i] = new Movie(this, path+"clip.mp4");
    datas[i] = loadTable(path+"data.csv", "header");
    File f = new File(dataPath(path+"award.txt"));
    if (f.exists()) {
      awardTypes[i] = loadStrings(path+"award.txt")[0];
      noAward[i] = false;
    } else {
      noAward[i] = true;
    }
  }
  getLimits();
  graphBuffer = createGraphics(int(260.0+graphWidth*10+2*graphPad), int(graphHeight+2*graphPad), OPENGL);

  // choose start
  curVid = floor(random(dirs.length));
  println("choosing "+curVid+": "+dirs[curVid]);
  clips[curVid].play();
  drawGraphBuffer();

  // load images
  menSVG = loadShape("Icon_Men.svg");
  womenSVG = loadShape("Icon_Women.svg");
  eyesSVG = loadShape("Logo_Realeyes_Ipsos.svg");
  gradient = loadImage("gradient.png");

  // load medals
  shortlistSVG = loadShape("Medal_Shortlist.svg");
  bronzeSVG = loadShape("Medal_Bronze.svg");
  silverSVG = loadShape("Medal_Silver.svg");
  goldSVG = loadShape("Medal_Gold.svg");
  grandPrixSVG = loadShape("Medal_GrandPrix.svg");

  // load fonts
  ralewayF = createFont("Raleway-Medium.ttf", 44);
  titilliumF = createFont("TitilliumWeb-Light.ttf", 44);
  textY = refHeight-265;
  subtextY = refHeight-235;
}

void draw() {
  background(0);
  noTint();

  pushMatrix();
  centerAndScale(clips[curVid].width, clips[curVid].height);
  image(clips[curVid], 0, 0);
  popMatrix();

  scale(refScale);

  pushStyle();
  tint(255, 200);
  image(gradient, 0, 0, refWidth, refHeight);
  popStyle();

  drawBars();
  drawGraph();
  drawExtras();

  //drawGrid();

  if (clips[curVid].time() == clips[curVid].duration()) { 
    curVid = floor(random(clips.length));
    clips[curVid].jump(0);
    clips[curVid].play();
    drawGraphBuffer();
  }

//  if(frameCount == 30) {
//    saveFrame("render.png");
//  }
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}

void keyPressed() {
  if (key == ' ') {
    zoomGraph = !zoomGraph;
    drawGraphBuffer();
  }
}

