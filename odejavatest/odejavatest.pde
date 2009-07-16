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

World world;
HashSpace space;
JavaCollision collision;
GeomSphere bomb;
boolean bombEnable = false;
float bombSize = 150;
JointGroup jointGroup;

Body main;
arm[] arms;

class arm {
  final static int NUM_BOXES = 5;
  final static int NUM_CIRC = 25;
  Body[] boxes;
  
  float angle;
  String[] names;
  String[] boxNames;
  
  /// vectors that make up the arm
  Vector3f[] vrt;
  /// surface norms
  Vector3f[] snrm;  
  
  arm(float angle, Body main, float x, float y, float z) {
    this.angle = angle;
    boxes = new Body[NUM_BOXES];
    names = new String[NUM_BOXES];
    boxNames = new String[NUM_BOXES];
    
    vrt  = new Vector3f[NUM_CIRC*NUM_BOXES];
    snrm = new Vector3f[NUM_CIRC*NUM_BOXES];
    
    float dx = 11;
    float dy = 2;
    float newx = 0;
    float newy = 0;
    
    for (int i = 0; i <boxes.length; i++) { 
      newx += dx;
      newy += 0;//dy;
      
      float px = x + cos(angle)*newx + sin(angle)*newy;
      float py = y;
      float pz = z + cos(angle)*newy + sin(angle)*newx;
      
      float fr = (1.0 - 0.99*(float)i/(float)boxes.length);
      float sz = 15.0*fr;
      
      String postfix = (int)(angle/PI*180.0)+ "_" + i;
      boxNames[i] = "box_" + postfix;
      boxes[i] = new Body(boxNames[i],world, new GeomBox(sz*0.99,sz*0.99,sz*0.99));
      boxes[i].adjustMass(0.8*fr);    
      boxes[i].setPosition(px, py, pz);
      boxes[i].setQuaternion(new Quat4f(0,sin(-angle/2),0,cos(-angle/2)));
      boxes[i].setLinearVel(0,0,0);
  
      names[i] = "hinge_" + postfix;
     
        JointUniversal jh = new JointUniversal(names[i], world, jointGroup);
        
        if (i > 0) { 
          jh.attach(boxes[i-1], boxes[i]);
        } else {
          jh.attach(main, boxes[i]);
        }
        
        jh.setAnchor(px, py, pz);
        
        float ay;
        ay = sin(angle);
        float az;
        az = cos(angle);
        jh.setAxis1(-ay,0,az);
        
        jh.setAxis2(az,0,ay);
        println(names[i] + " " + ay + " " + az);
      
        jh.setParam(Ode.dParamLoStop,  -PI/4);
        jh.setParam(Ode.dParamHiStop,  PI/4);
        jh.setParam(Ode.dParamLoStop2, -PI/10);
        jh.setParam(Ode.dParamHiStop2,  PI/10);
        jh.setParam(Ode.dParamBounce,  1.0);
        jh.setParam(Ode.dParamStopERP, 0.01f);
        jh.setParam(Ode.dParamStopCFM, 0.99f);
      
        jh.setParam(Ode.dParamFMax, 1000); 
    }
    
    /*
    for (int i = 0; i <boxes.length; i++) {
      space.addBodyGeoms(boxes[i]);
    }*/
     space.addBodyGeoms(boxes[boxes.length-1]);
  }
  
  float velf = 0.20;
  
  void update() {

    int iMax = int(NUM_BOXES);
    for (int i = 0; i < iMax; i++ ) {
      float fr = 1.0-(float)i/(float)iMax;
      float mix = 0.65;
      float vel = velf*(mix*sin(tme*4) + (1.0-mix)*(noise(tme+i*1000+angle*1000)-0.5)) ;  
      //if (vel > 0) vel*=2;
      JointUniversal joint = (JointUniversal)jointGroup.getJoint(names[i]);
      if (joint != null) {
        //println("vel " + vel);
        joint.setParam(Ode.dParamVel, -vel*(1.0 - i/iMax) );
        
        if (vel > 0) {
          Body part = world.getBody(boxNames[i]);
          
          Matrix3f rot = new Matrix3f();
          part.getRotation(rot);
    
          float f = -1.5*fr*vel*((GeomBox) part.getGeom()).getLengths()[0];
          //println(rot.m10 + " " + rot.m11 + " " + rot.m12);
          part.addForce(f*rot.m01, f*rot.m11, f*rot.m21); 
        }
      } 
    }
    Vector3f frc = main.getForce();
    //println(angle + " " + frc.x + " " + frc.y + " " + frc.z);
    
    
    float mvel = main.getLinearVel().y;
    
    if (mvel < 0) velf -= (0.0002*noise(tme+1000))*abs(mvel);
    if (mvel > 0) velf += (0.0002*noise(tme+2000))*abs(mvel);
    
    if (velf > 0.4) velf = 0.3;
    if (velf < 0) velf = 0;
    println(mvel + "  " + velf);
  
    for (int i = 1; i < NUM_BOXES; i++ ) {
      JointUniversal joint = (JointUniversal)jointGroup.getJoint("hinge" + i);
      //joint.setDesiredAngularVelocity2(0);
      if (joint != null) { 
        joint.setParam(Ode.dParamVel2, 0);
      }
    } 
  }
  
