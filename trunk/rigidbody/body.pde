/** 
binarymillenium
GPL v3.0
June 2009

*/

class movable {
  Vec3D pos;
  Vec3D vel;
  
  Vec3D[] posHistory;
  int counter = 0;
  int historyStart =0;
  int historyEnd = 0;
  int historySkip = 8;  // only update with every 4th new position
  int historyMax = 1000;
  
  /// udp stuff
  boolean rxUdp;
  Vec3D newPos;
  Vec3D newVel;
  Quaternion newRot;
  /// subtract out the very first position received
  Vec3D initPos;
  
  Vec3D offset;
  Vec3D offsetVel;
  
  Quaternion rot;
  Quaternion offsetRot;
  /// TBD what is the best representation of rotational
  // inertia?  Used to moment of inertia matrices.
  // see http://www.mathworks.com/access/helpdesk/help/toolbox/aeroblks/index.html?/access/helpdesk/help/toolbox/aeroblks/simplevariablemass6dofquaternion.html&http://www.google.com/search?client=firefox-a&rls=org.mozilla%3Aen-US%3Aofficial&channel=s&hl=en&q=quaternion+inertia&btnG=Google+Search
  Vec3D pqr;
  
  movableVector[] movableVectors;
  float[] udpRaw = new float[0];
  
  /// move the movable with another movable
  boolean posTracking = false;
  boolean attTracking = false;
  /// point the movable at another movable
  boolean aimTracking = false;
  movable target;
  
  void toggleAttTracking() {
    attTracking = !attTracking;
    if (attTracking)
      rot = new Quaternion(0, new Vec3D(1,0,0)); 
  }
  
  void togglePosTracking() { 
    if (this == cam) println(pos);
    
    posTracking = !posTracking;
       
    if (posTracking) {
       println("pos tracking");
       if (aimTracking) toggleAimTracking();
       //if (target != null) {
       //  pos = pos.add(target.pos);
       //}
       pos = new Vec3D(0,0,0);
       rot = new Quaternion(0, new Vec3D(1,0,0));
    } else {
       println("not posTracking");
       if (target != null) {
         pos = pos.sub(target.pos);
       }
    }
      
    if (this == cam) println(pos);
  }
  
  void toggleAimTracking() {
    
   if (this == cam) println(pos);
    
    aimTracking = !aimTracking;
      
      if (aimTracking) {
         if (posTracking) { togglePosTracking(); }
         
         /// TBD add the rotated offset to pos
        // pos = pos.sub(rot.getMatrix().apply(offset.getInverted() ));
         //pos = pos.getInverted().add(rot.getMatrix().apply(offset.getInverted() ));
         
         rot = new Quaternion(-cos(PI/2), new Vec3D(0,0,sin(PI/2)));
         println("aiming ");

      } else {
         rot = offsetRot;
         println("not aiming"); 
      }
      
       if (this == cam) println(pos);
  }
  
  movable() {
    
     newPos = new Vec3D(0,0,0);
     newVel = new Vec3D(0,0,0);
     newRot = new Quaternion(0,new Vec3D(1,0,0));
     initPos = null;
    
     
     posHistory = new Vec3D[historyMax];
    
     pos = new Vec3D(0,0,0);
     vel = new Vec3D(0,0,0);
     rot = new Quaternion(0,new Vec3D(1,0,0));
     offsetRot = new Quaternion(0,new Vec3D(1,0,0));
     pqr = new Vec3D(0,0,0);
    
     offset = new Vec3D(0,0,0);
     offsetVel = new Vec3D(0,0,0);
     
     movableVectors = new movableVector[0];
  }
  
  
 
