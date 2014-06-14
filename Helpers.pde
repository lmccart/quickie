int getCol(int gender, String emotion) {
  // 0-male, 1-female
  int col = 0;
  if (emotion == "Positive") {
    col = 0;
  } else if (emotion == "Surprise") {
    col = 1;
  } else if (emotion == "Engagement") {
    col = 2;
  } else if (emotion == "Negative") {
    col = 3;
  }
  if (gender == 0) { // male
    col += 4;
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
  textSize(22.0);
  fill(genderC[0]);
}

// 22pt Titillium, cyan
void setupSubtext(int align) {
  textAlign(align);
  textFont(titilliumF);
  textSize(22.0);
  fill(genderC[0]);
}

// automatically start in fullscreen
boolean sketchFullScreen() {
  return true;
}

