/**
binarymillenium July 2009
GNU GPL v3.0
odejava libs https://odejava.dev.java.net/servlets/ProjectDocumentList?collapseFolder=1836&folderID=0
*/

//import org.odejava.display.*;
import org.odejava.*;
import org.odejava.collision.*;
import org.odejava.ode.*;
import javax.vecmath.*;


float angle;
Body[] boxes;
World world;
HashSpace space;
JavaCollision collision;

 
void setup() {
   size(500,500,P3D); 
   frameRate(50);
   setupODE();
   
   
}

void draw() {
  if (keyPressed) {
     if (key =='j') {
       angle += PI/100.0;
     } 
     if (key =='k') {
       angle -= PI/99.0;
     } 
  }
  
  
  
      collision.collide(space);
            collision.applyContacts();
            world.step();
            
            
            background(0);
            pushMatrix();
            lights();
            translate(width/2,3*height/4);
            
            rotateY(angle);
   
            
            //draw ground
            pushMatrix();
            stroke(150);
            strokeWeight(2.0);
            float sz = 100;
            fill(200);
            float maxi = 20;
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
            
            /// draw boxes
            for (int i = 0; i <boxes.length; i++) {
              pushMatrix();
              noStroke();
              Matrix3f rot = new Matrix3f();
              boxes[i].getRotation(rot);
              
              float pos[] = new float[3];
              boxes[i].getPosition(pos);
              
              
              
              translate(pos[0], pos[1], pos[2]);
              
              applyMatrix(rot.m00, rot.m01, rot.m02, 0.0,
                          rot.m10, rot.m11, rot.m12, 0.0,
                          rot.m20, rot.m21, rot.m22, 0.0,
                          0.0,     0.0,     0.0,     1.0);
              //println(vSpherePos[0] + ", " +vSpherePos[1] + ", " + vSpherePos[2]);
              sz = 5;
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
              //noStroke();
              fill(255.0, 0.0, 0.0 );
            
              popMatrix();  
            }
            
            popMatrix();
}


void cleanupOde() 
    {
        space.delete();
        collision.delete();
        world.delete();
        Ode.dCloseODE();
    }
    
    
void setupODE()
    {
        Odejava.init();
        world = new World();
        world.setGravity(0f, 1.0f, 0f);
        
        collision = new JavaCollision(world);
        collision.setSurfaceMu(10000.0);
        
        boxes= new Body[200];
        for (int i = 0; i <boxes.length; i++) {
          boxes[i] = new Body("box" + i,world, new GeomBox(10,10,10));        
          
          float x = boxes.length/5*random(-1,1);
          float y = -200 + random(-10*boxes.length,0);
          float z = boxes.length/5*random(-1,1);
          boxes[i].setPosition(x,y,z);
          boxes[i].setLinearVel(0,0,0);
        }
        
        
        
        GeomPlane groundGeom = new GeomPlane(0, -1, 0, 0);        
        
        space = new HashSpace();        
        space.add(groundGeom);
        
        for (int i = 0; i <boxes.length; i++) {
          space.addBodyGeoms(boxes[i]);
        }
    }
    

    







