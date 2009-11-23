/** 
binarymillenium
GPL v3.0
June 2009

*/


int udpCounter = 0;
int udpCounterOld = 0;
/////////////////////////////////////////
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
  
  if (rxx.length <10) {
    println("not enough data (only " + data.length + " bytes) from " + ip);
    return;
  }
  
  Vec3D udpPos = new Vec3D(rxx[1]*0.3048, rxx[0]*0.3048, -rxx[2]*0.3048); 
  
  Quaternion udpRot = new Quaternion(-rxx[3], new Vec3D(-rxx[5],-rxx[4],rxx[6]));
  udpRot = udpRot.multiply(new Quaternion(cos(PI/4), new Vec3D(0,0,sin(PI/4))) ); 
  udpRot = udpRot.multiply(new Quaternion(cos(PI/2), new Vec3D(sin(PI/2),0,0)) ); 
  
  Vec3D udpVel = new Vec3D(rxx[8]*0.3048, rxx[7]*0.3048, rxx[9]*0.3048);
  
  vehicle.rxUdp = true;
  if (vehicle.initPos== null) {
    vehicle.initPos = udpPos;
  }
  vehicle.newPos = udpPos;
  vehicle.newRot = udpRot;
  vehicle.newVel = udpVel;
  
  /// give the vehicle all the udp data
  vehicle.udpRaw = rxx;
 
  udpCounter++; 
}




////////////////////////////////////
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
  
  
  
  
//////////////////////////////////////////  
Vec3D rotateAxis(Quaternion rot, Vec3D ax) {
  Matrix4x4 m = rot.getMatrix();  
  Vec3D rax = new Vec3D(
             (float)(m.matrix[0][0]*ax.x + m.matrix[0][1]*ax.y + m.matrix[0][2]*ax.z), 
             (float)(m.matrix[1][0]*ax.x + m.matrix[1][1]*ax.y + m.matrix[1][2]*ax.z),  
             (float)(m.matrix[2][0]*ax.x + m.matrix[2][1]*ax.y + m.matrix[2][2]*ax.z));
 
  return rax;
}




///////////////////////////////////////////////////
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
  
  
  
  
//////////////////////////////////////////////////////////////////////
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
   
   
   
   
/////////////////////////////////////////////////////////////////  
Quaternion matrixToQuat(Matrix4x4 m) {
   //m = m.transpose();
   float s= sqrt(1 + (float)
                   (m.matrix[0][0] + 
                    m.matrix[1][1] +
                    m.matrix[2][2])) * 2;
                   
   float qx = (float)(m.matrix[2][1] - m.matrix[1][2])/s;
   float qy = (float)(m.matrix[0][2] - m.matrix[2][0])/s;
   float qz = (float)(m.matrix[1][0] - m.matrix[0][1])/s;
   
   Quaternion rawQuat = new Quaternion(s/4, new Vec3D(qx,qy,qz) ).getNormalized();
   return rawQuat;
}
   
   
   
   
///////////////////////////////////////////////////////////   
Matrix4x4 pointMat(Vec3D aim) {
  /// TBD add offset to pos
  //Vec3D pnt = rotateAxis(rot, Vec3D ax) 
  
   //println("pos " + pos.x + " " + pos.y + " " + pos.z);
   //println("aim " + aim.x + " " + aim.y + " " + aim.z);
  
  /// construct a left handed matrix here, and then convert it back after
   Vec3D up1 = new Vec3D(0.001,0.999,0); //Vec3D(0,1,0);
   Vec3D right = aim.cross(up1); 
   right = right.getNormalized();
   Vec3D up = right.cross(aim);
   up = up.getNormalized();
   
   
   if (right.magnitude() < 0.5) {
     //aim = new Vec3D(0,0,1);
     right = new Vec3D(1,0,0);
     up    = new Vec3D(0,1,0);
     aim   = new Vec3D(0,0,1);
   }
     
   Matrix4x4 m = new Matrix4x4(
     up.x,     up.y,    up.z,    0,
     right.x,  right.y, right.z, 0,
     aim.x,    aim.y,   aim.z,   0,
     0,        0,      0,        1
   );
   
     /*
     Matrix4x4 m = new Matrix4x4(
     up.x, right.x,    aim.x,   0,
     up.y, right.y,    aim.y,   0,
     up.z, right.z,    aim.z,   0,
     0,        0,      0,        1
   );*/
          
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
  
  return m;
}




//////////////////////////////////////////////////////
/// Point a quaternion at a vector
Quaternion pointQuat(Vec3D aim) {
  
   Matrix4x4 m = pointMat(aim);
   
   Quaternion new_rot = matrixToQuat(m); 
  
   if (false) {
   println("rot new ");
     // it seems like getMatrix always outputs left handed matrices
     /// which it would since it's built for processing
      Matrix4x4 m3 = new_rot.getMatrix();
        for (int j = 0; j < 3; j++) {
        for (int i = 0; i < 3; i++) {
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
   
   
   
   
/////////////////////////////////////////////////////////////
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
