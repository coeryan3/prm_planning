//CSCI 5611 - Graph Search & Planning
//PRM Sample Code [Proj 1]
//Instructor: Stephen J. Guy <sjguy@umn.edu>

//This is a test harness designed to help you test & debug your PRM.

//USAGE:
// On start-up your PRM will be tested on a random scene and the results printed
// Left clicking will set a red goal, right clicking the blue start
// The arrow keys will move the circular obstacle with the heavy outline
// Pressing 'r' will randomize the obstacles and re-run the tests

//Change the below parameters to change the scenario/roadmap size
int numObstacles = 50;
int numNodes  = 100;
float agentSpeed = 25;


float agentRad = 10;
  
  
//A list of circle obstacles
static int maxNumObstacles = 1000;
Vec2 circlePos[] = new Vec2[maxNumObstacles]; //Circle positions
float circleRad[] = new float[maxNumObstacles];  //Circle radii

Vec2 startPos = new Vec2(100,500);
Vec2 goalPos = new Vec2(500,200);

//Vec2 agentPos;
int nodeID = 0;
int nodePath = 0;
static int minNumAgents = 1;
static int maxNumAgents = 1000;
int numAgents = 1;
Vec2[] agentPos;
//int whichAgent = 0;


/*
//A list of agents
static int maxNumAgents = 10;

Vec2[] startPos = new Vec2[maxNumAgents];
//startPos[0] = Vec2(100,500);
Vec2[] goalPos = new Vec2[maxNumAgents];
//goalPos[0] = Vec2(500,200);


int numPaths = 1;

int[] nodeID = new int[maxNumAgents];
int[] nodePath = new int[maxNumAgents];
*/




static int maxNumNodes = 1000;
Vec2[] nodePos = new Vec2[maxNumNodes];

//Generate non-colliding PRM nodes
void generateRandomNodes(int numNodes, Vec2[] circleCenters, float[] circleRadii){
  for (int i = 0; i < numNodes; i++){
    Vec2 randPos = new Vec2(random(width),random(height));
    boolean insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numObstacles,randPos,2);
    //boolean insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    while (insideAnyCircle){
      randPos = new Vec2(random(width),random(height));
      insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numObstacles,randPos,2);
      //insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    }
    nodePos[i] = randPos;
  }
}

void placeRandomObstacles(int numObstacles){
  //Initial obstacle position
  for (int i = 0; i < numObstacles; i++){
    circlePos[i] = new Vec2(random(50,950),random(50,700));
    circleRad[i] = (10+40*pow(random(1),3));
  }
  circleRad[0] = 30; //Make the first obstacle big
}



ArrayList<Integer> curPath;
//ArrayList<Integer>[] curPath = new ArrayList[maxNumAgents];





PImage obstacle;
PImage asteroid;
PImage background;
PImage agent;
PImage planetStart;
PImage planetGoal;

int strokeWidth = 2;
void setup(){
  size(1024,768);
  obstacle = loadImage("asteroid2.png");
  asteroid = loadImage("asteroid.png");
  //background = loadImage("space.png");
  background = loadImage("space2.jpg");
  agent = loadImage("millenium_falcon.png");
  planetStart = loadImage("mars.png");
  planetGoal = loadImage("saturn.png");
  
  testPRM();
  /*
  for(int i = 0; i < numAgents; i++){
    testPRM(i);
  }
  */
}





