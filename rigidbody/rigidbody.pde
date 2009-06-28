import processing.opengl.*;

/** 
binarymillenium
GPL v3.0
June 2009

*/

import toxi.geom.*;

body vehicle; 
movable cam;

terrain land;

void drawArrow(float len, float rad, color col ) {
  pushMatrix();
        
  noStroke();
 
  fill(col);
    
      /// body drawing
      int sides = 8;
      float angleIncrement = TWO_PI/sides;
      float angle = 0;  
      
      /// draw cylind
      beginShape(TRIANGLE_STRIP);
       for (int i = 0; i < sides + 1; i++) {
        vertex(0, rad * cos(angle),  rad * sin(angle));
        vertex( len, rad * cos(angle),  rad * sin(angle));
        angle += angleIncrement;
      }
      endShape();
      
      beginShape(TRIANGLE_FAN);
      // Center point
      vertex(len*1.3, 0, 0);
      for (int i = 0; i < sides + 1; i++) {
        vertex(len, rad*2 * cos(angle),  rad*2 * sin(angle));
        angle += angleIncrement;
      }
      endShape();  

  popMatrix();  
}



void setup() {
  size(800,600,P3D); 
  frameRate(15);
 
  vehicle = new body();
  vehicle.vel.x += 10;
  cam = new body();
  
  //land = new terrain("G:/other/western_wa/ned_1_3_78184666/78184666");
  land = new terrain("78184666");
}

//////////////////////////////////////////////////////

float increase(float x) {
     x += 1; 
       
   if (x > 0) cam.vel.x *= 1.2;
   else x *= 0.9;
   
   return x;
  
}

float decrease(float x) {
  x -= 1.1; 
       
  if (x < 0) x *= 1.2;
  else x *= 0.9;
  
  return x;
}

void keyPressed() {
 //if (keyPressed) {
   
    if (key == 'a') {
       Vec3D dir = rotateAxis(cam.rot, new Vec3D(1,0,0));
       cam.offsetVel = cam.offsetVel.add(dir.scale(10) );
       println(cam.offsetVel.x);
    }
    if (key == 'd') {
        Vec3D dir = rotateAxis(cam.rot, new Vec3D(-1,0,0));
       cam.offsetVel = cam.offsetVel.add(dir.scale(10) );
    }
    if (key == 'q') {
       Vec3D dir = rotateAxis(cam.rot, new Vec3D(0,1,0));
       cam.offsetVel = cam.offsetVel.add(dir.scale(10) );
    }
    if (key == 'z') {
       Vec3D dir = rotateAxis(cam.rot, new Vec3D(0,-1,0));
       cam.offsetVel = cam.offsetVel.add(dir.scale(10) ); 
    }
    if (key == 'w') {
       Vec3D dir = rotateAxis(cam.rot, new Vec3D(0,0,1));
       cam.offsetVel = cam.offsetVel.add(dir.scale(10) );
    }
    if (key == 's') {
       Vec3D dir = rotateAxis(cam.rot, new Vec3D(0,0,-1));
       cam.offsetVel = cam.offsetVel.add(dir.scale(10) );
    }    
    if (key == 'e') {
       cam.vel.z = increase(cam.vel.z); 
       println(cam.pos.z); 
    }
    if (key == 'c') {
      cam.pos.z = decrease(cam.vel.z);
      //println(cam.offset.z);
    }
//}
}

void handleMouse() {
        if (mousePressed) {
    /*
    println("start " + cam.rot.toArray()[0] + " " + 
            cam.rot.toArray()[1] + " " + 
            cam.rot.toArray()[2] + " " +
            cam.rot.toArray()[3]  );*/
    
    //cam.rot = cam.rot.normalize();  
    /// the ordering is xyzw, not wxyz
     
    float dx = (mouseX - oldMouseX)/500.0;
    float dy = (mouseY - oldMouseY)/500.0;
    
    Vec3D axis;
    if (mouseButton == RIGHT) {
      axis = new Vec3D(0,0,-1);
      cam.rotateBody(dx, axis);
    } else {
      axis = new Vec3D(0,1,0);
      cam.rotateAbs(-dx, axis);
    }
    
    Vec3D y_axis = new Vec3D(-1,0,0);
    //cam.rotateAbs(dy, y_axis);
    cam.rotateBody(dy, y_axis);
        }
  
  oldMouseX = mouseX;
  oldMouseY = mouseY;
}

void  drawSky() {
  background(0);
  noStroke();

  beginShape();
  fill(20,20,255);
  vertex(-width/2, -height/2);
  fill(20,20,255);
  vertex( width/2, -height/2);  
  fill(255,255,255);
  vertex( width/2,  0);  
  fill(255,255,255);
  vertex(-width/2,  0);  
      
  endShape();
  
    beginShape();
  fill(255,255,255);
  vertex(-width/2, 0);
  fill(255,255,255);
  vertex( width/2, 0);  
  fill(255,255,255);
  vertex( width/2,  height/2);  
  fill(255,255,255);
  vertex(-width/2,  height/2);  
      
  endShape();
    hint(DISABLE_DEPTH_TEST);
  hint(ENABLE_DEPTH_TEST);
  
}
////////////////////////////////////////////////////////////////////////////////

float time = 0;
float oldMouseX = 0;
float oldMouseY = 0;

void draw() {
  
  handleMouse();
 
  
  //println("test");
  time += 0.01;
  
  //background(128);
  

  translate(width/2,height/2); 
  drawSky();
  
  pushMatrix();
  //rotateZ(-PI/2);
  
  cam.update();
  cam.vel = cam.vel.scale(0.8);
  cam.offsetVel = cam.offsetVel.scale(0.8);
  cam.pqr = cam.pqr.scale(0.8);
  cam.apply();
  
  //drawGrid();
  land.draw();
  
  //translate(cam.pos.x,cam.pos.y,cam.pos.z);
  
  vehicle.pqr.x += 0.002*(noise(time)-0.5);
  vehicle.pqr.y += 0.001*(noise(1000+time)-0.5);  
  vehicle.pqr.z += 0.0011*(noise(2000+time)-0.5); 
  //vehicle.vel.x += 0.09*(noise(2000+time)-0.5);
  
  vehicle.update();
  //println(vehicle.vel.x + ", " +vehicle.pos.x);
  vehicle.draw();
  
  popMatrix();
}


void drawGrid() {
  float sc = 1;
   // draw grid
    int maxGridInd = 20;
    float spacing = 3000*sc;
    for (int i = 0; i < maxGridInd; i++) { 
      stroke(220,130,5);
      float xorz = i*spacing-  maxGridInd/2*spacing;
      line(-maxGridInd/2*spacing,50, xorz, maxGridInd/2*spacing,50, xorz);
      /// depth testing seems to be done only on the nearest part of the line, not each
      /// pixel
      stroke(120,190,5); 
      line(xorz, 50, -maxGridInd/2*spacing,  xorz, 50,maxGridInd/2*spacing);
  } 
}
