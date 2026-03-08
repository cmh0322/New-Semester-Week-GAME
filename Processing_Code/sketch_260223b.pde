import processing.serial.*;
import ddf.minim.*;


float startOffset = 3650.0;

Serial myPort;
Minim minim;
AudioPlayer music;

ArrayList<Note> notes = new ArrayList<Note>();
ArrayList<Particle> particles = new ArrayList<Particle>();
IntList leaderBoard = new IntList(); 

ArrayList<Float> noteTimings = new ArrayList<Float>(); 
int noteIndex = 0;
float spawnLeadTime; 
float currentT; 

int score = 0, combo = 0, maxCombo = 0;
float health = 100; 
boolean isGameOver = false, isMusicPlaying = false;
boolean isClear = false; 
int gameOverTime = 0;
int clearTime = 0;      

float scaleF;        
int gameWidth;       
int offsetX;         
int hitLineY;        
float noteSpeed;     

float laneWidth;     
float[] laneX = new float[4]; 
int[] laneFlashTimer = {0, 0, 0, 0};

PGraphics bgBuffer;
PGraphics noteSprite; 

float comboScale = 1.0, screenShake = 0;
int damageFlashTimer = 0;

String feedbackText = "";
int feedbackTimer = 0;
color feedbackColor = color(255);

void setup() {
  size(1600, 900, P2D); 
  pixelDensity(1); 
  noSmooth(); 
  
  scaleF = height / 1080.0;
  
  gameWidth = int(height * 0.45); 
  offsetX = (width - gameWidth) / 2;
  hitLineY = int(height * 0.88); 
  
  noteSpeed = height / 58.0; 
  
  laneWidth = gameWidth / 4.0;
  for (int i = 0; i < 4; i++) {
    laneX[i] = (laneWidth * i) + (laneWidth / 2.0);
  }
  
  createNoteSprite();
  createBackgroundBuffer();
  
  minim = new Minim(this);
  try {
    music = minim.loadFile("music.wav"); 
  } catch (Exception e) {
    println("Failed to load music file");
  }

  spawnLeadTime = (float(hitLineY + 100) / noteSpeed) * (1000.0 / 60.0);
  generateChart();
  loadLeaderBoard();

  try {
    if (Serial.list().length > 0) {
      myPort = new Serial(this, Serial.list()[0], 115200);
    }
  } catch (Exception e) { 
    println("시리얼 연결 실패."); 
  }
}

void generateChart() {
  noteTimings.clear();
  currentT = startOffset; 
  addNotes(8, 0.5, 90); addNotes(8, 0.5, 100); addNotes(8, 0.5, 110);
  n(0.25, 125); r(0.5, 125); r(0.25, 125); n(0.25, 125); r(0.5, 125); r(0.25, 125); n(2.0, 125);
  addNotes(8, 0.5, 140); addNotes(8, 0.5, 155);
  n(0.5, 162); n(0.5, 162); n(0.5, 162); n(0.5, 162); n(0.25, 162); r(0.5, 162); r(0.25, 162); n(0.5, 162); r(0.5, 162); 
  n(0.5, 170); r(3.5, 170);
  addNotes(8, 0.5, 180); addNotes(8, 0.5, 190);
  n(0.5, 200); n(0.5, 200); n(0.5, 200); n(0.5, 200); n(0.25, 200); r(0.5, 200); r(0.25, 200); n(0.25, 200); n(0.25, 200); r(0.5, 200);
  n(0.25, 215); r(0.5, 215); r(0.25, 215); n(0.25, 215); r(0.5, 215); r(0.25, 215); n(2.0, 215);
  addNotes(4, 0.5, 225); addNotes(4, 0.5, 235); addNotes(4, 0.5, 245); addNotes(4, 0.5, 255);
  addNotes(8, 0.5, 270); n(4.0, 270);
  float b = 320;
  for(int i=0; i<3; i++) addNotes(8, 0.5, b); 
  n(0.25, b); r(0.5, b); r(0.25, b); n(0.25, b); r(0.5, b); r(0.25, b); n(2.0, b); 
  for(int i=0; i<2; i++) addNotes(8, 0.5, b); 
  n(0.5, b); n(0.5, b); n(0.5, b); n(0.5, b); n(0.25, b); r(0.5, b); r(0.25, b); n(0.25, b); r(0.5, b); r(0.25, b); 
  n(4.0, b); 
  for(int i=0; i<2; i++) addNotes(8, 0.5, b); 
  n(0.5, b); n(0.5, b); n(0.5, b); n(0.5, b); n(0.5, b); r(0.5, b); n(0.5, b); n(0.5, b); 
  n(0.5, b); n(0.5, b); n(2.0, b); r(1.0, b); 
  for(int i=0; i<3; i++) { 
    n(0.5, b); n(0.5, b); n(0.5, b); n(0.5, b); n(0.5, b); r(0.5, b); n(0.5, b); n(0.5, b);
  }
  n(4.0, b); 
}

