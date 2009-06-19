
import toxi.geom.*;


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
  
  void update() {
    
    Matrix4x4 pqrMat  = new Matrix4x4(0,     -pqr.x, -pqr.y,  -pqr.z,
                                      pqr.x,  0,      pqr.z,  -pqr.y,
                                      pqr.y, -pqr.z,  0,       pqr.x,
                                      pqr.z,  pqr.y, -pqr.x,  -0);
    rot = 0.5*
  }
};
