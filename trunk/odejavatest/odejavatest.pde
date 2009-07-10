/**
binarymillenium July 2009
GNU GPL v3.0
odejava libs https://odejava.dev.java.net/

https://odejava.dev.java.net/files/documents/1109/8349/2004-10-30_windows.zip
https://odejava.dev.java.net/files/documents/1109/27450/odejava-2006-01-15_cvs.tar.gz

unzip/untar both.

Create a processing folder/libraries/odejava dir, and library subdir to that.

Move the uncompressed odejava/odejava.jar and odejava/lib/* into it

Copy odejava.dll from windows/release into the the libraries/odejava/library dir.
*/

//import org.odejava.display.*;
import org.odejava.*;
import org.odejava.collision.*;
import org.odejava.ode.*;
import javax.vecmath.*;


float angle;
Body[] boxes;
World world;
HashSpace space;
JavaCollision collision;
GeomSphere bomb;
boolean bombEnable = false;
float bombSize = 150;
JointGroup jointGroup;

final int NUM_BOXES = 13;

int wd = 20;
float spc = 60;
float[] heights;
float[] indices;
 
 float tme = 0;
 
void setup() {
   size(500,500,P3D); 
   frameRate(50);
   
  heights =  new float[wd*wd*18]; /// wd*wd*3*2 vertices, each made of 3 floats

  float offset = wd*spc/2;
  float hgt = 450;
  float div1 = 28;
  float div2 = 20;
  // noise produces repeatable values for same parameters over runtime of 
  // sketch
  for (int i = 0; i < wd; i++) {
  for (int j = 0; j < wd; j++) {  
    int ind = (i*wd+j)*18;

    /// build triangles clockwise
    heights[ind+0] = i*spc-offset;
    heights[ind+1] = hgt*noise(i/div1, j/div2)-hgt;    
    heights[ind+2] = j*spc-offset;
    
    ind+=3;
    heights[ind+0] = i*spc-offset;
    heights[ind+1] = hgt*noise(i/div1, (j+1)/div2)-hgt;    
    heights[ind+2] = (j+1)*spc-offset;

    ind +=3;
    heights[ind+0] = (i+1)*spc-offset;
    heights[ind+1] = hgt*noise((i+1)/div1, j/div2)-hgt;    
    heights[ind+2] = j*spc-offset;
    
    /// opposite triangle
    ind +=3;
    heights[ind+0] = i*spc-offset;
    heights[ind+1] = hgt*noise(i/div1, (j+1)/div2)-hgt;    
    heights[ind+2] = (j+1)*spc-offset;
    
    ind+=3;
    heights[ind+0] = (i+1)*spc-offset;
    heights[ind+1] = hgt*noise((i+1)/div1, (j+1)/div2)-hgt;    
    heights[ind+2] = (j+1)*spc-offset;

    ind +=3;
    heights[ind+0] = (i+1)*spc-offset;
    heights[ind+1] = hgt*noise((i+1)/div1, j/div2)-hgt;    
    heights[ind+2] = j*spc-offset;
  }}
  
  /*
  indices = new float[(wd-1)*(wd-1)*2];
  for (int i = 0; i < wd-1; i++) {
  for (int j = 0; j < wd-1; j++) { 
    //int ind = (i*wd+j)*3;
  }}*/
  
   setupODE();
   
   bomb = new GeomSphere("bomb",bombSize);
   
}

float zoff;
float yoff=10;

void drawGround() {
  pushMatrix();
  noStroke();
  fill(100,100,50);
  beginShape(TRIANGLES);
  for (int i = 0; i < heights.length; i+=3) {
    vertex(heights[i], heights[i+1], heights[i+2]);
  }
  endShape();
  popMatrix();
}

