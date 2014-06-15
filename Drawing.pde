void drawBars() {
  String[] emotions = { 
    "Positive", "Negative", "Surprise"
  };

  noStroke();
  float x = 1065.0;
  float w = 80.0;
  float y = refHeight-65.0;
  float maxH = 160.0;
  for (int i=0; i<3; i++) {
    float textX = x+85.0;
    float totalV = 0;

    // emotion label
    setupText(CENTER);
    text(emotions[i], textX, textY);

    for (int j=0; j<2; j++) { // men and women
      float val = getLerpVal(getCol(j, emotions[i]));
      totalV += val;
      val = map(val, limits[curVid][0], limits[curVid][1], 0, 1);

      fill(genderC[j]);
      float h = maxH*val;
      rect(x, y-h, w, h);
      x += 90.0;
    }

    // percentage label
    setupSubtext(CENTER);
    text(round(totalV*50.0)+"%", textX, subtextY);
  }
}

void drawGraph() {

  float dur = clips[curVid].duration();
  float secs = 30;

  int x = int(-1*graphPad);
  float start = 0;
  if (zoomGraph) {
    start = max(min(clips[curVid].time()-(float)secs*0.5, dur-(float)secs), 0);
    x += round(graphWidth*start/secs);
  }
  graphImg = graphBuffer.get(x, 0, int(graphWidth+2*graphPad), graphBuffer.height);

  strokeWeight(3);
  noFill();

  // label
  float x0 = 245.0;
  float y0 = refHeight-65;
  setupText(LEFT);
  text("Engagement", x0, textY);

  // draw curves
  for (int j=0; j<2; j++) {

    image(graphImg, x0-20, y0-graphBuffer.height+10);

    // draw little circle
    pushMatrix();
    translate(0, 0, 1); // easiest way to get circles on top of curve
    fill(0);
    stroke(genderC[j]);
    float cX = x0;
    float cY = y0 - graphHeight*getLerpVal(getCol(j, "Engagement"));
    if (zoomGraph) {
      cX += (clips[curVid].time()-start)*graphWidth/secs;
    } else {
      cX += clips[curVid].time()*graphWidth/datas[curVid].getRowCount();
    }
    ellipse(cX, cY, graphPad, graphPad);
    popMatrix();
  }
}


void drawGraphBuffer() {

  graphBuffer.beginDraw();
  graphBuffer.clear();
  //graphBuffer.smooth(8);
  //graphBuffer.ortho(0, graphBuffer.width, 0, graphBuffer.height);

  graphBuffer.strokeWeight(3);
  graphBuffer.translate(10, 10);

  // draw curves
  for (int j=0; j<2; j++) {
    float totalW = 710.0;

    if (zoomGraph) {
      totalW *= clips[curVid].duration() / 30.0;
    }

    graphBuffer.stroke(genderC[j]);
    graphBuffer.noFill();

    graphBuffer.beginShape();
    graphBuffer.curveVertex(0, graphHeight);

    int numRows = datas[curVid].getRowCount();
    for (int i=0; i<= numRows; i++) {
      float x = i*totalW/numRows;
      float val = datas[curVid].getFloat(min(i, numRows-1), getCol(j, "Engagement"));
      val = map(val, limits[curVid][0], limits[curVid][1], 0, 1);
      float y = graphHeight*(1-val);
      graphBuffer.curveVertex(x, y);
      if (i == numRows) {
        graphBuffer.curveVertex(x, y);
      }
    }
    graphBuffer.endShape();
  }
  graphBuffer.endDraw();
}

void drawExtras() {
  // EYES - top left
  shape(eyesSVG, 65, 65); 

  // GENDER - bottom left
  setupText(LEFT);
  text("Gender", 65, textY);

  setupSubtext(LEFT);
  shape(menSVG, 65, refHeight-215); 
  text("Men", 128, refHeight-178);

  fill(genderC[1]);
  shape(womenSVG, 65, refHeight-135); 
  text("Women", 128, refHeight-97);

  // CANNES - bottom right
  PShape curMedal;
  String curAward = awardTypes[curVid];
  if (curAward.equals("bronze")) {
    curMedal = bronzeSVG;
  } else if (curAward.equals("gold")) {
    curMedal = goldSVG;
  } else if (curAward.equals("silver")) {
    curMedal = silverSVG;
  } else if (curAward.equals("shortlist")) {
    curMedal = shortlistSVG;
  } else {
    curMedal = grandPrixSVG;
  }
  shape(curMedal, refWidth - 235, refHeight - 195);
}

void drawGrid() {
  float bigPad = 65, smallPad = 10, spacing = 170;
  pushStyle();
  stroke(gridC);
  strokeWeight(2);
  pushMatrix();
  translate(bigPad, 0);
  for (int i=0; i<11; i++) {
    line(0, 0, 0, refHeight);
    if (i > 0 && i < 10) {
      translate(smallPad, 0);
      line(0, 0, 0, refHeight);
    }
    translate(spacing, 0);
  }
  popMatrix();
  line(0, bigPad, refWidth, bigPad);
  line(0, refHeight - bigPad, refWidth, refHeight - bigPad);
  popStyle();
}


