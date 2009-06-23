
import toxi.geom.*;

Quaternion MatMultQuat(float[] m, Quaternion q) {
  float q0 = q.toArray()[0];
  float q1 = q.toArray()[1];
  float q2 = q.toArray()[2];
  float q3 = q.toArray()[3]; 
  
  float nq0 =  q0*m[0] + q1*m[1] + q2*m[2] + q3*m[3];
  float nq1 =  q0*m[4] + q1*m[5] + q2*m[6] + q3*m[7];
  float nq2 =  q0*m[8] + q1*m[9] + q2*m[10]+ q3*m[11];
  float nq3 =  q0*m[12]+ q1*m[13]+ q2*m[14]+ q3*m[15];
  
  return Quaternion(nq3, Vec3D(nq0,nq1,nq3));
}

class body {
  Vec3D pos;
  Vec3D vel;
  
  Quaternion rot;
  /// TBD what is the best representation of rotational
  // inertia?  Used to moment of inertia matrices.
  // see http://www.mathworks.com/access/helpdesk/help/toolbox/aeroblks/index.html?/access/helpdesk/help/toolbox/aeroblks/simplevariablemass6dofquaternion.html&http://www.google.com/search?client=firefox-a&rls=org.mozilla%3Aen-US%3Aofficial&channel=s&hl=en&q=quaternion+inertia&btnG=Google+Search
  Vec3D pqr;
  
  /// looking at own ancient code from
  /// http://icculus.org/~lucasw/Dynamics/volume-src-limited-0.0.12.tgz
  /// http://icculus.org/~lucasw/Dynamics/Rigid%20Body%20Dynamics.html
  Vec3D force;
  Vec3D torque;  // can be multiply by dt and added to pqr? 
  
  body() {
     pos = new Vec3D(0,0,0);
     vel = new Vec3D(0,0,0);
     rot = new Quaternion(0,Vec3D(1,0,0));
     pqr = new Vec3D(0,0,0);
     force = new Vec3D(0,0,0);
     torque = new Vec3D(0,0,0);
  }
  
  void update() {
    
    float[] pqrMat  =  {0,     -pqr.x, -pqr.y,  -pqr.z,
                        pqr.x,  0,      pqr.z,  -pqr.y,
                        pqr.y, -pqr.z,  0,       pqr.x,
                        pqr.z,  pqr.y, -pqr.x,  -0};
                        
    epsilon = 1 - (rot.toArray[0]^2 + rot.toArray[1]^2 + rot.toArray[2]^2 + rot.toArray[3]^2);
    float k = 0.01;
    
    //add rot Quaternion qdot 
     rot.add( MatMultQuat(pqrMat,rot).scale(0.5).add(rot.scale(k*epsilon)) );
  
  }
};


body vehicle = new body();


void setup() {
 size(500,500,P3D); 
}

void draw() {
  background(0);
 translate(width/2,height/2); 
}