void n(float beat, float bpm) { noteTimings.add(currentT); currentT += (60000.0 / bpm) * beat; }
void r(float beat, float bpm) { currentT += (60000.0 / bpm) * beat; }
void addNotes(int count, float beat, float bpm) { for (int i = 0; i < count; i++) n(beat, bpm); }

void createNoteSprite() {
  int nw = int(laneWidth * 0.92);
  int nh = int(50 * scaleF);
  noteSprite = createGraphics(nw + 20, nh + 20, P2D);
  noteSprite.beginDraw();
  noteSprite.rectMode(CENTER);
  noteSprite.fill(0, 150, 255);
  noteSprite.stroke(255);
  noteSprite.strokeWeight(3.5 * scaleF);
  noteSprite.rect(noteSprite.width/2, noteSprite.height/2, nw, nh, 8 * scaleF);
  noteSprite.noStroke();
  noteSprite.fill(255, 180);
  noteSprite.rect(noteSprite.width/2, noteSprite.height/2 - (12 * scaleF), nw * 0.8, 6 * scaleF, 3 * scaleF);
  noteSprite.endDraw();
}

void createBackgroundBuffer() {
  bgBuffer = createGraphics(gameWidth, height, P2D);
  bgBuffer.beginDraw();
  bgBuffer.background(5, 10, 20); 
  bgBuffer.stroke(0, 150, 255, 30);
  float gridS = 100 * scaleF;
  for (float i = 0; i <= gameWidth; i += gridS) bgBuffer.line(i, 0, i, height);
  for (float j = 0; j <= height; j += gridS) bgBuffer.line(0, j, gameWidth, j);
  for (int i=0; i<4; i++) {
    bgBuffer.noStroke(); bgBuffer.fill(255, 10); 
    bgBuffer.rect(laneWidth * i, 0, laneWidth, height);
    bgBuffer.stroke(0, 200, 255, 50); 
    bgBuffer.line(laneWidth * i, 0, laneWidth * i, height); 
  }
  bgBuffer.stroke(0, 255, 255, 200);
  bgBuffer.strokeWeight(6 * scaleF);
  bgBuffer.line(0, hitLineY, gameWidth, hitLineY);
  bgBuffer.endDraw();
}

void draw() {
  background(2, 5, 10); 

  while (myPort != null && myPort.available() > 0) {
    char inByte = myPort.readChar();
    if (isGameOver || isClear) {
      if (inByte >= 'A' && inByte <= 'D') {
        if (millis() - (isGameOver ? gameOverTime : clearTime) > 1000) resetGame();
      }
    } else {
      if (inByte >= 'A' && inByte <= 'D') checkHit(inByte - 'A');
    }
  }

  if (!isGameOver && !isClear && noteIndex >= noteTimings.size() && notes.isEmpty()) {
    isClear = true;
    clearTime = millis();
    updateLeaderBoard(score);
    if (music != null && music.isPlaying()) music.pause();
  }

  if (isGameOver) {
    if (music != null && music.isPlaying()) { music.pause(); music.rewind(); isMusicPlaying = false; }
    displayGameOver(); 
    drawLeaderBoardUI(); 
    return;
  }

  if (isClear) {
    displayClearUI(); 
    drawLeaderBoardUI();
    return;
  }

  if (music != null && !isMusicPlaying) { music.play(); isMusicPlaying = true; }

  pushMatrix();
  translate(offsetX, 0); 
  image(bgBuffer, 0, 0); 

  if (screenShake > 0.1) {
    translate(random(-screenShake, screenShake), random(-screenShake, screenShake));
  }
  
  drawLaneFlash(); 
  
  if (isMusicPlaying && music != null && noteIndex < noteTimings.size()) {
    if (music.position() + spawnLeadTime >= noteTimings.get(noteIndex)) {
      notes.add(new Note(int(random(4)))); 
      noteIndex++;
    }
  }

  for (int i = notes.size() - 1; i >= 0; i--) {
    Note n = notes.get(i); 
    n.y += noteSpeed;
    image(noteSprite, n.x - noteSprite.width/2, n.y - noteSprite.height/2);
    if (n.y > hitLineY + (160 * scaleF)) { 
      triggerFeedback("MISS", color(255, 50, 50));
      health -= 12; combo = 0; screenShake = 25 * scaleF; damageFlashTimer = 8;
      notes.remove(i);
    }
  }

  if (particles.size() > 0) {
    noStroke();
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.x += p.vx; p.y += p.vy; p.lifespan -= 22;
      if (p.lifespan <= 0) { particles.remove(i); continue; }
      fill(p.c, p.lifespan);
      rect(p.x, p.y, 11 * scaleF, 11 * scaleF);
    }
  }

  drawInGameUI();
  popMatrix(); 

  drawLeaderBoardUI(); 

  if (damageFlashTimer > 0) {
    fill(255, 0, 0, map(damageFlashTimer, 0, 8, 0, 70));
    rect(0, 0, width, height); damageFlashTimer--;
  }

  screenShake *= 0.85; 
  if (health <= 0) { 
    health = 0; 
    if(!isGameOver) { updateLeaderBoard(score); gameOverTime = millis(); isGameOver = true; }
  }
}

