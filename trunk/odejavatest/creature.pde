
class creature {
  
Body main;
arm[] arms;

creature(final int numArms) {
    main = new Body("boxroot",world, new GeomBox(20,20,20));
  main.adjustMass(1);    
    
  float x = 0;// (20+boxes.length)/2*random(-1,1);
  float y = -150;//-50 + random(-2*boxes.length,0);
  float z = 20;//(20+boxes.length)/2*random(-1,1);
  main.setPosition(x,y,z);
  main.setLinearVel(0,0,0); 
  space.addBodyGeoms(main);
  
 arms = new arm[numArms];
  for (int i = 0; i < arms.length; i++) {
    float angle = PI*0.3 +(float)i/(float)arms.length*2*PI;
    arms[i] = new arm(angle, main, x+10*cos(angle),y,z + 10*sin(angle));  
    
    
  } 
  

}
void update() {
   for (int i = 0; i < arms.length; i++) {
    arms[i].update(); 
  } 
}

void draw() {
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
    fill(100,100,255);
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
   
}

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
  color[] cols;
  
  void reset() {
    
  }
  
  arm(float angle, Body main, float x, float y, float z) {
    this.angle = angle;
    boxes = new Body[NUM_BOXES];
    names = new String[NUM_BOXES];
    boxNames = new String[NUM_BOXES];
    
    vrt  = new Vector3f[NUM_CIRC*NUM_BOXES];
    snrm = new Vector3f[NUM_CIRC*NUM_BOXES];
    cols = new color[NUM_CIRC*NUM_BOXES];
    
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
      boxes[i] = new Body(boxNames[i], world, new GeomBox(sz*0.99,sz*0.99,sz*0.99));
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
        //println(names[i] + " " + ay + " " + az);
      
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
      float mix = 0.85;
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
    
    if (mvel < 0) velf -= (0.0001 + 0.0001*noise(tme+1000))*abs(mvel);
    if (mvel > 0) velf += (0.0001 + 0.0001*noise(tme+2000))*abs(mvel);
    
    if (velf > 0.4) velf = 0.3;
    if (velf < 0) velf = 0;
    //println(mvel + "  " + velf);
  
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
        fill(cols[ind1]);
        vertex(vrt[ind1].x, vrt[ind1].y, vrt[ind1].z);
        if (snrm[ind2] != null) normal(snrm[ind2].x,snrm[ind2].y,snrm[ind2].z);
        fill(cols[ind2]);
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
      
      vrt[ind*NUM_CIRC+i]  = new Vector3f(pos.x + mixa.x, pos.y + mixa.y, pos.z + mixa.z);  
      
      color c1 = color(100,100,255);
      color c2 = color(255,255,255);
      cols[ind*NUM_CIRC+i] = lerpColor(c1,c2, (float)ind/(float)NUM_BOXES);
      // fill(c);
      //vertex(pos.x    + mixa.x, pos.y   + mixa.y, pos.z    + mixa.z); 
      //fill(oldc);
      //vertex(oldpos.x + mixb.x, oldpos.y+ mixb.y, oldpos.z + mixb.z); 
    }  
  }
  
  
};


};