  ///////////////////////////////////////////////////////
  void update() {
    
    if (rxUdp) {
      pos = newPos;
      vel = newVel;
      rot = newRot; 
    } else {
      
      rot = updateRot(rot,pqr); 
      
      pos =  pos.add(vel);  
      offset = offset.add(offsetVel);
 
      ////////////////////////////////////
      if (aimTracking && (target != null)) { 
         
        //pos = new Vec3D(0.0001,0.001,0.001);
        //Vec3D aim = target.pos.getInverted().sub(pos);
        
        /// there's something wrong that requires this to be added instead of subtracted
        Vec3D aim = target.pos.add(pos);
        
        float targetDistance = aim.magnitude();
        
        if (targetDistance > 1e3) {
          autoFov = 1e3/targetDistance;
        } else {
          autoFov = 1.0; 
        }
        
        aim = aim.getNormalized();
        
      
      
        offsetRot = pointQuat(aim.getNormalized());
        
        if (false) { 
          
                  String se;
        se = nf((float)(aim.x), 1, 1);
        print(se + " ");
        se = nf((float)(aim.y), 1, 1);
        print(se + " ");
        se = nf((float)(aim.z), 1, 1);
        println(se + " ");  
        println("rot");
        //println(offsetRot.getMatrix());
        
        Matrix4x4 m2 = offsetRot.getMatrix();
        for (int j = 0; j < 3; j++) {
          for (int i = 0; i < 3; i++) {
            se = nf((float)(m2.matrix[j][i]), 1, 1);
            print(se + " ");
          }
          println();
        }
        println();
        }
          
        if (false){  // TBD not working right
        /// preserve rotation of rot, which can be annoying so may want to disable
        Matrix4x4 m1 = rot.getMatrix();
        Matrix4x4 m2 = offsetRot.getMatrix();
        
        Matrix4x4 m = m2.multiply(m1);
           
        offsetRot = matrixToQuat(m);
        }
        
        
        
        float angle = PI/2;
        offsetRot = offsetRot.multiply(new Quaternion(cos(angle/2) , new Vec3D(0,0,sin(angle/2) ) ));
       
        
      } else {   
        
      }    
    
    }
         
     /// update history
     
     counter++;
     
     if (counter%historySkip == 0) {

       posHistory[historyEnd] = pos;
       
       historyEnd += 1;
       historyEnd %= historyMax;
       if (historyEnd == historyStart) {
          historyStart +=1;
          historyStart %= historyMax; 
       }
     }
  }
  ////////////////////////////////////
  
  
  void apply() {
    
    applyMatrix( 1, 0, 0, (float)pos.x,  
                 0, 1, 0, (float)pos.y,  
                 0, 0, 1, (float)pos.z,  
                 0, 0, 0, 1  ); 
                 
                   
    Matrix4x4 m = rot.getMatrix();
    if (aimTracking) m = offsetRot.getMatrix();  
    
    
    applyMatrix( (float)m.matrix[0][0], (float)m.matrix[0][1], (float)m.matrix[0][2], 0,  
                 (float)m.matrix[1][0], (float)m.matrix[1][1], (float)m.matrix[1][2], 0,  
                 (float)m.matrix[2][0], (float)m.matrix[2][1], (float)m.matrix[2][2], 0,  
                 (float)m.matrix[3][0], (float)m.matrix[3][1], (float)m.matrix[3][2], 1  ); 
    
    if (!aimTracking) {   
      applyMatrix( 1, 0, 0, (float)offset.x,  
                   0, 1, 0, (float)offset.y,  
                   0, 0, 1, (float)offset.z,  
                   0, 0, 0, 1  ); 
    }
  }
  
  /////////////////////////////////////////////////////////////////////
  void applyInv() {
    
    applyMatrix( 1, 0, 0, (float)offset.x,  
                 0, 1, 0, (float)offset.y,  
                 0, 0, 1, (float)offset.z,  
                 0, 0, 0, 1  );  
    
             
    Matrix4x4 m = rot.getMatrix();  
    if (aimTracking) m = offsetRot.getMatrix(); 
    
    applyMatrix( (float)m.matrix[0][0], (float)m.matrix[1][0], (float)m.matrix[2][0], 0,  
                 (float)m.matrix[0][1], (float)m.matrix[1][1], (float)m.matrix[2][1], 0,  
                 (float)m.matrix[0][2], (float)m.matrix[1][2], (float)m.matrix[2][2], 0,  
                 (float)m.matrix[0][3], (float)m.matrix[1][3], (float)m.matrix[2][3], 1  ); 
    
    if (attTracking) {
        rotateZ(PI/2);
        m = target.rot.getMatrix(); 
        applyMatrix( (float)m.matrix[0][0], (float)m.matrix[1][0], (float)m.matrix[2][0], 0,  
                     (float)m.matrix[0][1], (float)m.matrix[1][1], (float)m.matrix[2][1], 0,  
                     (float)m.matrix[0][2], (float)m.matrix[1][2], (float)m.matrix[2][2], 0,  
                     (float)m.matrix[0][3], (float)m.matrix[1][3], (float)m.matrix[2][3], 1  ); 
    }
    
    if (posTracking) {
          applyMatrix( 1, 0, 0, (float)-target.pos.x,  
                 0, 1, 0, (float)-target.pos.y,  
                 0, 0, 1, (float)-target.pos.z,  
                 0, 0, 0, 1  ); 
    }
    
    applyMatrix( 1, 0, 0, (float)pos.x,  
                 0, 1, 0, (float)pos.y,  
                 0, 0, 1, (float)pos.z,  
                 0, 0, 0, 1  ); 
  }

  
  /////////////
   void rotateBody(float df,  Vec3D axis) {

    Quaternion quat = new Quaternion(cos(df/2), 
                                new Vec3D(axis.x*sin(df/2),
                                          axis.y*sin(df/2),
                                          axis.z*sin(df/2)) );
    rot = quat.multiply(rot);
   }
 
