/** 
binarymillenium
GPL v3.0
June 2009

Dependencies
hypermedia udp library
http://ubaa.net/shared/processing/udp/

toxi geom library
http://toxiclibs.googlecode.com/files/toxiclibscore-0014.zip

*/
import hypermedia.net.*;
import processing.opengl.*;
import toxi.geom.*;


PFont font;

/// offline rendering
boolean offline = false;
boolean textHud = true;

body vehicle; 
movable cam;

terrain land;

float fov = PI/3;
float autoFov = 1.0;
boolean useAutoFov = true;

UDP udp;

/// these are arbitrary movable relative vectors to be drawn with
/// udp data
class movableVector {
  /// what part of the udp stream of floats the length data comes from
  int udpInd;
  color col;
  /// scale factor
  float sc;
  float scPos;
  /// arrow radius
  float rad;
  
  String name;
  
  Vec3D pos;
  Vec3D aim;
  //Quaternion rot;
  
  /// the current length, update by udp
  float len;

  ///////////////////////////// 
  //  draw text hud 
  void drawHud(Quaternion parentRot){ 
    pushMatrix();
                 
      
    applyMatrix( 1, 0, 0, (float)pos.x,  
                 0, 1, 0, (float)pos.y,  
                 0, 0, 1, (float)pos.z,  
                 0, 0, 0, 1  ); 
                                   applyMatrix( 1, 0, 0, (float)aim.x*scPos,  
                 0, 1, 0, (float)aim.y*scPos,  
                 0, 0, 1, (float)aim.z*scPos,  
                 0, 0, 0, 1  ); 

    Matrix4x4 m;         
    m = parentRot.getMatrix(); 
    applyMatrix( (float)m.matrix[0][0], (float)m.matrix[1][0], (float)m.matrix[2][0], 0,  
                 (float)m.matrix[0][1], (float)m.matrix[1][1], (float)m.matrix[2][1], 0,  
                 (float)m.matrix[0][2], (float)m.matrix[1][2], (float)m.matrix[2][2], 0,  
                 (float)m.matrix[0][3], (float)m.matrix[1][3], (float)m.matrix[2][3], 1  );   
               
               
    m = cam.rot.getMatrix(); 
    applyMatrix( (float)m.matrix[0][0], (float)m.matrix[0][1], (float)m.matrix[0][2], 0,  
                 (float)m.matrix[1][0], (float)m.matrix[1][1], (float)m.matrix[1][2], 0,  
                 (float)m.matrix[2][0], (float)m.matrix[2][1], (float)m.matrix[2][2], 0,  
                 (float)m.matrix[3][0], (float)m.matrix[3][1], (float)m.matrix[3][2], 1  );  
        if (textHud) {
                     scale(0.22);
                     String sa = nfs(len,4,1);
                     text(" " + name + "\n" + sa, 0,  50);
                   }              
    popMatrix();  
  }
  ////////////////////////////////
  
  void draw() {
    
     pushMatrix();
         
    applyMatrix( 1, 0, 0, (float)pos.x,  
                 0, 1, 0, (float)pos.y,  
                 0, 0, 1, (float)pos.z,  
                 0, 0, 0, 1  ); 
                     applyMatrix( 1, 0, 0, (float)aim.x*scPos,  
                 0, 1, 0, (float)aim.y*scPos,  
                 0, 0, 1, (float)aim.z*scPos,  
                 0, 0, 0, 1  ); 
                 
                 strokeWeight(2.0);
                 stroke(col);
                 //line(0,0,0, aim.x*scPos, aim.y*scPos, aim.z*scPos);
                 
                 /*{   /// TBD make text rotate to camera view    
                   pushMatrix();
                   
                   Vec3D aim = new Vec3D(parentPos.x - cam.pos.x, parentPos.y-cam.pos.y, parentPos.z-cam.pos.z);
                   Matrix4x4 m = pointMat(aim.getNormalized());  
                   applyMatrix( (float)m.matrix[0][0], (float)m.matrix[0][1], (float)m.matrix[0][2], 0,  
                           (float)m.matrix[1][0], (float)m.matrix[1][1], (float)m.matrix[1][2], 0,  
                           (float)m.matrix[2][0], (float)m.matrix[2][1], (float)m.matrix[2][2], 0,  
                           (float)m.matrix[3][0], (float)m.matrix[3][1], (float)m.matrix[3][2], 1  );
                     
                
                   popMatrix();
                 }*/
     popMatrix();

    pushMatrix();
    apply();    
    
    stroke(255,0,0);
    //line(0,0,0, 10, 0, 0);
    
    drawArrow(len*sc, rad, color(col) );
   
  
    popMatrix();
   
   

  }
  
