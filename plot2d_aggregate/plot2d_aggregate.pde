import com.jmatio.io.*;
import com.jmatio.types.*;

String names[];

PFont font;


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

// TBD load these from config file
float xmin = 0;
float xmax = 100;
float ymin = 0;
float ymax = 100;

int i = 0;

//////////////////////////////////////////////////////////////////////////

void drawPlot(double[][] matData, float weight) {
  float dataMax = matData[0].length;
  //smooth();
  noFill();
  stroke(255,255,255);
  beginShape();
  strokeWeight(weight);
  for (int j = 1; j < matData[0].length; j++) {
       float y = (((float)(matData[0][j]) - xmin)/(xmax-xmin)) * height;
       float x = width*(float)(j)/dataMax;
       
       vertex(x,y);
  }
  endShape();
}

//////////////////////////////////////////////////////////////////////////

double[][] getData(String name, String matName) {
  MatFileReader mfr = null;
  try {
    mfr = new MatFileReader(sketchPath + "/data/" + name + "/" + matName + ".mat" );
  } catch (IOException e) {
    e.printStackTrace();
    exit(); 
  } 
    
  if (mfr != null) {       
    double[][] matData = ((MLDouble)mfr.getMLArray( matName )).getArray();
    return matData;
    //or get the collection of all arrays that were stored in the file
    //Map content = mfr.getContent();
  }
  return null;
}

void draw() {
  //TBD get array of a name  from file
  String matName = "veh_x"; 
  
  /// load or create the data buffer
  byte[] data = loadBytes(matName + ".dat");
  if ((data == null) /*|| (i == 0)*/)  data = new byte[width*height*4];
  
  for (int nameInd=0; nameInd <names.length; nameInd++) {   
    double[][] matData = getData(names[nameInd], matName);
    if (matData == null) { 
      println("error " + names[nameInd] + " was null");
      continue;
    }   
    
    background(0);  
    int numAgg = i+1;
    drawPlot(matData,1);
    
    /////////////////////
    /// now that drawing is done, aggregate the new plot with the saved one    
    updateDataAndPixels(data, numAgg);

  } // name list
  
  if (names.length == 0) {
    /// just draw the existing data even if there is nothing new 
    background(0);
    /// TBD need to generate numAgg from saved file- put in last four bytes of data[]?
    updateDataAndPixels(data,  numAgg);  
  }
  
  
  saveBytes(matName + ".dat", data);
  
  /// draw the latest data again to highlight it
  for (int nameInd=0; nameInd <names.length; nameInd++) {   
    double[][] matData = getData(names[nameInd], matName);
    if (matData != null) {    
      drawPlot(matData,2);
      //text(nameInd, width-150,50);
    }
  }

  saveFrame("output.png");
 // nameInd++;
 // if (nameInd >= names.length) {
 //   noLoop();
    //exit();
 // }  
  exit();
}


void updateDataAndPixels(byte[] data, float numAgg) {
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
      pixels[zind] = color(fr*32.0*255.0,
                           fr*4.0*255.0, 
                           fr*16.0 + ((fr >0) ? 127.0 :0) ); 
  }
      
  updatePixels();
  
}


