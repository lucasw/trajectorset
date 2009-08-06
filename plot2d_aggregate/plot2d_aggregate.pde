import com.jmatio.io.*;
import com.jmatio.types.*;

String names[];

// TBD load these from config file
void setup() {
size(500,500);
//smooth();

String dir = sketchPath + "/data";
File file = new File(dir);

  names = file.list();
  
    background(0);
}

float xmin = 0;
float xmax = 100;
float ymin = 0;
float ymax = 100;

int i = 0;

void draw() {
    //println(names[i]); 
  MatFileReader mfr = null;
  try {
    mfr = new MatFileReader(sketchPath + "/data/" + names[i] + "/veh_x.mat" );
  } catch (IOException e) {
   e.printStackTrace();
   exit(); 
  }
  i++;
  if (i >= names.length) {
    noLoop();
  }  
   
  
  //get array of a name "my_array" from file
  
  if (mfr != null) {
  double[][] data = ((MLDouble)mfr.getMLArray( "veh_x" )).getArray();
  //or get the collection of all arrays that were stored in the file
  //Map content = mfr.getContent();
  
  println(i + " " + names.length + " " + data.length +" " + data[0].length + " "  + data[0][0]);
  

  float datamax = data[0].length;
  float oldy = (float) (data[0][0]);
  float oldx = 0;
  stroke(255,255,255);
  strokeWeight(1.0);
  for (int j = 1; j < data[0].length; j++) {
       float y = (((float)(data[0][j]) - xmin)/(xmax-xmin)) * height;
       float x = width*(float)(j)/datamax;
       
       line(oldx,oldy,x,y);
       
       /// TBD load pixels, then load previous plot file, and add
       /// pixel red val /255.0 to plot file
       
       oldx = x;
       oldy =y;
  }
  
  }

  
}