void checkHit(int lane) {
  boolean hitFound = false;
  for (int i = 0; i < notes.size(); i++) {
    Note n = notes.get(i);
    if (n.lane == lane) {
      float d = abs(n.y - hitLineY);
      if (d < 200 * scaleF) { 
        if (d < 90 * scaleF) { 
          score += 250; health += 2.0; if (health > 100) health = 100;
          triggerFeedback("PERFECT", color(255, 220, 0)); 
          spawnParticles(n.x, n.y, color(255, 220, 0)); 
        } else if (d < 150 * scaleF) { 
          score += 120; triggerFeedback("GREAT", color(0, 255, 255)); 
          spawnParticles(n.x, n.y, color(0, 255, 255)); 
        } else { 
          score += 50; triggerFeedback("GOOD", color(200)); 
          spawnParticles(n.x, n.y, color(200)); 
        }
        combo++; comboScale = 1.3; if (combo > maxCombo) maxCombo = combo;
        laneFlashTimer[lane] = 6; notes.remove(i);
        hitFound = true; break;
      }
    }
  }
  if (!hitFound) { health -= 5; screenShake = 15 * scaleF; damageFlashTimer = 5; combo = 0; triggerFeedback("WRONG!", color(255, 50, 50)); }
}

void keyPressed() {
  if (isGameOver || isClear) {
    if (millis() - (isGameOver ? gameOverTime : clearTime) > 1000) resetGame();
  } else {
    if (key == '1') checkHit(0); if (key == '2') checkHit(1);
    if (key == '3') checkHit(2); if (key == '4') checkHit(3);
  }
}

void triggerFeedback(String txt, color c) { feedbackText = txt; feedbackColor = c; feedbackTimer = 20; }
void spawnParticles(float x, float y, color c) { for (int i=0; i<3; i++) particles.add(new Particle(x, y, c)); }
void resetGame() { score = 0; combo = 0; health = 100; maxCombo = 0; noteIndex = 0; notes.clear(); particles.clear(); isGameOver = false; isClear = false; isMusicPlaying = false; if (music != null) { music.pause(); music.rewind(); } generateChart(); }

void drawLaneFlash() {
  rectMode(CENTER);
  for (int i=0; i<4; i++) {
    if (laneFlashTimer[i] > 0) { 
      noStroke(); fill(0, 200, 255, map(laneFlashTimer[i], 0, 6, 0, 65)); 
      rect(laneX[i], height/2, laneWidth, height); laneFlashTimer[i]--; 
    }
  }
}