  void draw() {
     /// draw boxes
     //stroke(255,255,0);
     noFill();
     //strokeWeight(5.0);
    // beginShape();
     
     float[] oldposf = new float[3];
     //main.getPosition(oldposf);
     boxes[0].getPosition(oldposf); 
     Vector3f oldpos = new Vector3f(oldposf);
     Matrix3f oldrot = new Matrix3f();
     boxes[0].getRotation(oldrot);
     float oldf = ((GeomBox) main.getGeom()).getLengths()[0]/2;
     
     color oldc = color(255.0, 0.0, 0.0 );
     
    for (int i = 0; i <boxes.length; i++) {
      pushMatrix();
     // noStroke();
  
      float posf[] = new float[3];
      boxes[i].getPosition(posf);  
      Vector3f pos = new Vector3f(posf);
      
      Matrix3f rot = new Matrix3f();
      boxes[i].getRotation(rot);

      float sz = ((GeomBox) boxes[i].getGeom()).getLengths()[0]/2;
      
      color c = color(255.0, 255.0*i/(float)boxes.length, 0.0 );
      vertex(posf[0], posf[1], posf[2]);
      float f = ((GeomBox) boxes[i].getGeom()).getLengths()[0]/2;
      
      updateLimb(rot, oldrot, pos, oldpos, f, oldf, c, oldc, i);
   
      oldpos = pos;
      oldrot = rot;
      oldf = f;
      oldc = c;
      //vertex(posf[0], posf[1], posf[2]);

      //println(sz + " " + dx);  */
      
        /*   
      translate(posf[0], posf[1], posf[2]);
      
      applyMatrix(rot.m00, rot.m01, rot.m02, 0.0,
                  rot.m10, rot.m11, rot.m12, 0.0,
                  rot.m20, rot.m21, rot.m22, 0.0,
                  0.0,     0.0,     0.0,     1.0);
           */       
      /* // this comes out inverted
      applyMatrix(rot.m00, rot.m11, rot.m20, 0.0,
                  rot.m01, rot.m11, rot.m21, 0.0,
                  rot.m02, rot.m12, rot.m22, 0.0,
                  0.0,     0.0,     0.0,     1.0);*/
      //drawBox(f);
   
      popMatrix();  
      
    } 
    
    for (int i = 1; i <boxes.length; i++) {
      fill(255,0,0);
      //specular(255,255,255);
      noStroke();
      beginShape(QUAD_STRIP);
      for (int j = 0; j <= NUM_CIRC; j++) { 
        int ind1 = (i-1)*NUM_CIRC+(j%NUM_CIRC);
        int ind1l = (i-1)*NUM_CIRC+((j-1)%NUM_CIRC);
        int ind1r = (i-1)*NUM_CIRC+((j+1)%NUM_CIRC);
        int ind1u = (i-2)*NUM_CIRC+(j%NUM_CIRC);
        int ind1d = (i)*NUM_CIRC+(j%NUM_CIRC);
        
        int ind2 = (i)*NUM_CIRC+(j%NUM_CIRC);
        int ind2l = (i)*NUM_CIRC+((j-1)%NUM_CIRC);
        int ind2r = (i)*NUM_CIRC+((j+1)%NUM_CIRC);
        int ind2u = (i-1)*NUM_CIRC+(j%NUM_CIRC);
        int ind2d = (i+1)*NUM_CIRC+(j%NUM_CIRC);
        
        Vector3f n1 = getNormal(ind1,ind1l,ind1r,ind1u, ind1d);
        Vector3f n2 = getNormal(ind2,ind2l,ind2r,ind1u, ind2d);
        if(n1 != null) snrm[ind1] = n1;
        if (n2 != null)snrm[ind2] = n2;
        
        if (snrm[ind1] != null) normal(snrm[ind1].x,snrm[ind1].y,snrm[ind1].z);
        vertex(vrt[ind1].x, vrt[ind1].y, vrt[ind1].z);
        if (snrm[ind2] != null) normal(snrm[ind2].x,snrm[ind2].y,snrm[ind2].z);
        vertex(vrt[ind2].x, vrt[ind2].y, vrt[ind2].z);
      }
      endShape();
    }
    
    
    if (false) {
    for (int i = 0; i < snrm.length; i++) {
      stroke(0,255,0);
      if ((vrt[i] != null) && ( snrm[i] != null)) {
        //println(snrm[i].x + " " + snrm[i].y + " " + snrm[i].z);
        float sc = 4;
       line(vrt[i].x, vrt[i].y, vrt[i].z, 
            vrt[i].x + sc*snrm[i].x, vrt[i].y + sc*snrm[i].y, vrt[i].z + sc*snrm[i].z);
      }
    }
    }
    
  }
  
  
  
