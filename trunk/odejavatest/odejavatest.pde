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

boolean doSave = false;
 /// 30 fps * 60 seconds = 1800 frames max
 final static int COUNT_MAX = 2000;

float angle;

float now;

World world;
HashSpace space;
JavaCollision collision;
GeomSphere bomb;
boolean bombEnable = false;
float bombSize = 150;
JointGroup jointGroup;

creature theCreature;

int wd = 20;
float spc = 60;
float[] heights;
float[] indices;
 
 float tme = 0;
 
int count = 0;
int rollCount = 0;



 
void setup() {
   size(640,480,P3D); 
   frameRate(50);
   
   now = millis();
   
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
  
  initStuff();
}

void initStuff() {
     setupODE();
   
   bomb = new GeomSphere("bomb",bombSize);
   
   theCreature = new creature(5);
   tme = 0;
   
   noiseSeed(rollCount);
}

float zoff = -100;
float yoff=200;

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
  world.setGravity(0f, 0.5f, 0f);
  
  collision = new JavaCollision(world);
  collision.setSurfaceMu(5.0);
  
  jointGroup = new JointGroup();
  
 // GeomPlane groundGeom = new GeomPlane("plane",0, -1, 0, 0);        

  //GeomTriMesh terrain = new GeomTriMesh(heights, heights.length/3);
  //GeomTerrain terrain = new GeomTerrain(heights,100, 5);
  
  space = new HashSpace();        
 // space.add(groundGeom);
 
  //space.add(terrain);

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
    String name1 = geo1.getName();
    String name2 = geo2.getName();
    
    if ((name1.equals("bomb")) || (name2.equals("bomb"))) {
      contact.setSoftErp(0);
      contact.setSoftCfm(1);
      contact.setBounce(1.25);
      //contact.ignoreContact();  // this works
    }
    
    //if ((name1.charAt(name1.length()-1) == name2.charAt(name2.length()-1) )) {
    if (name1.equals("plane") || name2.equals("plane") ) {
      if ((match(name1,str(creature.arm.NUM_BOXES-1)) == null) && (match(name2,str(creature.arm.NUM_BOXES-1)) ==null)) {
        contact.ignoreContact();
      }
      
    }else {
      contact.ignoreContact();
      //println(name1 + " " + name2);
      
    }
    
  }
  
  theCreature.update();
  
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
 
  ambientLight(20,20,20);
  translate(width/2,height/2+yoff,zoff);
  
  rotateY(angle);
  //lightSpecular(100,100,100);//,-1.0,0.4,0);
  //shininess(2.9);
   directionalLight(155,155,255,1,0.4,0 );
   pointLight(255,95,55,0,0,0 );
  if (bombEnable) {
   sphere(bombSize);
     space.remove(bomb);
    bombEnable = false; 
  }
  
  //draw ground
  //drawGrid();
  //drawGround();
  
  theCreature.draw();
  
  
  popMatrix();
  
  if (doSave) {
  //print(millis()-now + " ");
  /// capture zbuffer
  PGraphics3D p3 = (PGraphics3D) g;
  
  /*
  /// this is really slow
  String path = savePath("zbuffer_" + count);
  FileOutputStream fos;
  try {
    fos = new FileOutputStream(path);
      DataOutputStream dos = new DataOutputStream(fos);
  for (int i = 0; i < p3.zbuffer.length; i++) {
   
    dos.writeFloat(p3.zbuffer[i]); 
  }
  fos.close();
  } catch (IOException e) {
    println(e);
  }
  */
  
  String binfilename = "data/zbuffer_" + count + ".bin";
  String imgfilename = "data/image_" + count + ".png";
  byte[] loadedBin = loadBytes(binfilename);
  PImage loadedImg = loadImage(imgfilename);
  
  float[] binZbuffer = new float[p3.zbuffer.length];
     
  if ((loadedBin == null) || (loadedImg == null) || (rollCount == 0)) {
   // println("first pass " + count); 
    binZbuffer = p3.zbuffer;
  } else {   
    loadPixels();
     /// aggregate
     /// TBD could we manipulate zbuffer before drawing, and skip
     /// this manual step?
  
     for (int i = 0; i < loadedBin.length; i += 4) {
       int accum =  ((loadedBin[i+3]&0xff) << 24) | 
                    ((loadedBin[i+2]&0xff) << 16) | 
                    ((loadedBin[i+1]&0xff) << 8) | 
                     (loadedBin[i+0]&0xff);
    
       //int accum = ((b[i]&0xff <<24) | (b[i+1]<<16) | (b[i+2]<<8) | b[i+3];
  
       //aZbuffer[i/4] 
      
       int zind = i/4;
       binZbuffer[zind] = Float.intBitsToFloat(accum);
       if (binZbuffer[zind] > p3.zbuffer[zind]) {
         // the current pixel value is in front. update the aggregate
         binZbuffer[zind] = p3.zbuffer[zind]; 
       } else {
         /// the aggregate value is in front
         pixels[zind] = loadedImg.pixels[zind];
       } 
      } // for loadedbin
    updatePixels();
    
    }  /// loaded bin and img 
      
    /// now save new aggregate zbuffer
    byte[] txb = new byte[binZbuffer.length*4]; 
    for (int i = 0; i < binZbuffer.length; i++) {
      int bits = Float.floatToIntBits(binZbuffer[i]);
      txb[i*4+0] = (byte) ((bits >> 0)  & 0xff);
      txb[i*4+1] = (byte) ((bits >> 8)  & 0xff);
      txb[i*4+2] = (byte) ((bits >> 16) & 0xff);
      txb[i*4+3] = (byte) ((bits >> 24) & 0xff);
    }
    
    //print(millis()-now + " ");
    saveBytes(binfilename, txb);
    //print(millis()-now + "\n");
    
    //try {
      saveFrame(imgfilename);
    ///} catch (FileNotFoundException e) {
     //  println(e); 
    //}
  } /// doSave
  
  count++;
  
  if (count > COUNT_MAX) {
    count = 0; 
    rollCount++;
    println("rollover " + rollCount);
    cleanupOde();
    initStuff();
  }
}