   void apply() {
    
    applyMatrix( 1, 0, 0, (float)pos.x,  
                 0, 1, 0, (float)pos.y,  
                 0, 0, 1, (float)pos.z,  
                 0, 0, 0, 1  ); 
    applyMatrix( 1, 0, 0, (float)aim.x*scPos,  
                 0, 1, 0, (float)aim.y*scPos,  
                 0, 0, 1, (float)aim.z*scPos,  
                 0, 0, 0, 1  ); 
                    
    Matrix4x4 m = pointMat(aim);                 
      
    applyMatrix( (float)m.matrix[0][0], (float)m.matrix[0][1], (float)m.matrix[0][2], 0,  
                 (float)m.matrix[1][0], (float)m.matrix[1][1], (float)m.matrix[1][2], 0,  
                 (float)m.matrix[2][0], (float)m.matrix[2][1], (float)m.matrix[2][2], 0,  
                 (float)m.matrix[3][0], (float)m.matrix[3][1], (float)m.matrix[3][2], 1  );
               
    applyMatrix( 0, 1, 0, 0,  
                 0, 0, 1, 0,  
                 1, 0, 0, 0,
                 0, 0, 0, 1  );       
                 
    /*
    /// this one is wrong
    applyMatrix( (float)m.matrix[0][0], (float)m.matrix[1][0], (float)m.matrix[2][0], 0,  
                 (float)m.matrix[0][1], (float)m.matrix[1][1], (float)m.matrix[2][1], 0,  
                 (float)m.matrix[0][2], (float)m.matrix[1][2], (float)m.matrix[2][2], 0,  
                 (float)m.matrix[0][3], (float)m.matrix[1][3], (float)m.matrix[2][3], 1  );  
               
 */      
  }
}

////////////////////////////////////////////////////////

void setup() {
  size(800,600,P3D); 
  frameRate(15);
  
  font = loadFont("CourierNewPS-BoldMT-32.vlw");
  textFont(font, 32);
  
  udp = new UDP( this, 6100 );
  udp.listen(true); 
  
  vehicle = new body();
  vehicle.pos.x = 50;
  vehicle.pos.y = 50;
  vehicle.pos.z = 500;
  
  /// load config file
  String[] lines = loadStrings("config.txt");
  int index = 0;
  
  for (index = 0; index < lines.length; index++) {
    String[] pieces = split(lines[index], '\t');
    if ((pieces.length > 14) && (pieces[0].charAt(0) != '#')) {
      movableVector mv = new movableVector();
      mv.name = pieces[0];
      mv.udpInd = Integer.parseInt(pieces[1]);
      mv.col = color(int(pieces[2]), 
                         Integer.parseInt(pieces[3]), 
                         Integer.parseInt(pieces[4]) );
      mv.scPos = Float.valueOf(pieces[5]).floatValue();
      mv.sc = Float.valueOf(pieces[6]).floatValue();
      mv.rad = Float.valueOf(pieces[7]).floatValue();  
      mv.len = Float.valueOf(pieces[8]).floatValue();  
      
      mv.pos = new Vec3D( Float.valueOf(pieces[9]).floatValue()*mv.scPos ,
                          Float.valueOf(pieces[10]).floatValue()*mv.scPos ,
                          Float.valueOf(pieces[11]).floatValue()*mv.scPos );
                          
      mv.aim = new Vec3D( -Float.valueOf(pieces[12]).floatValue(),
                          -Float.valueOf(pieces[13]).floatValue(),
                          -Float.valueOf(pieces[14]).floatValue() );
                          
//      mv.rot = new Quaternion(Float.valueOf(pieces[11]).floatValue(),
//                  new Vec3D(Float.valueOf(pieces[12]).floatValue(),
//                            Float.valueOf(pieces[13]).floatValue(),
//                            Float.valueOf(pieces[14]).floatValue() ) );
  
      
      vehicle.movableVectors = (movableVector[]) append(vehicle.movableVectors, mv); 
     
     println("new movable vector " + vehicle.movableVectors[vehicle.movableVectors.length-1].name); 
    } else {
       println("not parsing line: " + lines[index]); 
    }
  }
  
  
  vehicle.rot = vehicle.rot.multiply(new Quaternion(cos(-PI/4),new Vec3D(0,0,sin(-PI/4))));
  
  cam = new movable();
  cam.target = vehicle;
  cam.posTracking = false;
  cam.togglePosTracking();
  cam.pos = new Vec3D(0,0,0);
  cam.offset = new Vec3D(0,100,300);
  //land = new terrain("G:/other/western_wa/ned_1_3_78184666/78184666");
  land = new terrain("78184666", "78184666.png");
 
  //land = new terrain("54112044","28660617.jpg");
}