  Vector3f getNormal(int ind1, int ind1l, int ind1r, int ind1u, int ind1d) {
    Vector3f rv = new Vector3f();
    

    if ((ind1 < 0) || (ind1 >= vrt.length)) {
        return null;
    } 
    if ((ind1l < 0) || (ind1l >= vrt.length)) {
        return null;
    } 
    if ((ind1r < 0) || (ind1r >= vrt.length)) {
        return null;
    } 
    if ((ind1u < 0) || (ind1u >= vrt.length)) {
        return null;
    } 
    if ((ind1d < 0) || (ind1d >= vrt.length)) {
        return null;
    } 
    
         Vector3f v1 = vrt[ind1];
         Vector3f vl = vrt[ind1l];
         Vector3f vr = vrt[ind1r];
         Vector3f vu = vrt[ind1u];
         Vector3f vd = vrt[ind1d];
         
         Vector3f nl = new Vector3f(v1);
         Vector3f nr = new Vector3f(v1);
         Vector3f nu = new Vector3f(v1);
         Vector3f nd = new Vector3f(v1);     
         nl.sub(vl);
         nr.sub(vr);
         nu.sub(vu);
         nd.sub(vd);
         
         
         Vector3f nrm1 = getNorm(nl,nu);
         Vector3f nrm2 = getNorm(nu,nr);
         Vector3f nrm3 = getNorm(nr,nd);
         Vector3f nrm4 = getNorm(nd,nl);
         
         /*
         Vector3f nrm1 = getNorm(nu,nl);
         Vector3f nrm2 = getNorm(nr,nu);
         Vector3f nrm3 = getNorm(nd,nr);
         Vector3f nrm4 = getNorm(nl,nd);
         */
         
         /*
         println("face 1 " + nrm1.x + " " + nrm1.y + " " + nrm1.z);
         println("face 2 " + nrm2.x + " " + nrm2.y + " " + nrm2.z);
         println("face 3 " + nrm3.x + " " + nrm3.y + " " + nrm3.z);
         println("face 4 " + nrm4.x + " " + nrm4.y + " " + nrm4.z);
         */
         
         
         nrm1.add(nrm2);
         nrm1.add(nrm3);
         nrm1.add(nrm4);
         nrm1.normalize();
 
         return nrm1;
   
  }
  
  Vector3f getNorm(Vector3f v1, Vector3f v2) {
    Vector3f rv = new Vector3f();
    
    rv.cross(v1,v2);
    rv.normalize();

    
    return rv;
  }
  
