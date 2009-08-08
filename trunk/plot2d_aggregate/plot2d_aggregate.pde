import com.jmatio.io.*;
import com.jmatio.types.*;

String names[];

PFont font;

// TBD load these from config file
void setup() {
size(500,500);
//smooth();

String dir = sketchPath + "/data";
File file = new File(dir);

font = createFont("Serif.bold",24);
textFont(font);

  names = file.list();
  
    background(0);
}

float xmin = 0;
float xmax = 100;
float ymin = 0;
float ymax = 100;

int i = 0;

//////////////////////////////////////////////////////////////////////////

void drawPlot(double[][] matdata, float weight) {
  float datamax = matdata[0].length;
  //smooth();
  noFill();
  stroke(255,255,255);
  beginShape();
  strokeWeight(weight);
  for (int j = 1; j < matdata[0].length; j++) {
       float y = (((float)(matdata[0][j]) - xmin)/(xmax-xmin)) * height;
       float x = width*(float)(j)/datamax;
       
       vertex(x,y);
  }
  endShape();
}

//////////////////////////////////////////////////////////////////////////

void draw() {
    //println(names[i]); 
    background(0);
  
  //TBD get array of a name  from file
  String matname = "veh_x";
  MatFileReader mfr = null;
  try {
    mfr = new MatFileReader(sketchPath + "/data/" + names[i] + "/" + matname + ".mat" );
  } catch (IOException e) {
   e.printStackTrace();
   exit(); 
  }
 
    
  if (mfr != null) {
    
      /// load the old data file and text file (just a list of all the 
  /// files used to make the data file currently
  byte[] data   = loadBytes(matname + ".dat");
  if ((data == null) || (i == 0))  data = new byte[width*height*4];
  
  /*
  String[] meta = loadStrings(matname + ".txt");
  if ((meta == null) || (i == 0)) meta = new String[0];
  meta = append(meta, names[i]);
  saveStrings(matname+".txt",meta);
  int numAgg = meta.length;
  */
  int numAgg = i+1;
  
  double[][] matdata = ((MLDouble)mfr.getMLArray( matname )).getArray();
  //or get the collection of all arrays that were stored in the file
  //Map content = mfr.getContent();
  
  /*
  println(i + " " + names.length + " " + matdata.length +" " + 
                matdata[0].length + " "  + matdata[0][0]);
                */
  // println("numAgg " + numAgg);
  
  drawPlot(matdata,1);
  
  /////////////////////
  /// now that drawing is done, aggregate the new plot with the saved one
  
  loadPixels();
  float[] newData = new float[width*height];
  for (int i = 0; i < data.length; i+=4) {
    // convert from bytes back to float
    int accum = ((data[i+3]&0xff) << 24) | 
                ((data[i+2]&0xff) << 16) | 
                ((data[i+1]&0xff) << 8) | 
                 (data[i+0]&0xff);
                 
    int zind = i/4;
    
    /// add the data and immediately convert back to bytes
    newData[zind] = Float.intBitsToFloat(accum);
    newData[zind] += (float)red(pixels[zind])/255.0;
    int bits = Float.floatToIntBits(newData[zind]);
    data[i+3] = (byte) ((bits >> 24) & 0xff);
    data[i+2] = (byte) ((bits >> 16) & 0xff);
    data[i+1] = (byte) ((bits >> 8)  & 0xff);
    data[i+0] = (byte) ((bits >> 0)  & 0xff);
    
    /// now update the pixel for display
    float fr = newData[zind]/(float)numAgg;
    pixels[zind] = color(fr*128.0*255.0,
                         fr*32.0*255.0, 
                         fr*128.0 + ((fr >0) ? 127.0 :0) );
    
  }
  updatePixels();
  saveBytes(matname + ".dat", data);
  
    /// draw the latest data again to highlight it
  
  drawPlot(matdata,3);
  text(i, width-150,50);
  }
  


  i++;
  if (i >= names.length) {
    noLoop();
  }  
}