//////////////////////////////////////////////////////

float increase(float x) {
     x += 5; 
       
   if (x > 0) cam.vel.x *= 1.2;
   else x *= 0.9;
   
   return x;
  
}

float decrease(float x) {
  x -= 5.1; 
       
  if (x < 0) x *= 1.2;
  else x *= 0.9;
  
  return x;
}

void keyPressed() {
 //if (keyPressed) {
   
    if (key == 'a') {
       Vec3D dir = rotateAxis(cam.rot, new Vec3D(1,0,0));
       cam.vel = cam.vel.add(dir.scale(10) );
       println(cam.offsetVel.x);
    }
    if (key == 'd') {
        Vec3D dir = rotateAxis(cam.rot, new Vec3D(-1,0,0));
       cam.vel= cam.vel.add(dir.scale(10) );
    }
    if (key == 'q') {
       Vec3D dir = rotateAxis(cam.rot, new Vec3D(0,1,0));
       cam.vel = cam.vel.add(dir.scale(10) );
    }
    if (key == 'z') {
       Vec3D dir = rotateAxis(cam.rot, new Vec3D(0,-1,0));
       cam.vel = cam.vel.add(dir.scale(10) ); 
    }
    if (key == 'w') {
       Vec3D dir = rotateAxis(cam.rot, new Vec3D(0,0,1));
       cam.vel = cam.vel.add(dir.scale(10) );
    }
    if (key == 's') {
       Vec3D dir = rotateAxis(cam.rot, new Vec3D(0,0,-1));
       cam.vel = cam.vel.add(dir.scale(10) );
    }    
    if (key == 'e') {
       cam.offsetVel.z = increase(cam.offsetVel.z); 
       println(cam.offset.z); 
    }
    if (key == 'c') {
      cam.offsetVel.z = decrease(cam.offsetVel.z);
      //println(cam.offset.z);
    }
    
    if (key == 'y') {
      cam.togglePosTracking();
    }
    if (key == 'u') {
      cam.toggleAttTracking();
    }
    if (key == 't') {
      cam.toggleAimTracking();
    }
    
    if (key == 'p') {
       useAutoFov = !useAutoFov; 
    }
    
    if (key == 'm') {
      fov *= 1.02; 
      
      if (fov > PI) fov = PI;
      println("fov " + fov*180.0/PI); 
    }
    if (key == 'n') {
      fov *= 0.98;
      println("fov " + fov*180.0/PI); 
    }
    
    if (key == 'b') {
      Vec3D dir = rotateAxis(vehicle.rot, new Vec3D(1,0,0));
      vehicle.vel = vehicle.vel.add(dir.scale( 13+ random(13.0)) );
      //println(vehicle.vel.x + ", " + vehicle.vel.y + ", " + vehicle.vel.z);    
    }
    
    if (key == 'h') {
       textHud = !textHud; 
    }
//}
}

void handleMouse() {
  if (mousePressed) {
    float dx = (mouseX - oldMouseX)/500.0;
    float dy = (mouseY - oldMouseY)/500.0;  
   
    if (mouseButton != CENTER ) {
      /*
      println("start " + cam.rot.toArray()[0] + " " + 
              cam.rot.toArray()[1] + " " + 
              cam.rot.toArray()[2] + " " +
              cam.rot.toArray()[3]  );*/
      
      //cam.rot = cam.rot.normalize();  
      /// the ordering is xyzw, not wxyz

      Vec3D axis;
      if (mouseButton == RIGHT) {
        axis = new Vec3D(0,0,-1);
        cam.rotateAbs(-dx, axis);
      } else {
        axis = new Vec3D(0,1,0);
        cam.rotateBody(dx, axis);
      }
      
      Vec3D y_axis = new Vec3D(-1,0,0);
      cam.rotateAbs(-dy, y_axis);
      //cam.rotateBody(-dy, y_axis);
    } else {
        Vec3D axis = new Vec3D(0,1,0);
        vehicle.rotateAbs(dy, axis);
        axis = new Vec3D(0,0,1);
        vehicle.rotateAbs(dx, axis);
       //vehicle.pqr.y += dx;
       //vehicle.pqr.x += dy;
     }
  } 

  oldMouseX = mouseX;
  oldMouseY = mouseY;
}