int numCollisions;
float pathLength;
boolean reachedGoal;
void pathQuality(){
  Vec2 dir;
  hitInfo hit;
  float segmentLength;
  numCollisions = 9999; pathLength = 9999;
  if (curPath.size() == 1 && curPath.get(0) == -1) return; //No path found  
  
  pathLength = 0; numCollisions = 0;
  
  if (curPath.size() == 0 ){ //Path found with no nodes (direct start-to-goal path)
    segmentLength = startPos.distanceTo(goalPos);
    pathLength += segmentLength;
    dir = goalPos.minus(startPos).normalized();
    hit = rayCircleListIntersect(circlePos, circleRad, numObstacles, startPos, dir, segmentLength);
    if (hit.hit) numCollisions += 1;
    return;
  }
  
  segmentLength = startPos.distanceTo(nodePos[curPath.get(0)]);
  pathLength += segmentLength;
  dir = nodePos[curPath.get(0)].minus(startPos).normalized();
  hit = rayCircleListIntersect(circlePos, circleRad, numObstacles, startPos, dir, segmentLength);
  if (hit.hit) numCollisions += 1;
  
  
  for (int i = 0; i < curPath.size()-1; i++){
    int curNode = curPath.get(i);
    int nextNode = curPath.get(i+1);
    segmentLength = nodePos[curNode].distanceTo(nodePos[nextNode]);
    pathLength += segmentLength;
    
    dir = nodePos[nextNode].minus(nodePos[curNode]).normalized();
    hit = rayCircleListIntersect(circlePos, circleRad, numObstacles, nodePos[curNode], dir, segmentLength);
    if (hit.hit) numCollisions += 1;
  }
  
  int lastNode = curPath.get(curPath.size()-1);
  segmentLength = nodePos[lastNode].distanceTo(goalPos);
  pathLength += segmentLength;
  dir = goalPos.minus(nodePos[lastNode]).normalized();
  hit = rayCircleListIntersect(circlePos, circleRad, numObstacles, nodePos[lastNode], dir, segmentLength);
  if (hit.hit) numCollisions += 1;
}





Vec2 sampleFreePos(){
  Vec2 randPos = new Vec2(random(width),random(height));
  boolean insideAnyCircle = pointInCircleList(circlePos,circleRad,numObstacles,randPos,2);
  while (insideAnyCircle){
    randPos = new Vec2(random(width),random(height));
    insideAnyCircle = pointInCircleList(circlePos,circleRad,numObstacles,randPos,2);
  }
  return randPos;
}








void testPRM(){
  long startTime, endTime;
  
  placeRandomObstacles(numObstacles);
  
  startPos = sampleFreePos();
  goalPos = sampleFreePos();
  
  numAgents = 1;
  agentPos = new Vec2[maxNumAgents];
  
  
  agentPos[0] = new Vec2(startPos.x, startPos.y);
  agentSpeed = 50;
  nodeID = 0;
  nodePath = 0;

  generateRandomNodes(numNodes, circlePos, circleRad);
  connectNeighbors(circlePos, circleRad, numObstacles, nodePos, numNodes);
  
  startTime = System.nanoTime();
  curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes);
  endTime = System.nanoTime();
  pathQuality();
  
  if(numCollisions > 0) testPRM();
  
  println("Nodes:", numNodes," Obstacles:", numObstacles," Time (us):", int((endTime-startTime)/1000),
          " Path Len:", pathLength, " Path Segment:", curPath.size()+1,  " Num Collisions:", numCollisions);
}





void update(float dt){
  Vec2 alphadir;
  Vec2 agentVel;
  float radius = 5;
  for(int k = 0; k < numAgents; k++){
  if(agentPos[k].distanceTo(goalPos) < radius/2){
      agentSpeed = 0;
    }
    
    if(nodeID < curPath.size()) nodePath = curPath.get(nodeID);
    
    if(agentPos[k].distanceTo(nodePos[nodePath]) < radius && nodeID < curPath.size()){
      nodeID++;
      alphadir = nodePos[nodePath].minus(agentPos[k]);
      if(alphadir.length() > 0) alphadir.normalize();
      agentVel = alphadir.times(agentSpeed);
      agentPos[k].add(agentVel.times(dt));
    }
    
    
    else if (nodeID < curPath.size()){
      alphadir = nodePos[nodePath].minus(agentPos[k]);
      if(alphadir.length() > 0) alphadir.normalize();
      agentVel = alphadir.times(agentSpeed);
      agentPos[k].add(agentVel.times(dt));
    }
    
    
    else if(agentPos[k].distanceTo(nodePos[nodePath]) < radius && nodeID >= curPath.size()-1){
      alphadir = goalPos.minus(agentPos[k]);
      if(alphadir.length() > 0) alphadir.normalize();
      agentVel = alphadir.times(agentSpeed);
      agentPos[k].add(agentVel.times(dt));
    }  
    else {
      alphadir = goalPos.minus(agentPos[k]);
      if(alphadir.length() > 0) alphadir.normalize();
      agentVel = alphadir.times(agentSpeed);
      agentPos[k].add(agentVel.times(dt));
    }
  }
  
    
  /*
  int nextID = nodeID + 1;
  
  if(nextID < curPath.size()){
    Vec2 nextDir = nodePos[curPath.get(nodeID+1)].minus(agentPos);
    hitInfo hit = rayCircleListIntersect(circlePos, circleRad, numObstacles, agentPos, nextDir, agentPos.distanceTo(nodePos[curPath.get(nodeID+1)]));
    if(!hit.hit){
      nodeID++;
      alphadir = nextDir;
      agentVel = alphadir.times(agentSpeed);
      agentPos.add(agentVel.times(dt));
      System.out.println("hello");
    }
  }
  */
}