void drawGrid() {
   pushMatrix();
  stroke(150);
  strokeWeight(2.0);
  float sz = 100;
  fill(200);
  float maxi = 40;
  translate(-maxi*sz/2,0,-maxi*sz/2);
  for (int j = 0; j < maxi; j++) {
    beginShape(QUAD_STRIP);
    for (int i = 0; i < maxi; i++) {
    vertex(j*sz -sz, 0.0, i*sz );
    vertex(j*sz +sz, 0.0, i*sz );
    }
    endShape();
  }
  popMatrix(); 
}

void drawBox(float sz) {
  //noStroke();
  fill(255.0, 0.0, 0.0 );
   beginShape(QUAD_STRIP);
    vertex( -sz, sz,-sz );
    vertex(  sz, sz,-sz );
    vertex( -sz, sz, sz );
    vertex(  sz, sz, sz );
    vertex( -sz,-sz, sz );
    vertex(  sz,-sz, sz );
    vertex( -sz,-sz, -sz );
    vertex(  sz,-sz, -sz );
    vertex( -sz, sz, -sz );
    vertex(  sz, sz, -sz );
  endShape();
  
  beginShape(QUAD_STRIP);
    vertex(  sz, -sz, -sz );
    vertex(  sz,  sz, -sz );
    vertex(  sz, -sz, sz );
    vertex(  sz,  sz, sz );

  endShape();
  
  beginShape(QUAD_STRIP);
    vertex(  -sz, -sz, -sz );
    vertex(  -sz,  sz, -sz );
    vertex(  -sz, -sz,sz );
    vertex(  -sz,  sz, sz );

  endShape();
}