  /// get vector positiosn
  void updateLimb(final Matrix3f rot, final Matrix3f oldrot, 
                final Vector3f pos, final Vector3f oldpos,
                final float f, final float oldf, 
                final color c, final color oldc, 
                final int ind) {
    
    Vector3f ax = new Vector3f( f*rot.m01, f*rot.m11, f*rot.m21);
    Vector3f ay = new Vector3f( f*rot.m02, f*rot.m12, f*rot.m22);
    //Vector3f bx = new Vector3f(oldf*oldrot.m01, oldf*oldrot.m11, oldf*oldrot.m21); 
    //Vector3f by = new Vector3f(oldf*oldrot.m02, oldf*oldrot.m12, oldf*oldrot.m22); 
    beginShape(QUAD_STRIP);
    for (int i = 0; i < NUM_CIRC; i++) {
      float fr = (float)i/(float)NUM_CIRC;
      float angle = 2.0*PI*fr;
      float ca = cos(angle);
      float sa = sin(angle);
      Vector3f mixa = new Vector3f(ax.x*ca + ay.x*sa, ax.y*ca + ay.y*sa, ax.z*ca + ay.z*sa);
      //Vector3f mixb = new Vector3f(bx.x*ca + by.x*sa, bx.y*ca + by.y*sa, bx.z*ca + by.z*sa);
      //color newc = lerpColor(oldc,c,fr);
      
      vrt[ind*NUM_CIRC+i] = new Vector3f(pos.x + mixa.x, pos.y + mixa.y, pos.z + mixa.z);  
      
      // fill(c);
      //vertex(pos.x    + mixa.x, pos.y   + mixa.y, pos.z    + mixa.z); 
      //fill(oldc);
      //vertex(oldpos.x + mixb.x, oldpos.y+ mixb.y, oldpos.z + mixb.z); 
    }  
  }
  
  
};



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
  world.setGravity(0f, 0.5f, 0f);
  
  collision = new JavaCollision(world);
  collision.setSurfaceMu(5.0);
  
  jointGroup = new JointGroup();
  
  main = new Body("boxroot",world, new GeomBox(20,20,20));
  main.adjustMass(1);    
    
  float x = 0;// (20+boxes.length)/2*random(-1,1);
  float y = -150;//-50 + random(-2*boxes.length,0);
  float z = 20;//(20+boxes.length)/2*random(-1,1);
  main.setPosition(x,y,z);
  main.setLinearVel(0,0,0); 
  

  
  GeomPlane groundGeom = new GeomPlane("plane",0, -1, 0, 0);        
  

  GeomTriMesh terrain = new GeomTriMesh(heights, heights.length/3);
  //GeomTerrain terrain = new GeomTerrain(heights,100, 5);
  
  space = new HashSpace();        
  space.add(groundGeom);
  
  space.addBodyGeoms(main);
  //space.add(terrain);
  
  arms = new arm[5];
  for (int i = 0; i < arms.length; i++) {
    float angle = PI*0.3 +(float)i/(float)arms.length*2*PI;
    arms[i] = new arm(angle, main, x+10*cos(angle),y,z + 10*sin(angle));  
    
    
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
      if ((match(name1,str(arm.NUM_BOXES-1)) == null) && (match(name2,str(arm.NUM_BOXES-1)) ==null)) {
        contact.ignoreContact();
      }
      
    }else {
      contact.ignoreContact();
      //println(name1 + " " + name2);
      
    }
    
  }
  
  for (int i = 0; i < arms.length; i++) {
    arms[i].update(); 
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
 
  ambientLight(80,80,80);
  translate(width/2,3*height/4+yoff,zoff);
  
  rotateY(angle);
  //lightSpecular(100,100,100);//,-1.0,0.4,0);
  //shininess(2.9);
   directionalLight(255,255,180,1,0.4,0 );
   
  if (bombEnable) {
   sphere(bombSize);
     space.remove(bomb);
    bombEnable = false; 
  }
  
  

  //draw ground
  drawGrid();
  //drawGround();
   pushMatrix();
      noStroke();
  
      float pos[] = new float[3];
      main.getPosition(pos);
      translate(pos[0], pos[1], pos[2]);
      
      Matrix3f rot = new Matrix3f();
      main.getRotation(rot);
      applyMatrix(rot.m00, rot.m01, rot.m02, 0.0,
                  rot.m10, rot.m11, rot.m12, 0.0,
                  rot.m20, rot.m21, rot.m22, 0.0,
                  0.0,     0.0,     0.0,     1.0);
  
      float [] sz = ((GeomBox) main.getGeom()).getLengths();
      //drawBox(sz[0]/2);
   
      popMatrix();  
      
  for (int i = 0; i < arms.length; i++) {
    arms[i].draw(); 
  }
  //
  
  if (true) {
  for (int i = 0; i < arms.length; i++) {
    fill(255,0,0);
    noStroke();
    beginShape(QUAD_STRIP);
    for (int j = 0; j <= arm.NUM_CIRC; j++) {
      Vector3f v1 = arms[i].vrt[j%arm.NUM_CIRC];
      Vector3f v2 = arms[(i+1)%arms.length].vrt[(arm.NUM_CIRC-j)%arm.NUM_CIRC];
      vertex(v1.x,v1.y,v1.z);
      vertex(v2.x,v2.y,v2.z);
    }
    endShape();
  }
  }
  /*
  
  if (false) {
  {beginShape();
   Vector3f v1 = arms[0].vrt[arm.NUM_CIRC/2];
   Vector3f v2 = arms[1].vrt[arm.NUM_CIRC/2];
   Vector3f v3 = arms[2].vrt[arm.NUM_CIRC/2];
   Vector3f v4 = arms[3].vrt[arm.NUM_CIRC/2];
   vertex(v1.x,v1.y,v1.z);
   vertex(v2.x,v2.y,v2.z);
   vertex(v3.x,v3.y,v3.z);
   vertex(v4.x,v4.y,v4.z);
   vertex(v1.x,v1.y,v1.z);
   endShape();
  } 
  {
   beginShape();
   Vector3f v1 = arms[0].edge[1];
   Vector3f v2 = arms[1].edge[1];
   Vector3f v3 = arms[2].edge[1];
   Vector3f v4 = arms[3].edge[1];
   vertex(v1.x,v1.y,v1.z);
   vertex(v2.x,v2.y,v2.z);
   vertex(v3.x,v3.y,v3.z);
   vertex(v4.x,v4.y,v4.z);
   vertex(v1.x,v1.y,v1.z);
   endShape();
  }
  }
  */
  
  
  
  popMatrix();
}








