/** 
binarymillenium
GPL v3.0
June 2009

*/

Quaternion matrixToQuat(Matrix4x4 m) {
   //m = m.transpose();
   float s= sqrt(1 + (float)
                   (m.matrix[0][0] + 
                    m.matrix[1][1] +
                    m.matrix[2][2])) * 2;
                   
   float qx = (float)(m.matrix[2][1] - m.matrix[1][2])/s;
   float qy = (float)(m.matrix[0][2] - m.matrix[2][0])/s;
   float qz = (float)(m.matrix[1][0] - m.matrix[0][1])/s;
   
   return new Quaternion(s/4, new Vec3D(qx,qy,qz) ).getNormalized();
}

void receive( byte[] data, String ip, int port ) {	// <-- extended handler
  
  float[] rxx = new float[data.length/4];
  for (int i = 0; i < data.length; i += 4) {
    int accum = ((data[i+3]&0xff) << 24) | 
                ((data[i+2]&0xff) << 16) | 
                ((data[i+1]&0xff) << 8) | 
                 (data[i+0]&0xff);
      
      //int accum = ((b[i]&0xff <<24) | (b[i+1]<<16) | (b[i+2]<<8) | b[i+3];
    
    rxx[i/4] = Float.intBitsToFloat(accum);
  }
  
  if (rxx.length <7) {
    println("not enough data (only " + data.length + " bytes) from " + ip);
    return;
  }
  
  vehicle.rxUdp = true;
  vehicle.pos.x = rxx[0];
  vehicle.pos.y = rxx[1];
  vehicle.pos.z = rxx[2];
  vehicle.rot = new Quaternion(rxx[3], new Vec3D(rxx[4],rxx[5],rxx[6]));
  //String message = new String( data );
  
  // print the result
  //println( "receive: \""+message+"\" from "+ip+" on port "+port );
}

Quaternion updateRot(Quaternion oldRot, Vec3D curPqr) {
    
    float[] pqrMat  =  {0,     -curPqr.x, -curPqr.y,  -curPqr.z,
                        curPqr.x,  0,      curPqr.z,  -curPqr.y,
                        curPqr.y, -curPqr.z,  0,       curPqr.x,
                        curPqr.z,  curPqr.y, -curPqr.x,  -0};
     
    float[] rf;
   
    rf = oldRot.toArray();              
    float epsilon = 1 - (rf[0]*rf[0] + rf[1]*rf[1] + rf[2]*rf[2] + rf[3]*rf[3]);
    float k = 0.01;
    
    //add rot Quaternion qdot 
    //rf = rot.toArray();
    //println(rf[0] + ", " + rf[1] + ", " + rf[2] + ", " + rf[3] + ", ");
    
    Quaternion qdot = MatMultQuat(pqrMat,oldRot);
    //rot = rot.add(  );//.scale(0.5) ); //.add(rot.scale(k*epsilon)) );
    // add is buggy or doesn't do what I think it should
    // so far the only quat operation worthwhile is multiply
    
    float[] qdf = qdot.toArray();
    
    Quaternion newRot = new Quaternion(qdf[3] + rf[3], new Vec3D(0.5*qdf[0] + rf[0], 0.5*qdf[1] + rf[1],0.5*qdf[2] + rf[2]  ));
    newRot = newRot.normalize();
    //rf = rot.toArray();
    //println(rf[0] + ", " + rf[1] + ", " + rf[2] + ", " + rf[3] + ", ");
    
    return newRot;
  }
  
Vec3D rotateAxis(Quaternion rot, Vec3D ax) {
      Matrix4x4 m = rot.getMatrix();  
      Vec3D rax = new Vec3D(
                 (float)(m.matrix[0][0]*ax.x + m.matrix[0][1]*ax.y + m.matrix[0][2]*ax.z), 
                 (float)(m.matrix[1][0]*ax.x + m.matrix[1][1]*ax.y + m.matrix[1][2]*ax.z),  
                 (float)(m.matrix[2][0]*ax.x + m.matrix[2][1]*ax.y + m.matrix[2][2]*ax.z));
 
       return rax;
}