void drawInGameUI() {
  rectMode(CORNER);
  float uiY = 50 * scaleF;
  fill(30, 40, 60, 230); rect(0, uiY, gameWidth, 25 * scaleF, 12 * scaleF);
  fill(lerpColor(color(255, 50, 50), color(0, 255, 150), health/100.0));
  rect(0, uiY, map(health, 0, 100, 0, gameWidth), 25 * scaleF, 12 * scaleF);
  fill(0, 255, 255); textSize(35 * scaleF); textAlign(LEFT);
  text("SCORE: " + nf(score, 6), 5, uiY - (12 * scaleF));
  if (combo > 1) {
    textAlign(CENTER); comboScale = lerp(comboScale, 1.0, 0.1);
    pushMatrix(); translate(gameWidth/2, height/2 - (150 * scaleF)); scale(comboScale);
    fill(255, 100); textSize(180 * scaleF); text(combo, 0, 0);
    textSize(45 * scaleF); fill(0, 200, 255); text("COMBO", 0, 75 * scaleF); popMatrix();
  }
  if (feedbackTimer > 0) {
    textAlign(CENTER); textSize(85 * scaleF); fill(feedbackColor, map(feedbackTimer, 0, 20, 0, 255));
    text(feedbackText, gameWidth/2, hitLineY - (300 * scaleF)); feedbackTimer--;
  }
}

void drawLeaderBoardUI() {
  float uiX = offsetX + gameWidth + (120 * scaleF); 
  if (uiX + (350 * scaleF) > width) uiX = width - (400 * scaleF); 
  textAlign(LEFT);
  fill(0, 255, 255); textSize(55 * scaleF); text("RANKING", uiX, 150 * scaleF);
  stroke(0, 255, 255, 100); strokeWeight(3 * scaleF);
  line(uiX, 180 * scaleF, uiX + (300 * scaleF), 180 * scaleF);
  textSize(38 * scaleF);
  for (int i = 0; i < 10; i++) {
    int val = (i < leaderBoard.size()) ? leaderBoard.get(i) : 0;
    if (i == 0) fill(255, 215, 0); 
    else if (i == 1) fill(192, 192, 192); 
    else if (i == 2) fill(205, 127, 50); 
    else fill(200, 220, 255, 180);
    text((i+1) + ". " + nf(val, 6), uiX, 250 * scaleF + (i * 85 * scaleF));
  }
}

void displayGameOver() {
  pushStyle();
  fill(0, 0, 0, 220); rect(0, 0, width, height); 
  textAlign(CENTER, CENTER);
  fill(255, 50, 50); textSize(width/12); text("MISSION FAILED", width/2, height/2 - (120 * scaleF));
  fill(255); textSize(width/28); text("YOUR SCORE: " + score, width/2, height/2 + 30);
  if (millis() % 1000 < 500) { fill(0, 255, 255); textSize(35 * scaleF); text("PRESS ANY KEY TO RETRY", width/2, height/2 + 180); }
  popStyle();
}

void displayClearUI() {
  pushStyle();
  fill(10, 20, 40, 235); rect(0, 0, width, height); 
  textAlign(CENTER, CENTER);
  fill(0, 255, 150); textSize(width/12); text("MISSION CLEAR", width/2, height/2 - (180 * scaleF));
  fill(255, 220, 0); textSize(width/28); text("FINAL SCORE: " + score, width/2, height/2 + 10);
  fill(0, 200, 255); textSize(width/35); text("MAX COMBO: " + maxCombo, width/2, height/2 + (90 * scaleF));
  if (millis() % 1000 < 500) { fill(255); textSize(35 * scaleF); text("PRESS ANY KEY TO PLAY AGAIN", width/2, height/2 + 220); }
  popStyle();
}

void loadLeaderBoard() { leaderBoard.clear(); String[] lines = loadStrings("data/leaderboard.txt"); if (lines != null) { for (String s : lines) if (!s.trim().equals("")) leaderBoard.append(int(s)); leaderBoard.sortReverse(); } }
void updateLeaderBoard(int newScore) { leaderBoard.append(newScore); leaderBoard.sortReverse(); if (leaderBoard.size() > 10) leaderBoard.remove(10); String[] out = new String[leaderBoard.size()]; for (int i = 0; i < leaderBoard.size(); i++) out[i] = str(leaderBoard.get(i)); saveStrings("data/leaderboard.txt", out); }

class Note { int lane; float x, y = -150; Note(int l) { lane = l; x = laneX[lane]; } }
class Particle { float x, y, vx, vy, lifespan = 255; color c; Particle(float xpos, float ypos, color col) { x = xpos; y = ypos; c = col; vx = random(-8 * scaleF, 8 * scaleF); vy = random(-8 * scaleF, 8 * scaleF); } }
