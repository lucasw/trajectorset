/** 
binarymillenium
GPL v3.0
June 2009

*/

   Vec3D rotateAxis(Quaternion rot, Vec3D ax) {
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
//                 (float)(m.matrix[0][0]*ax.x + m.matrix[0][1]*ax.y + m.matrix[0][2]*ax.z), 
//                 (float)(m.matrix[1][0]*ax.x + m.matrix[1][1]*ax.y + m.matrix[1][2]*ax.z),  
//                 (float)(m.matrix[2][0]*ax.x + m.matrix[2][1]*ax.y + m.matrix[2][2]*ax.z));
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
   
   
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////  
class movable {
  Vec3D pos;
  Vec3D vel;
  
  Vec3D offset;
  Vec3D offsetVel;
  
  Quaternion rot;
  /// TBD what is the best representation of rotational
  // inertia?  Used to moment of inertia matrices.
  // see http://www.mathworks.com/access/helpdesk/help/toolbox/aeroblks/index.html?/access/helpdesk/help/toolbox/aeroblks/simplevariablemass6dofquaternion.html&http://www.google.com/search?client=firefox-a&rls=org.mozilla%3Aen-US%3Aofficial&channel=s&hl=en&q=quaternion+inertia&btnG=Google+Search
  Vec3D pqr;
  
  
  movable() {
    
     pos = new Vec3D(0,0,0);
     vel = new Vec3D(0,0,0);
     rot = new Quaternion(0,new Vec3D(1,0,0));
     pqr = new Vec3D(0,0,0);
    
     offset = new Vec3D(0,0,0);
     offsetVel = new Vec3D(0,0,0);
  }
  
  void update() {
    
    
    
    
    float[] pqrMat  =  {0,     -pqr.x, -pqr.y,  -pqr.z,
                        pqr.x,  0,      pqr.z,  -pqr.y,
                        pqr.y, -pqr.z,  0,       pqr.x,
                        pqr.z,  pqr.y, -pqr.x,  -0};
     
    float[] rf;
   
    rf  = rot.toArray();              
    float epsilon = 1 - (rf[0]*rf[0] + rf[1]*rf[1] + rf[2]*rf[2] + rf[3]*rf[3]);
    float k = 0.01;
    
    //add rot Quaternion qdot 
    rf = rot.toArray();
    //println(rf[0] + ", " + rf[1] + ", " + rf[2] + ", " + rf[3] + ", ");
    
    Quaternion qdot = MatMultQuat(pqrMat,rot);
    //rot = rot.add(  );//.scale(0.5) ); //.add(rot.scale(k*epsilon)) );
    // add is buggy or doesn't do what I think it should
    // so far the only quat operation worthwhile is multiply
    
    float[] qdf = qdot.toArray();
    
    rot = new Quaternion(qdf[3] + rf[3], new Vec3D(0.5*qdf[0] + rf[0], 0.5*qdf[1] + rf[1],0.5*qdf[2] + rf[2]  ));
    rot = rot.normalize();
    rf = rot.toArray();
    //println(rf[0] + ", " + rf[1] + ", " + rf[2] + ", " + rf[3] + ", ");
    
    pos =  pos.add(vel);  
    offset = offset.add(offsetVel);
    
  }
  
  void apply() {
    
    applyMatrix( 1, 0, 0, (float)pos.x,  
                   0, 1, 0, (float)pos.y,  
                   0, 0, 1, (float)pos.z,  
                   0, 0, 0, 1  ); 
                   
    Matrix4x4 m = rot.getMatrix();  
    
    
    applyMatrix( (float)m.matrix[0][0], (float)m.matrix[0][1], (float)m.matrix[0][2], 0,  
                 (float)m.matrix[1][0], (float)m.matrix[1][1], (float)m.matrix[1][2], 0,  
                 (float)m.matrix[2][0], (float)m.matrix[2][1], (float)m.matrix[2][2], 0,  
                 (float)m.matrix[3][0], (float)m.matrix[3][1], (float)m.matrix[3][2], 1  ); 
                   
    applyMatrix( 1, 0, 0, (float)offset.x,  
                 0, 1, 0, (float)offset.y,  
                 0, 0, 1, (float)offset.z,  
                 0, 0, 0, 1  ); 
  }
  
   void rotateBody(float df,  Vec3D axis) {

    Quaternion quat = new Quaternion(cos(df/2), 
                                new Vec3D(axis.x*sin(df/2),
                                          axis.y*sin(df/2),
                                          axis.z*sin(df/2)) );
    rot = quat.multiply(rot);
   }
 
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

    float len = 30;
    float rad = 7;
    drawArrow(len*1.5,  rad*1.5, color(200,255,230) );
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
    
    super.update();
    
    /// gravity
    vel.x -=   0.2;
      
    /// bounce off ground
    if (pos.x  < 0) { 
      pos.x = 0;
      if (vel.x < 0) vel.x = -vel.x*0.5; 
      
      if (vel.x < 0.1){
      pqr.x *= 0.9;
      pqr.y *= 0.9;
      pqr.z *= 0.9; 
      
      /// add a random boost
      if (random(1.0) < 0.05) {
          vel.x = 8 + random(5.0);
      }
      }
    }
  }
  
 /* void draw() {

  }*/
};