Vec3D rotateAxisInv(Quaternion rot, Vec3D ax) {
    /* // get the angle and axis of existing quat
     float angle = 2*acos(cam.rot.toArray()[3]);
     Vec3D axis = new Vec3D(1,0,0);
    
     if (abs(angle) > 0.001) {
     axis = new Vec3D( cam.rot.toArray()[0]/sin(angle/2), 
                       cam.rot.toArray()[1]/sin(angle/2),
                       cam.rot.toArray()[2]/sin(angle/2) );
     } */
     
       Matrix4x4 m = rot.getMatrix();  
    
      Vec3D rax = new Vec3D(
                 (float)(m.matrix[0][0]*ax.x + m.matrix[1][0]*ax.y + m.matrix[2][0]*ax.z), 
                 (float)(m.matrix[0][1]*ax.x + m.matrix[1][1]*ax.y + m.matrix[2][1]*ax.z),  
                 (float)(m.matrix[0][2]*ax.x + m.matrix[1][2]*ax.y + m.matrix[2][2]*ax.z));   
               
       return rax;
     
}
  
/////


Quaternion MatMultQuat(float[] m, Quaternion q) {
  float q0 = q.toArray()[0];
  float q1 = q.toArray()[1];
  float q2 = q.toArray()[2];
  float q3 = q.toArray()[3]; 
  
  float nq0 =  q0*m[0] + q1*m[1] + q2*m[2] + q3*m[3];
  float nq1 =  q0*m[4] + q1*m[5] + q2*m[6] + q3*m[7];
  float nq2 =  q0*m[8] + q1*m[9] + q2*m[10]+ q3*m[11];
  float nq3 =  q0*m[12]+ q1*m[13]+ q2*m[14]+ q3*m[15];
  
  return new Quaternion(nq3, new Vec3D(nq0,nq1,nq2));
}
   

/// Point a quaternion at a vector
Quaternion pointQuat(Vec3D aim) {
/// TBD add offset to pos
  //Vec3D pnt = rotateAxis(rot, Vec3D ax) 
  
   //println("pos " + pos.x + " " + pos.y + " " + pos.z);
   //println("aim " + aim.x + " " + aim.y + " " + aim.z);
  
   Vec3D up1 = new Vec3D(0,1,0);
   Vec3D right = aim.cross(up1); 
   right = right.getNormalized();
   Vec3D up = right.cross(aim);
   up = up.getNormalized();
   
   Matrix4x4 m = new Matrix4x4(
     
     right.x,  right.y,  right.z, 0,
     -up.x,     -up.y,     -up.z,    0,
   //   up.x,     up.y,     up.z,    0,
     aim.x,    aim.y,    aim.z,   0,
     0,        0,        0,       1  
   );
              
  m = m.transpose();
 
  if (false) {
    println("track");
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
          String se = nf( (float)(m.matrix[i][j]), 1, 3);
          print(se + " ");
      }
      println();
    }
  }
   
   Quaternion new_rot = matrixToQuat(m); 
  
   if (false) {
   println("rot new ");
      Matrix4x4 m3 = new_rot.getMatrix();
        for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          String se = nf((float)(m3.matrix[i][j]), 1, 3);
          print(se + " ");
        }
      println();
    }
    println();
   }

  
  if (false) {
    float angle = 2*acos(cam.rot.toArray()[3]);
    Vec3D axis = new Vec3D(1,0,0);
  
    if (abs(angle) > 0.001) {
      axis = new Vec3D( cam.rot.toArray()[0]/sin(angle/2), 
                        cam.rot.toArray()[1]/sin(angle/2),
                        cam.rot.toArray()[2]/sin(angle/2) );
                     
      println("axis " + axis.x + " " + axis.y + " " + axis.z + ", " + (angle*180.0/PI));
    } 
  }
  
  return new_rot;
}
   
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////  
class movable {
  Vec3D pos;
  Vec3D vel;
  
