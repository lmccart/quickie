void drawBars() {
  String[] emotions = { "Positive", "Negative", "Surprise" };

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
  strokeWeight(3);
  noFill();

  // label
  float x0 = 245.0;
  setupText(LEFT);
  text("Engagement", x0, textY);

  // draw curves
  for (int j=0; j<2; j++) {
    float y0 = 65.0;
    float maxH = 170.0;
    float totalW = 710.0;
    stroke(genderC[j]);
    
    beginShape();
    noFill();
    curveVertex(x0, refHeight-y0);
    for (int i=0; i<= datas[curVid].getRowCount(); i++) {
      float x = x0 + i*totalW/datas[curVid].getRowCount();
      float y = refHeight - y0 - maxH*datas[curVid].getFloat(min(i, datas[curVid].getRowCount()-1), getCol(j, "Engagement"));
      curveVertex(x, y);
      if (i == datas[curVid].getRowCount()) {
        curveVertex(x, y);
      }
    }
    endShape();
    
    // draw little circle
    pushMatrix();
    translate(0, 0, 1); // easiest way to get circles on top of curve
    fill(0);
    float cX = x0 + clips[curVid].time()*totalW/datas[curVid].getRowCount();
    float cY = refHeight - y0 - maxH*getLerpVal(getCol(j, "Engagement"));
    ellipse(cX, cY, 10, 10);
    popMatrix();
  }
}

void drawExtras() {
  // EYES - top left
  shape(eyesSVG, 65, 65); 

  // GENDER - bottom left
  setupText(LEFT);
  text("Gender", 65, textY);

  setupSubtext(LEFT);
  shape(menSVG, 65, refHeight-215); 
  text("Men", 125, refHeight-172);

  fill(genderC[1]);
  shape(womenSVG, 65, refHeight-135); 
  text("Women", 125, refHeight-92);

  // CANNES - bottom right
  PShape curMedal;
  String curAward = awardTypes[curVid];
  if(curAward.equals("bronze")) {
    curMedal = bronzeSVG;
  } else if(curAward.equals("gold")) {
    curMedal = goldSVG;
  } else if(curAward.equals("silver")) {
    curMedal = silverSVG;
  } else if(curAward.equals("shortlist")) {
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