float clamp(float a, float b, float c) { 
	   return (a < b ? b : (a > c ? c : a)); 
} 
    
void drawGround() {
  float r = terrain.EARTH_CIRC_EQ;
  
  noStroke();
 //stroke(255,0,0);
 
  int maxInd = 64;
  pushMatrix();
   translate(-0, -1.00001*r, 0);
   //translate(-0, -1.1*r, 0);
   rotateX(-PI/2);
  for (int i = 0; i < maxInd; i++) {
      beginShape(TRIANGLE_STRIP); 
      float f1 = (float)i/(float)maxInd;
      float f2 = (float)(i+1)/(float)maxInd;
       float psi = f1*PI/64 + 31*PI/64;
       float psi2= f2*PI/64 + 31*PI/64;
     
       for (int j = 0; j <= maxInd; j++) {  
            float cdiv1 = 10.0*(psi/(PI/2)); 
            float cdiv2 = 10.0*(psi2/(PI/2));  
            
            float y = (j==maxInd)?0:j;
    
          float nval1 = noise(    i/cdiv1+1000,  y/cdiv1+1000);
          float nval2 = noise((i+1)/cdiv2+1000,  y/cdiv2+1000);
          float nval3 = noise(    i/cdiv1,       y/cdiv1);
          float nval4 = noise((i+1)/cdiv2,       y/cdiv2);
    
          color col1 = color(10,80*nval1,  200+55*nval3);
          color col2 = color(0, 80*nval2,  200+55*nval4);
           
          float theta = (float)j/(float)maxInd*2*PI;
          fill(lerpColor(col1, color(255,255,255), 1-f1*f1));
          vertex( r*cos(theta)*cos(psi),  r*sin(theta)*cos(psi),  r*sin(psi));// (float)j/(float)maxInd*100.0,     (float)i/(float)maxInd*100.0);
          fill(lerpColor(col2, color(255,255,255), 1-f2*f2));
          vertex( r*cos(theta)*cos(psi2), r*sin(theta)*cos(psi2), r*sin(psi2));// (float)(j)/(float)maxInd*100.0, (float)(i+1)/(float)maxInd*100.0);
        }
      
       endShape(); 
    }
  popMatrix();
 
  hint(DISABLE_DEPTH_TEST);
  hint(ENABLE_DEPTH_TEST);
}

void  drawSky() {
  background(0);
  noStroke();
  
  float h = clamp(-cam.pos.y/30e3,0,1);
  
    pushMatrix();
    
    translate(-cam.pos.x, -cam.pos.y, -cam.pos.z);
    if (cam.posTracking && (cam.target != null)) {
      translate(cam.target.pos.x, cam.target.pos.y, cam.target.pos.z);         
    }
    noStroke();
    //stroke(255,255,50);

    rotateX(-PI/2);
    
    float r = 1000.0;
    int maxInd = 24;
    
    for (int i = 0; i < maxInd; i++) {
      beginShape(QUAD_STRIP); 
      float f1 = (float)i/(float)maxInd;
      float f2 = (float)(i+1)/(float)maxInd;
      float psi = f1*PI-PI/2;
      float psi2= f2*PI-PI/2;
       
      color top = lerpColor(color(20,20,255), color(0,0,0), h );
      
//      f1 = (f1 > 0.5) ? (f1-0.5)*2 : 0;
//      f2 = (f2 > 0.5) ? (f2-0.5)*2 : 0;
//      f1 *= f1;
//      f2 *= f2;
      
      for (int j = 0; j <= maxInd; j++) {  
         float theta = (float)j/(float)maxInd*2*PI;
         fill(lerpColor( color(255,255,255), top, f1 ));
         vertex( r*cos(theta)*cos(psi),  r*sin(theta)*cos(psi),  r*sin(psi));// (float)j/(float)maxInd*100.0,     (float)i/(float)maxInd*100.0);
         fill(lerpColor( color(255,255,255), top, f2 ));
         vertex( r*cos(theta)*cos(psi2), r*sin(theta)*cos(psi2), r*sin(psi2));// (float)(j)/(float)maxInd*100.0, (float)(i+1)/(float)maxInd*100.0);
      }
      
       endShape(); 
    }
    // vertex( 10,  10, 0, 100, 100);
    // vertex(-10,  10, 0, 0,   100);

  
    popMatrix(); 
  /*
  beginShape();
  fill(lerpColor( color(20,20,255), color(0,0,0), clamp(-cam.pos.y/30e3,0,1) ));
  println("z " + cam.pos.y);
  vertex(-width/2, -height/2);
  fill(lerpColor( color(20,20,255), color(0,0,0), clamp(-cam.pos.y/30e3,0,1) ));
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
  */
  
  
hint(DISABLE_DEPTH_TEST);
hint(ENABLE_DEPTH_TEST);
  
}
////////////////////////////////////////////////////////////////////////////////