  Vec3D offset;
  Vec3D offsetVel;
  
  Quaternion rot;
  Quaternion offsetRot;
  /// TBD what is the best representation of rotational
  // inertia?  Used to moment of inertia matrices.
  // see http://www.mathworks.com/access/helpdesk/help/toolbox/aeroblks/index.html?/access/helpdesk/help/toolbox/aeroblks/simplevariablemass6dofquaternion.html&http://www.google.com/search?client=firefox-a&rls=org.mozilla%3Aen-US%3Aofficial&channel=s&hl=en&q=quaternion+inertia&btnG=Google+Search
  Vec3D pqr;
  
  /// move the movable with another movable
  boolean posTracking = false;
  boolean posAttTracking = false;
  /// point the movable at another movable
  boolean aimTracking = false;
  movable target;
  
  movable() {
    
     pos = new Vec3D(0,0,0);
     vel = new Vec3D(0,0,0);
     rot = new Quaternion(0,new Vec3D(1,0,0));
     offsetRot = new Quaternion(0,new Vec3D(1,0,0));
     pqr = new Vec3D(0,0,0);
    
     offset = new Vec3D(0,0,0);
     offsetVel = new Vec3D(0,0,0);
  }
  
  
 
  ///////////////////////////////////////////////////////
  void update() {
    rot = updateRot(rot,pqr); 
    
    pos =  pos.add(vel);  
    offset = offset.add(offsetVel);
    
    ////////////////////////////////////
    if (aimTracking && (target != null)) { 
       
       /*
       println("rot");
      Matrix4x4 m2 = rot.getMatrix();
        for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          String se = nf((float)(m2.matrix[i][j]), 1, 3);
          print(se + " ");
        }
      println();
    }*/
     offsetRot = pointQuat(target.pos.getInverted().sub(pos).getNormalized());
      
      //offsetRot = updateRot(offsetRot,pqr);
      
      Matrix4x4 m1 = rot.getMatrix();
      Matrix4x4 m2 = offsetRot.getMatrix();
      
      Matrix4x4 m = m2.multiply(m1);
         
      offsetRot = matrixToQuat(m);
      
      float angle = PI;
      offsetRot = offsetRot.multiply(new Quaternion(cos(angle/2) , new Vec3D(0,0,sin(angle/2) ) ));
      
    } else {   
      
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
                   
    applyMatrix( 1, 0, 0, (float)offset.x,  
                 0, 1, 0, (float)offset.y,  
                 0, 0, 1, (float)offset.z,  
                 0, 0, 0, 1  ); 
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
   

  
  void draw() {
    pushMatrix();
 
    apply();

    float len = 60;
    float rad = 7;
    drawArrow(len*2.5,  rad*1.5, color(100,105,255) );
      pushMatrix();
      applyMatrix( 0, 1, 0, 0,  
                   0, 0, 1, 0,  
                   1, 0, 0, 0,
                   0, 0, 0, 1  ); 
      drawArrow(len, rad, color(0,255,0));
      popMatrix();
      pushMatrix();
       applyMatrix( 0, 1, 0, 0,  
                    1, 0, 0, 0,  
                    0, 0, 1, 0,
                    0, 0, 0, 1  ); 
      drawArrow(len, rad, color(255,0,0));
      popMatrix();


    popMatrix();
  }
};

class body extends movable {

  boolean rxUdp;
  
  /// looking at own ancient code from
  /// http://icculus.org/~lucasw/Dynamics/volume-src-limited-0.0.12.tgz
  /// http://icculus.org/~lucasw/Dynamics/Rigid%20Body%20Dynamics.html
  Vec3D force;
  Vec3D torque;  // can be multiply by dt and added to pqr? 
  
  body() {
   
     force = new Vec3D(0,0,0);
     torque = new Vec3D(0,0,0);
     
     
  }
  
  void update() {
    
    if (rxUdp) {
      
    } else {
      super.update();
    }
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
  }
  
 /* void draw() {

  }*/
};