void draw(){
  if (!paused){
    update(1.0/frameRate);
  }  
  //println("FrameRate:",frameRate);
  strokeWeight(1);
  background(0); //Grey background
  image(background, 0, 0, 1024, 768); 
  stroke(0,0,0);  
  
  //Draw the circle obstacles
  for (int i = 0; i < numObstacles; i++){
    Vec2 c = circlePos[i];
    float r = circleRad[i];
    image(obstacle, c.x-r, c.y-r, r*2, r*2); 
  }  
  //Draw graph
  stroke(100,100,100, 5);
  strokeWeight(1);
  for (int i = 0; i < numNodes; i++){
    for (int j : neighbors[i]){
      line(nodePos[i].x,nodePos[i].y,nodePos[j].x,nodePos[j].y);
    }
  }
  
  //Draw Start and Goal
  
  //fill(20,60,250);
  //circle(nodePos[startNode].x,nodePos[startNode].y,20);
  //circle(startPos.x,startPos.y,20);
  image(planetStart, startPos.x-20,startPos.y-20, 75/2, 75/2); 
  //other start images for planets -> image(planetStart, startPos.x-20,startPos.y-20, 20*2, 20*2);
  
  
  //fill(250,30,50);
  //circle(nodePos[goalNode].x,nodePos[goalNode].y,20);
  //circle(goalPos.x,goalPos.y,20);
  image(planetGoal, goalPos.x-20,goalPos.y-20, 100/2, 75/2);
  //other goal images for planets -> image(planetGoal, goalPos.x-20,goalPos.y-20, 20*2, 20*2);
 
  
  
  if (curPath.size() >0 && curPath.get(0) == -1) return; //No path found
  
  //Draw Planned Path
  stroke(20,255,40, 5);
  strokeWeight(5);
  if (curPath.size() == 0){
    line(startPos.x,startPos.y,goalPos.x,goalPos.y);
    return;
  }
  line(startPos.x,startPos.y,nodePos[curPath.get(0)].x,nodePos[curPath.get(0)].y);
  for (int i = 0; i < curPath.size()-1; i++){
    int curNode = curPath.get(i);
    int nextNode = curPath.get(i+1);
    line(nodePos[curNode].x,nodePos[curNode].y,nodePos[nextNode].x,nodePos[nextNode].y);
  }
  line(goalPos.x,goalPos.y,nodePos[curPath.get(curPath.size()-1)].x,nodePos[curPath.get(curPath.size()-1)].y);
  
  fill(255,192,203);
  stroke(0);
  strokeWeight(1);
  //circle(agentPos[0].x, agentPos[0].y, agentRad);
  image(agent, agentPos[0].x-agentRad, agentPos[0].y-agentRad, agentRad*2, agentRad*2+4); 
  
}





int closestCircle(Vec2 mouse){
  float minDist = 999999;
  int closest = 0;
  for(int i = 0; i < numObstacles; i++){
    float dist = mouse.distanceTo(circlePos[i]);
    if(dist < minDist){
      minDist = dist;
      closest = i;
    }
  }
  return closest;
}