 ///////////////
   void rotateAbs(float df,  Vec3D axis) {  
    Quaternion quat = new Quaternion(cos(df/2), 
                              new Vec3D(axis.x*sin(df/2),
                                        axis.y*sin(df/2),
                                        axis.z*sin(df/2)) );
    rot = rot.multiply(quat);
   }
   
  void drawHistory( ) {
    pushMatrix();
    noFill();
    beginShape();
    int tempHistoryEnd = (historyEnd < historyStart) ? historyEnd+historyMax : historyEnd;
    
   
    for (int i = historyStart; i < tempHistoryEnd && (i%historyMax < posHistory.length); i++ ) {
      float frc = (float)(i-historyStart)/(float)(tempHistoryEnd - historyStart);
       strokeWeight(2.0+(1.0-frc)*10.0);
      stroke(frc*255, frc*255,frc*frc*255,255*frc);  
      int realInd = i%historyMax;
      vertex( posHistory[realInd].x, posHistory[realInd].y, posHistory[realInd].z );  
    }
    
    vertex( pos.x, pos.y, pos.z );  
    
    endShape();
    popMatrix();
  }
  
  void draw() {
    pushMatrix();
   
  { 
    //drawHistory();
    
    /// draw velocity vectors
    pushMatrix();
    applyMatrix( 1, 0, 0, (float)pos.x,  
                 0, 1, 0, (float)pos.y,  
                 0, 0, 1, (float)pos.z,  
                 0, 0, 0, 1  ); 

    float rad = 3;
    drawArrow(vel.x/3.0,  rad, color(100,105,155) );
    //text("vel X", 0,  30+vel.x/3.0);
    pushMatrix();
    applyMatrix( 0, 1, 0, 0,  
                 0, 0, 1, 0,  
                 1, 0, 0, 0,
                 0, 0, 0, 1  ); 
    drawArrow(vel.z/3.0, rad, color(100,155,0));
    //text("vel Z", 0,  30+vel.z/3.0);
    popMatrix();
    pushMatrix();
    applyMatrix( 0, 1, 0, 0,  
                 1, 0, 0, 0,  
                 0, 0, 1, 0,
                 0, 0, 0, 1  ); 
    drawArrow(vel.y/3.0, rad, color(155,100,0));
    //text("vel Y", 0,  30+vel.y/3.0);
    popMatrix();
    popMatrix();  
  }
   
    
    if (true) {
      
    /// draw arrows to show movable orientation
    pushMatrix();
 
    apply();
    float len = 60;
    float rad = 7;
    drawArrow(len*2.5,  rad*1.5, color(100,105,255) );
    text("X", len*2.5*1.3,0);
    pushMatrix();
    applyMatrix( 0, 1, 0, 0,  
                 0, 0, 1, 0,  
                 1, 0, 0, 0,
                 0, 0, 0, 1  ); 
    drawArrow(len, rad, color(0,255,0));
    text("Z", len*1.3,0);
    popMatrix();
    pushMatrix();
    applyMatrix( 0, 1, 0, 0,  
                  1, 0, 0, 0,  
                  0, 0, 1, 0,
                  0, 0, 0, 1  ); 
    drawArrow(len, rad, color(255,0,0));
    text("Y", len*1.3, 0);
    popMatrix();

    /// draw movableVectors
    for (int i = 0; i < movableVectors.length; i++) {
       if (udpRaw.length > movableVectors[i].udpInd) {
          movableVectors[i].len = udpRaw[movableVectors[i].udpInd];

       } 
       movableVectors[i].draw();
       movableVectors[i].drawHud(rot);
    }
    popMatrix();
    }
    popMatrix();
  }
  
};

class body extends movable {


  
  /// looking at own ancient code from
  /// http://icculus.org/~lucasw/Dynamics/volume-src-limited-0.0.12.tgz
  /// http://icculus.org/~lucasw/Dynamics/Rigid%20Body%20Dynamics.html
  Vec3D force;
  Vec3D torque;  // can be multiply by dt and added to pqr? 
  
  body() {  
     force  = new Vec3D(0,0,0);
     torque = new Vec3D(0,0,0);   
  }
  
 /* void update() {
    

//    
//    /// gravity
//   // vel.y -=   1.0;
//      
//    /// bounce off ground
//    if (pos.y  < 0) { 
//      pos.y = 0;
//      if (vel.y < 0) vel.y = -vel.y*0.4; 
//      
//      vel.x *= 0.5;
//      vel.z *= 0.5;
//    }
  }*/
  
  /*void draw() {

    super.draw();
  }*/
};




