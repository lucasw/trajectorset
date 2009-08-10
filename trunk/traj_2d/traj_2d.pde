import com.jmatio.io.*;
import com.jmatio.types.*;

int tmax = 450;
float gravity = -0.0020;
float acc = 0.0045;
float tx = 40;
float ty = 70;

float max_tdot = PI/20;

/*
class veh {
  
  
};*/

float[] veh_x = new float[tmax];
float[] veh_y = new float[tmax];
float[] veh_vx = new float[tmax];
float[] veh_vy = new float[tmax];
float[] veh_ax = new float[tmax];
float[] veh_ay = new float[tmax];
float[] veh_theta = new float[tmax];
float[] veh_thetadot = new float[tmax];
float[] veh_theta_target = new float[tmax];
float[] veh_theta_target2 = new float[tmax];
    
void setup() {
  size(100,100);
  
  background(0);
  
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

int t = 1;

void draw() {
  float windx = 0.004*(0.8*noise(4.0*(float)veh_x[t-1]/(float)height, 4.0*(float)veh_y[t-1]/(float)width) + 
                       0.2*noise(100+0.5*(float)veh_x[t-1]/(float)height, 100+0.5*(float)veh_y[t-1]/(float)width));
  float windy = 0.004*(0.8*noise(0.5*(float)veh_x[t-1]/(float)height, 0.5*(float)veh_y[t-1]/(float)width) + 
                       0.2*noise(100+0.5*(float)veh_x[t-1]/(float)height, 100+0.5*(float)veh_y[t-1]/(float)width));
                       
  float dx = tx-veh_x[t-1];
  float dy = ty-veh_y[t-1];
  float dist2 = sqrt(dx*dx+dy*dy);
        
  veh_theta_target[t] = atan2( dx,dy );
  // TBD unwrap function
  //veh_theta_target(1:t) = unwrap(veh_theta_target(1:t));
        
  veh_theta_target2[t] = atan2(veh_vx[t-1],veh_vy[t-1]);
  //veh_theta_target2(1:t) = unwrap(veh_theta_target2(1:t));
        
  veh_thetadot[t] = 0.1*(veh_theta_target[t] - veh_theta[t-1] - 0.3*veh_theta_target2[t]);
           
        if (veh_thetadot[t] > max_tdot)
            veh_thetadot[t] = max_tdot;
        else if (veh_thetadot[t] < -max_tdot)
            veh_thetadot[t] = -max_tdot;
  
        veh_theta[t] = veh_theta[t-1] + veh_thetadot[t];
            
        float real_acc = acc*(0.6 + 0.4*dist2/width);
        veh_ax[t] = sin(veh_theta[t])*real_acc;
        veh_ay[t] = cos(veh_theta[t])*real_acc + gravity;
        
        veh_vy[t] = veh_vy[t-1] + veh_ay[t];
        veh_vy[t] = veh_vy[t] + windy;

        veh_vx[t] = veh_vx[t-1] + veh_ax[t];
        veh_vx[t] = veh_vx[t] + windx;

        
        veh_x[t] = veh_x[t-1] + veh_vx[t];
        veh_y[t] = veh_y[t-1] + veh_vy[t];
        
        if (veh_x[t] > width)
            veh_x[t] = veh_x[t] -width;
  
        if (veh_x[t] < 0)
           veh_x[t] = veh_x[t] + width;

        if (veh_y[t] < 0)
           veh_y[t] = 0; 
        
        stroke(255);
        fill(255);
        point((int)veh_x,(int)veh_y);
  
  t++;
  if (t >= tmax) {
    noLoop();

    
  }
}