void cleanupOde() 
{
  space.delete();
  collision.delete();
  world.delete();
  Ode.dCloseODE();
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
    
void setupODE()
{
  Odejava.init();
  world = new World();
  world.setGravity(0f, 2.5f, 0f);
  
  collision = new JavaCollision(world);
  collision.setSurfaceMu(5.0);
  
  jointGroup = new JointGroup();
  
  boxes= new Body[NUM_BOXES];
  
  boxes[0] = new Body("rootbox",world, new GeomBox(20,20,20));
  boxes[0].adjustMass(1);    
    
  float x = 20;// (20+boxes.length)/2*random(-1,1);
  float y = -150;//-50 + random(-2*boxes.length,0);
  float z = 20;//(20+boxes.length)/2*random(-1,1);
  boxes[0].setPosition(x,y,z);
  boxes[0].setLinearVel(0,0,0); 

  float dx = 11;
  float dy = 2;
    float newx = x+dx;
  float newy = y;
    
  for (int i = 1; i <boxes.length; i++) { 
    newx += dx;
    newy += dy;
    
    float fr = (1.0 - 0.5*(float)i/(float)boxes.length);
    float sz = 15.0*fr;
    
    boxes[i] = new Body("box" + i,world, new GeomBox(sz,sz,sz));
    boxes[i].adjustMass(0.8*fr);    
    boxes[i].setPosition(newx,newy,z);
    boxes[i].setLinearVel(0,0,0);
    
    JointUniversal jh = new JointUniversal("hinge"+i, world,jointGroup);
    jh.attach(boxes[i-1], boxes[i]);
    jh.setAnchor(newx-dx/2, newy-dy/2, z);
    jh.setAxis1(0,0,1);
    jh.setAxis2(0,1,0);
    
    jh.setParam(Ode.dParamLoStop, -PI/3);
    jh.setParam(Ode.dParamHiStop,  PI/3);
    jh.setParam(Ode.dParamLoStop2, -PI/10);
    jh.setParam(Ode.dParamHiStop2,  PI/10);
    jh.setParam(Ode.dParamBounce,  1.0);
    jh.setParam(Ode.dParamStopERP, 0.1f);
    jh.setParam(Ode.dParamStopCFM, 0.2f);
    
    jh.setParam(Ode.dParamFMax, 1000);
  }
  
  GeomPlane groundGeom = new GeomPlane("plane",0, -1, 0, 0);        
  

  GeomTriMesh terrain = new GeomTriMesh(heights, heights.length/3);
  //GeomTerrain terrain = new GeomTerrain(heights,100, 5);
  
  space = new HashSpace();        
  space.add(groundGeom);
  //space.add(terrain);
  
  for (int i = 0; i <boxes.length; i++) {
    space.addBodyGeoms(boxes[i]);
  }
}
    

    
    ////////////////////////////////////////////////
    
    

void draw() {
  tme += 0.01;
  if (keyPressed) {
     if (key =='a') {
       angle += PI/100.0;
     } 
     if (key =='d') {
       angle -= PI/99.0;
     } 
     
     if (key =='q') {
       yoff += 10;
     } 
     if (key =='z') {
       yoff -= 9.0;
     } 
          if (key =='w') {
       zoff += 10;
     } 
     if (key =='s') {
       zoff -= 9.0;
     } 
     
     if (key == 'b') {
       println("bomb!");
       bombEnable = true;
       space.add(bomb);
     }
  }
  
 
  
  // update stuff
  collision.collide(space);
  
  Contact contact = new Contact( collision.getContactIntBuffer(),
        	collision.getContactFloatBuffer());
  for (int i = 0; i < collision.getContactCount(); i++) {
    contact.setIndex(i);
    Geom geo1 = contact.getGeom1();
    Geom geo2 = contact.getGeom2();
    /// TBD getName crashes when there is no name
    if ((geo1.getName().equals("bomb")) || (geo2.getName().equals("bomb"))) {
      contact.setSoftErp(0);
      contact.setSoftCfm(1);
      //contact.ignoreContact();  // this works
    }
  }


  float vel = 0.2*(2*sin(tme*4)+ (noise(tme)-0.5)/2.0) ;
  int iMax = int(NUM_BOXES/2);
  for (int i = 1; i < iMax; i++ ) {
        JointUniversal joint = (JointUniversal)jointGroup.getJoint("hinge" + i);
        if (joint != null) {
          //println("vel " + vel);
          joint.setParam(Ode.dParamVel, vel*(1.0 - i/iMax) );
          //joint.setDesiredAngularVelocity1(vel*(1.0-i/iMax));        
        }
  }
  
  for (int i = 1; i < NUM_BOXES; i++ ) {
    JointUniversal joint = (JointUniversal)jointGroup.getJoint("hinge" + i);
    //joint.setDesiredAngularVelocity2(0);
    joint.setParam(Ode.dParamVel2, 0);
  }
  
        /*
        Iterator iter = jointGroup.getJointList().iterator();
        if (iter.hasNext()) {
            joint = (JointHinge2) iter.next();
            */
            

  
  collision.applyContacts();
  world.step();

  /// draw
  background(0);
  pushMatrix();
  //lights();
 
  ambientLight(40,40,40);
  translate(width/2,3*height/4+yoff,zoff);
  
  rotateY(angle);
   directionalLight(255,255,180,1,0.4,0 );
  if (bombEnable) {
   sphere(bombSize);
     space.remove(bomb);
    bombEnable = false; 
  }

  //draw ground
  drawGrid();
  //drawGround();
  
  /// draw boxes
  for (int i = 0; i <boxes.length; i++) {
    pushMatrix();
    noStroke();

    float pos[] = new float[3];
    boxes[i].getPosition(pos);
    translate(pos[0], pos[1], pos[2]);
    
    Matrix3f rot = new Matrix3f();
    boxes[i].getRotation(rot);
    applyMatrix(rot.m00, rot.m01, rot.m02, 0.0,
                rot.m10, rot.m11, rot.m12, 0.0,
                rot.m20, rot.m21, rot.m22, 0.0,
                0.0,     0.0,     0.0,     1.0);

    float [] sz = ((GeomBox) boxes[i].getGeom()).getLengths();
    drawBox(sz[0]/2);
 
    popMatrix();  
  }
  
  popMatrix();
}








