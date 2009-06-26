
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
  
  return new Quaternion(nq3, new Vec3D(nq0,nq1,nq2));
}

void draw_arrow(float len, float rad, color col ) {
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

////////////////////////////////////////////////////////////////////////////////////

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
     rot = new Quaternion(0,new Vec3D(1,0,0));
     pqr = new Vec3D(0,0,0);
     force = new Vec3D(0,0,0);
     torque = new Vec3D(0,0,0);
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
  }
  
  void draw() {
    pushMatrix();
     
    
    apply();

    
    float len = 30;
    float rad = 7;
    draw_arrow(len*1.5,  rad*1.5, color(200,255,230) );
      pushMatrix();
      applyMatrix( 0, 1, 0, 0,  
                   0, 0, 1, 0,  
                   1, 0, 0, 0,
                   0, 0, 0, 1  ); 
      draw_arrow(len, rad, color(0,255,0));
      popMatrix();
      pushMatrix();
       applyMatrix( 0, 1, 0, 0,  
                    1, 0, 0, 0,  
                    0, 0, 1, 0,
                    0, 0, 0, 1  ); 
      draw_arrow(len, rad, color(255,0,0));
      popMatrix();


    popMatrix();
  }
};


body vehicle; 
body cam;


void setup() {
  frameRate(5);
 size(500,500,P3D); 
 
 vehicle = new body();
 cam = new body();
}

//////////////////////////////////////////////////////

float increase(float x) {
     x += 1; 
       
   if (x > 0) cam.vel.x *= 1.2;
   else x *= 0.9;
   
   return x;
  
}

float decrease(float x) {
  x -= 1.1; 
       
  if (x < 0) x *= 1.2;
  else x *= 0.9;
  
  return x;
}

void handleKeys()
{
 if (keyPressed) {
    if (key == 'a') {
       cam.vel.x = increase(cam.vel.x);
       println(cam.pos.x);
    }
    if (key == 'd') {
        cam.vel.x = decrease(cam.vel.x);
    }
    if (key == 'q') {
       cam.vel.y = increase(cam.vel.y); 
    }
    if (key == 'z') {
       cam.vel.y = decrease(cam.vel.y); 
    }
    if (key == 'w') {
       cam.vel.z = increase(cam.vel.z);
    }
    if (key == 's') {
       cam.vel.z = decrease(cam.vel.z);
    }    
    if (key == 'e') {
       //cam.offset.z += 10; 
       //println(cam.offset.z);
      
    }
    if (key == 'c') {
      //cam.offset.z -= 9;
      //println(cam.offset.z);
    }
}
}


////////////////////////////////////////////////////////////////////////////////

float time = 0;

void draw() {
  
  //println("test");
  time += 0.01;
  
  background(0);
  translate(width/2,height/2); 
  
  cam.update();
  //translate(cam.pos.x,cam.pos.y,cam.pos.z);
  
  vehicle.pqr.x += 0.002*(noise(time)-0.5);
  vehicle.pqr.y += 0.001*(noise(1000+time)-0.5);  
  vehicle.pqr.z += 0.0011*(noise(2000+time)-0.5); 
  //vehicle.vel.x += 0.09*(noise(2000+time)-0.5);
  
  vehicle.update();
  //println(vehicle.vel.x + ", " +vehicle.pos.x);
  vehicle.draw();
}