float time = 0;
float oldMouseX = 0;
float oldMouseY = 0;

int counter = 0;

void draw() {
  float tempFov = fov;
  if (cam.aimTracking && useAutoFov) tempFov*=autoFov;
  perspective(tempFov, float(width)/float(height), 1, 1e7);


  handleMouse();
 
  
  //println("test");
  time += 0.01;
  
  //background(128);
  
  /////// update

  //translate(cam.pos.x,cam.pos.y,cam.pos.z);
  
  if (offline) {
  vehicle.pqr.x += 0.008*(noise(time)-0.5);
  vehicle.pqr.y += 0.004*(noise(1000+time)-0.5);  
  vehicle.pqr.z += 0.0021*(noise(2000+time)-0.5); 
  Vec3D dir = rotateAxis(vehicle.rot, new Vec3D(1,0,0));
  vehicle.vel = vehicle.vel.add(dir.scale( 13+ noise(counter/100.0)) );
  }
  
  vehicle.vel = vehicle.vel.scale(0.95);
  vehicle.pqr.x *= 0.9;
  vehicle.pqr.y *= 0.9;
  vehicle.pqr.z *= 0.9; 
      
  
  vehicle.update();
  //println(vehicle.vel.x + ", " +vehicle.pos.x);
  
  cam.update();
  cam.vel = cam.vel.scale(0.9);
  cam.offsetVel = cam.offsetVel.scale(0.9);
  cam.pqr = cam.pqr.scale(0.8);
  ///////////////////////////////////////////
  // update
  
  /////////////////////////////////////////
  /// draw 
  pushMatrix();
  translate(width/2,height/2); 

  //background(128);
  /// the camera needs an applyInverse()
  cam.applyInv();
  drawSky();
  drawGround();
    //drawGrid();
  land.draw();

  //rotateZ(-PI/2);
 
  vehicle.draw();
  
  popMatrix();
  
  
    /// write text to screen
  
  
  if (textHud) {
    pushMatrix();
  hint(DISABLE_DEPTH_TEST);
  hint(ENABLE_DEPTH_TEST);
  perspective(PI/2, float(width)/float(height), 1, 1e7);
  //noStroke();
  translate(-width/4,-height/4); 

  stroke(128);
  fill(0,0,0);
  String sa;
  /// TBD handle arbitrary conversions like this x<->y better
  sa = nfs(vehicle.pos.y,6,1);
  text("X     " + sa, 0,  50);
  sa = nfs(vehicle.pos.x,6,1);
  text("Y     " + sa, 0,  80);
  sa = nfs(vehicle.pos.z,6,1);
  text("Z     " + sa, 0, 110);
  sa = nfs(vehicle.vel.y,6,1);
  text("dX/dt " + sa, 0, 140);
  sa = nfs(vehicle.vel.x,6,1);
  text("dY/dt " + sa, 0, 170);
  sa = nfs(vehicle.vel.z,6,1);
  text("dZ/dt " + sa, 0, 200);
  popMatrix();
  }
  
  if (offline) {
    counter++;
    if (counter > 200) {
      exit(); 
    }
  
    saveFrame("test-######.png");
  }
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
