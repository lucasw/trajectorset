import com.jmatio.io.*;
import com.jmatio.types.*;

String names[];

PFont font;

class plot {
  float xmin;
  float xmax;
  float ymin;
  float ymax;
  String xName;
  String yName;
  
  plot(String xName, String yName, 
        float xmin, float xmax, float ymin, float ymax) {
    this.xmin = xmin;
    this.xmax = xmax;
    this.ymin = ymin;
    this.ymax = ymax;
    this.xName = xName;
    this.yName = yName;
  }
};

plot[] plots = new plot[0];

void setup() {
  size(500,500);
  //smooth();
  
  String dir = sketchPath + "/data";
  File file = new File(dir);
 
  
  font = createFont("Serif.bold",24);
  textFont(font);

  names = file.list();
  
  String lines[] = loadStrings("config.csv");
  for (int i = 0; i < lines.length; i++) {
     
    String tk[] = split(lines[i],' ');
    if (tk.length == 6) {
      plots = (plot[])append(plots, new plot(tk[0], tk[1], 
                                              Float.parseFloat(tk[2]), 
                                              Float.parseFloat(tk[3]),
                                              Float.parseFloat(tk[4]),
                                              Float.parseFloat(tk[5]) ) );
    } else {
       println("error config line: " + lines[i]);  
    }
    
  }
  
  background(0);
}





//////////////////////////////////////////////////////////////////////////

void drawPlot(plot plotData, double[][] xMatData, double[][] yMatData, float weight, color col) {
  
  //smooth();
  noFill();
  stroke(col);
  beginShape();
  strokeWeight(weight);
  for (int j = 1; j < xMatData[0].length && j < yMatData[0].length; j++) {
       float y = (((float)(xMatData[0][j]) - plotData.xmin)/(plotData.xmax-plotData.xmin)) * height;
       float x = (((float)(yMatData[0][j]) - plotData.ymin)/(plotData.ymax-plotData.ymin)) * width;
       
       ///
       if (x >= width) x = width-1;
       if (y >= height) y = height-1;
       if (x<0) x=0;
       if (y<0) y=0;
       
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

///////////////////////////////////////////////////////

void draw() {
  //TBD get array of a name  from file
  //String matName = "veh_x"; 
  
  (new File(sketchPath + "/output/")).mkdir();
  
  for (int i = 0; i < plots.length; i++) {
  
    /// load or create the data buffer
    byte[] data = loadBytes("output/" +plots[i].xName + "_" + plots[i].yName + ".dat");
    if ((data == null) /*|| (i == 0)*/)  data = new byte[(width*height+1)*4];
    
    float numAgg = -1.0;
    for (int nameInd=0; nameInd <names.length; nameInd++) {   
      double[][] xMatData = getData(names[nameInd], plots[i].xName);
      if (xMatData == null) { 
        println("error " + names[nameInd] + " was null");
        continue;
      }   
      
      double[][] yMatData = getData(names[nameInd], plots[i].yName);
      if (yMatData == null) { 
        println("error " + names[nameInd] + "/" + plots[i].yName + " was null");
        continue;
      }  
      
      background(0);  
      
      drawPlot(plots[i],xMatData,yMatData,1,color(255,255,255));
      
      /////////////////////
      /// now that drawing is done, aggregate the new plot with the saved one    
      numAgg = updateDataAndPixels(data, true);
  
    } // name list
    saveBytes("output/" + plots[i].xName + "_" + plots[i].yName + ".dat", data);
    
    /// just draw the existing data even if there is nothing new 
    if (names.length == 0) {
      background(0);
      /// TBD need to generate numAgg from saved file- put in last four bytes of data[]?
      numAgg  = updateDataAndPixels(data,  false);     
    }
    println(numAgg + " runs with " + names.length  + " new aggregated");
    
    saveFrame("output/" + plots[i].xName + "_" + plots[i].yName + "_nohighlight.png");
    
    /// draw the latest data again to highlight it
    for (int nameInd=0; nameInd <names.length; nameInd++) {   
      double[][] xMatData = getData(names[nameInd], plots[i].xName);
      double[][] yMatData = getData(names[nameInd], plots[i].yName);
      if ((yMatData != null) && (xMatData !=null)) {      
        drawPlot(plots[i],xMatData,yMatData,3,color(100,255,100,128));
        //text(nameInd, width-150,50);
      }
    }
  
    text(plots[i].xName + " vs. " + plots[i].yName ,10,25);
    text((int)numAgg + " runs with " + names.length  + " new runs",10,50);
    
    saveFrame("output/" + plots[i].xName + "_" + plots[i].yName + ".png");
  }
 // nameInd++;
 // if (nameInd >= names.length) {
 //   noLoop();
    //exit();
 // }  
  exit();
}


float updateDataAndPixels(byte[] data, boolean hasNew) {
  loadPixels();
  float[] newData = new float[width*height];
  
  float numAgg= bytesToFloat(data,width*height*4);
  /// this stores the total number of runs
  if(hasNew) numAgg += 1.0;
      
  for (int i = 0; i < data.length-4; i+=4) {             
      int zind = i/4;
    
      /// add the data and immediately convert back to bytes
      newData[zind] = bytesToFloat(data,i);
      newData[zind] += (float)red(pixels[zind])/255.0;
      data = floatToBytes(data, i, newData[zind]);
      
   
      /// now update the pixel for display
      float fr = newData[zind]/numAgg;
      pixels[zind] = color(fr*32.0*255.0,
                           fr*4.0*255.0, 
                           fr*16.0 + ((fr >0) ? 127.0 :0) ); 
       
  }
      
  data = floatToBytes(data, width*height*4, numAgg);
      
  updatePixels();
  
  return numAgg;
}

float bytesToFloat(byte[] data, int i) {
    // convert from bytes back to float
    int accum = ((data[i+3]&0xff) << 24) | 
                ((data[i+2]&0xff) << 16) | 
                ((data[i+1]&0xff) << 8) | 
                 (data[i+0]&0xff);
                 
    return Float.intBitsToFloat(accum);             
}

byte[] floatToBytes(byte[] rv, int i, float val) {
    //byte[] rv = new byte[4];
    
      int bits = Float.floatToIntBits(val);
      rv[i+3] = (byte) ((bits >> 24) & 0xff);
      rv[i+2] = (byte) ((bits >> 16) & 0xff);
      rv[i+1] = (byte) ((bits >> 8)  & 0xff);
      rv[i+0] = (byte) ((bits >> 0)  & 0xff);
      
      return rv;
}

