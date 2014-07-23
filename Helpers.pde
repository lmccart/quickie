void centerAndScale(float w, float h) {
  translate(width / 2, height / 2);
  float widthRatio = width / w;
  float heightRatio = height / h;
  if(widthRatio / heightRatio > 1) {
    scale(widthRatio);
  } else {
    scale(heightRatio);
  }
  translate(-w / 2, -h / 2);
}

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

// 2 and 6 are engagement, rest are emos
void getLimits() {
  emoLimits = new float[datas.length][2];
  for (int i=0; i<datas.length; i++) {
    float minLim = 1;
    float maxLim = 0;
    for (int j=0; j<datas[i].getRowCount(); j++) {
      for (int k=0; k<datas[i].getColumnCount(); k++) {
        if (k != 2 && k != 6) {
          float v = datas[i].getFloat(j, k);
          minLim = min(minLim, v);
          maxLim = max(maxLim, v);
        }
      } 
    }
    emoLimits[i][0] = minLim; 
    emoLimits[i][1] = maxLim;
  } 
  
  engageLimits = new float[datas.length][2];
  for (int i=0; i<datas.length; i++) {
    float minLim = 1;
    float maxLim = 0;
    for (int j=0; j<datas[i].getRowCount(); j++) {
      for (int k=0; k<datas[i].getColumnCount(); k++) {
        if (k == 2 || k == 6) {
          float v = datas[i].getFloat(j, k);
          minLim = min(minLim, v);
          maxLim = max(maxLim, v);
        }
      } 
    }
    engageLimits[i][0] = minLim; 
    engageLimits[i][1] = maxLim;
  } 
}

// uses data in csv to lerp inbetween values based on current playtime
float getLerpVal(int col) {
  return getLerpVal(col, clips[curVid].time()); 
}

// uses data in csv to lerp inbetween values
float getLerpVal(int col, float start) {
  
  int t = floor(start);
  if (t >= datas[curVid].getRowCount()) {
    t = datas[curVid].getRowCount()-1;
  }
  float val0 = datas[curVid].getFloat(t, col);
  float val1 = val0;
  if (t+1 < datas[curVid].getRowCount()) {
    val1 = datas[curVid].getFloat(t+1, col);
  }
  float v = lerp(val0, val1, (start-t));
  return v;
}

// 22px Raleway, cyan
void setupText(int align) {
  textAlign(align);
  textFont(ralewayF);
  textSize(22);
  fill(genderC[0]);
}

// 22px Titillium, cyan
void setupSubtext(int align) {
  textAlign(align);
  textFont(titilliumF);
  textSize(22);
  fill(genderC[0]);
}

// automatically start in fullscreen
boolean sketchFullScreen() {
  return true;
}