void fixObstacleArrays(int circleID){
  for(int i = circleID; i < numObstacles-1; i++){
    circlePos[i] = circlePos[i+1];
    circleRad[i] = circleRad[i+1];
  }
  circlePos[numObstacles-1] = new Vec2(0,0);
  circleRad[numObstacles-1] = 0;
}






int closest;
boolean paused = true;
boolean shiftDown = false, ctrlDown = false, altDown = false;
void keyPressed(){
  if (key == 'r'){
    testPRM();
    /*
    for(int i = 0; i < numAgents; i++){
      testPRM(i);
    }
    */
    return;
  }
  
  if (keyCode == CONTROL){
    ctrlDown = true;
  }
  
  Vec2 mousePos = new Vec2(mouseX, mouseY);
  if(ctrlDown){
    closest = closestCircle(mousePos);
    circlePos[closest] = mousePos;
  } 
  
  if (key == ' ') {
    paused = !paused;
    return;
  }
  if (keyCode == ALT){
    altDown = true;
  }
  if (keyCode == SHIFT){
    shiftDown = true;
  }
  float speed = 5;
  if (keyCode == UP){
    agentSpeed += speed;
  }
  if (keyCode == DOWN){
    agentSpeed -= speed;
  }
  
  /*
  if (keyCode == '1'){
    whichAgent = 0;
  }
  if (keyCode == '2'){
    whichAgent = 1;
  }
  if (keyCode == '3'){
    whichAgent = 2;
  }
  if (keyCode == '4'){
    whichAgent = 3;
  }
  if (keyCode == '5'){
    whichAgent = 4;
  }
  if (keyCode == '6'){
    whichAgent = 5;
  }
  if (keyCode == '7'){
    whichAgent = 6;
  }
  if (keyCode == '8'){
    whichAgent = 7;
  }
  if (keyCode == '9'){
    whichAgent = 8;
  }
  if (keyCode == '0'){
    whichAgent = 9;
  }
  */
  
  connectNeighbors(circlePos, circleRad, numObstacles, nodePos, numNodes);
  curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes);

  /*
  for(int i = 0; i < numAgents; i++){
    curPath[i] = planPath(startPos[i], goalPos[i], circlePos, circleRad, numObstacles, nodePos, numNodes);
  }
  */
  
}

void keyReleased(){
  if (keyCode == SHIFT){
    shiftDown = false;
  }
  if (keyCode == CONTROL){
    ctrlDown = false;
  }
  if (keyCode == ALT){
    altDown = false;
  }
}







void mousePressed(){
  if(altDown){
    if(mouseButton == LEFT){  
      fill(255);
      Vec2 c = new Vec2(mouseX, mouseY);
      float r = 10+40*pow(random(1),3);
      image(obstacle, c.x-r, c.y-r, r*2, r*2); 
      circlePos[numObstacles] = c;
      circleRad[numObstacles] = r;
      numObstacles++;
    }
    /*else{
        fill((random(10,255)), (random(10,255)), (random(10,255)));
        strokeWeight(1);
        Vec2 a = new Vec2(startPos.x, startPos.y);  
        circle(a.x, a.y, agentRad);
        agentPos[numAgents] = a;
        numAgents++;
    }
    */
  }
  else if(shiftDown){
    if(mouseButton == LEFT){
      Vec2 mouse = new Vec2(mouseX, mouseY);
      int ID = closestCircle(mouse);
      fixObstacleArrays(ID);
      numObstacles--;
    }
    //else remove agents/paths
  }
  else{
    if (mouseButton == RIGHT){
      startPos = new Vec2(mouseX, mouseY);
      for(int k = 0; k < numAgents; k++){
        agentPos[k] = new Vec2(mouseX, mouseY);
      }
      //println("New Start is",startPos.x, startPos.y);
    }
    else{
      goalPos = new Vec2(mouseX, mouseY);
      //println("New Goal is",goalPos.x, goalPos.y);
    }
  }
  curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes);
}




/*

RRT(initial, numNodes, dt){
  arrayList path;
  neighbors[];
  float[] pathCost = new float[numNodes];
  for(int i = 0; i < numNodes; i++){
    xRandom;
    nearest = nearestNode between random 











































*/
