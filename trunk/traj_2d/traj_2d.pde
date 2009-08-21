import com.jmatio.io.*;
import com.jmatio.types.*;

int tmax = 450;
float gravity = -0.0020;
float acc = 0.0045;


float max_tdot = PI/20;

/*
class veh {
  
  
};*/

double[] veh_time = new double[tmax];
double[] veh_x = new double[tmax];
double[] veh_y = new double[tmax];
double[] veh_vx = new double[tmax];
double[] veh_vy = new double[tmax];
double[] veh_ax = new double[tmax];
double[] veh_ay = new double[tmax];
double[] veh_theta = new double[tmax];
double[] veh_thetadot = new double[tmax];
double[] veh_theta_target = new double[tmax];
double[] veh_theta_target2 = new double[tmax];


float tx = 40;
float ty = 70;
//float[] trg_x = new float[tmax]; //40;
//float[] trg_y = new float[tmax]; //70;
//float[] trg_vx = new float[tmax]; //40;
//float[] trg_vy = new float[tmax]; //70;
   
int seed = -1;
     
void setup() {
  size(100,100); 


  
  background(0);
  
  veh_time[0] = 0;
  veh_x[0] = width/2;
  veh_y[0] = 0;
  veh_vx[0] = 0;
  veh_vy[0] = 0;
  /*
  loadPixels();
  for (int i = 0; i < height; i++) {
    for (int j = 0; j < width; j++) {
      
        float c1 = noise(4.0*(float)i/(float)height,
                         4.0*(float)j/(float)width);
        float c2 = noise(100+0.5*(float)i/(float)height,
                         100+0.5*(float)j/(float)width);
        pixels[j*width + i] = color(255*(0.8*c1+0.2*c2));  
    }
  }
  updatePixels();
  */
  
}

//int t = 1;
float offset = 0;

void draw() {
  
  String lines[] = loadStrings("config.csv");
  for (int i = 0; i < lines.length; i++) {
    
    seed = -1;
    String tokens[] = split(lines[i],' ');
    if ( (tokens.length >= 2) && 
        (tokens[0].equals("seed")) ) {
      seed = Integer.parseInt(tokens[1]);    
    }
  
  
  println("seed " + seed);
  noiseSeed(seed);
  
  background(0);
  
  stroke(255);
  //fill(255);
  noFill();
  beginShape();
  for (int t = 1; t < tmax; t++) {
    
    veh_time[t] = (float)t/50.0;
    
    float fr = 0.6;
    float windx = 0.020*((fr*noise(offset + 4.0*(float)veh_x[t-1]/(float)height, 4.0*(float)veh_y[t-1]/(float)width) + 
                       (1.0-fr)*noise(100+0.5*(float)veh_x[t-1]/(float)height, 100+0.5*(float)veh_y[t-1]/(float)width))-0.5);
    float windy = 0.009*((fr*noise(1000+offset + 0.5*(float)veh_x[t-1]/(float)height, 0.5*(float)veh_y[t-1]/(float)width) + 
                       (1.0-fr)*noise(1000+0.5*(float)veh_x[t-1]/(float)height, 100+0.5*(float)veh_y[t-1]/(float)width))-0.5);
    offset += 10.0;                 
                       
    float dx = (float)(tx-veh_x[t-1]);
    float dy = (float)(ty-veh_y[t-1]);
    float dist2 = sqrt(dx*dx+dy*dy);
        
    veh_theta_target[t] = atan2( dx,dy );
    // TBD unwrap function
    //veh_theta_target(1:t) = unwrap(veh_theta_target(1:t));
        
    veh_theta_target2[t] = atan2((float)veh_vx[t-1],(float)veh_vy[t-1]);
    //veh_theta_target2(1:t) = unwrap(veh_theta_target2(1:t));
        
    veh_thetadot[t] = 0.1*(veh_theta_target[t] - veh_theta[t-1] - 0.3*veh_theta_target2[t]);
           
        if (veh_thetadot[t] > max_tdot)
            veh_thetadot[t] = max_tdot;
        else if (veh_thetadot[t] < -max_tdot)
            veh_thetadot[t] = -max_tdot;
  
        veh_theta[t] = veh_theta[t-1] + veh_thetadot[t];
            
        float real_acc = acc*(0.6 + 0.4*dist2/width);
        veh_ax[t] = sin((float)veh_theta[t])*real_acc;
        veh_ay[t] = cos((float)veh_theta[t])*real_acc + gravity;
        
        veh_vy[t] = veh_vy[t-1] + veh_ay[t];
        veh_vy[t] = veh_vy[t] + windy;

        veh_vx[t] = veh_vx[t-1] + veh_ax[t];
        veh_vx[t] = veh_vx[t] + windx;

        
        veh_x[t] = veh_x[t-1] + veh_vx[t];
        veh_y[t] = veh_y[t-1] + veh_vy[t];
        
        
        /*
        if (veh_x[t] >= width)
            veh_x[t] = width;
  
        if (veh_x[t] < 0)
           veh_x[t] = 0;
        */   

        if (veh_y[t] < 0)
           veh_y[t] = 0; 
        
        //stroke(255);
        //fill(255);
        vertex((int)veh_x[t],(int)veh_y[t]);
  
  //t++;
  
  }
  endShape();
  
  
 //saveFrame("data/output" + seed + ".png");

  String subfolder = "data/data" + seed + "/";
  String folder= sketchPath + "/" +subfolder;
  boolean success = (new File(folder)).mkdir();
  //if (success) println("folder " + folder + " created");
  //else println("folder " + folder + " failed");
  
  writeMat(subfolder, "veh_time", veh_time);
  writeMat(subfolder, "veh_x", veh_x);
  writeMat(subfolder, "veh_y", veh_y);
  writeMat(subfolder, "veh_theta", veh_theta);
  
  }
exit();
}


void writeMat(String dir, String name, double[] vals) {
  double[] src = new double[] { 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 };
  MLDouble mlDouble = new MLDouble( name, vals, 1 );
     
  ArrayList list1 = new ArrayList();
  list1.add( mlDouble );
   
   try {
  new MatFileWriter(sketchPath + '/' + dir + name + ".mat", list1 ); 
   } catch (IOException e) {
      e.printStackTrace(); 
   }
}
