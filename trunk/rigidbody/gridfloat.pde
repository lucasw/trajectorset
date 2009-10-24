/** 
binarymillenium
GPL v3.0
June 2009

*/

class terrain {
  
  PImage tex;
  
  float [][] heights;
  float [] xs;
  float [] ys;

  /// in meters
  static final float EARTH_CIRC_EQ = 40075.02e3;
  static final float EARTH_CIRC_MER= 40007.86e3;
  
  int ncols;
  int nrows;
  float xllcorner;
  float yllcorner;
  float cellsize;
  float xSizeMeters;
  float ySizeMeters;
  float dx;
  float dy;
  
  Vec3D maxur, minll;
 
  float hToY(int h) {
     return ((-h + nrows/2)*dy);
  }
  
  float wToX(int w) {   
    return ((w - ncols/2)*dx);
  }
  
  /// retun position in meters relative to center of gridfloat
  Vec3D indicesToVec(int h, int w) {  
     if ((h <0) || (h >= heights.length) || (w <0) || (w >= heights[h].length)) {
       println(" error h " + h + ", w " + w);
        return new Vec3D(0,0,0);
     }
  
      
       return new Vec3D( wToX(h), hToY(w), heights[h][w]); 

    
  }
  
  /// path to hdr and flt files
  /// download some data from seamless.usgs.gov in gridfloat format
  terrain(String filepath, String imagePath) {
    
    /// png converted from geotiffs
    tex = loadImage(imagePath);
    
    String lines[] = loadStrings(filepath + ".hdr");

    for (int i = 0; i< lines.length; i++) {
      String[] tk = splitTokens( lines[i] ," \t");
      
      if (tk.length >1) {
        if (match(tk[0], "ncols")    != null) { ncols = Integer.parseInt(tk[1]); }
        if (match(tk[0], "nrows")    != null) { nrows = Integer.parseInt(tk[1]); }
        if (match(tk[0], "xllcorner")!= null) { xllcorner = Float.parseFloat(tk[1]); }
        if (match(tk[0], "yllcorner")!= null) { yllcorner = Float.parseFloat(tk[1]); }
        if (match(tk[0], "cellsize") != null) { cellsize = Float.parseFloat(tk[1]); }
        /// TBD look at byteorder later
      }
    }    
        
    println("ncols (w) " + ncols + 
            ", nrows (h) " + nrows + "\n xllcorner " + xllcorner + ", " + yllcorner + ", " + cellsize);
    
    dy = cellsize/360.0*EARTH_CIRC_MER;
    /// this of course would be increasingly inexact as the width of the tile get large compared
    /// to the size of the Earth
    dx = cos(yllcorner*PI/180.0)*cellsize/360.0*EARTH_CIRC_EQ;
    
    println("dx = " + dx + " meters, dy = " + dy + " meters");
      
    heights = new float[nrows][ncols];
    xs = new float[ncols];
    ys = new float[nrows];
    
    int i = 0;
    byte b[] = loadBytes(filepath + ".flt");
    /// b.length should == ncols*nrows*4, could check this
    for (int h = 0; h < nrows; h++) {
    for (int w = 0; w < ncols; w++) {
      //int i = (h*ncols+w)*4;
      if ((i+4) > b.length) {
         println("error flt file is too short " + (ncols*nrows*4) + " vs. " + b.length); 
         
         //return;
      }
    //for (int i = 0; i < b.length; b+=4) {
      int accum = ((b[i+3]&0xff) <<24) | ((b[i+2]&0xff) <<16) | ((b[i+1]&0xff)<<8) | (b[i+0]&0xff);
      
      //int accum = ((b[i]&0xff <<24) | (b[i+1]<<16) | (b[i+2]<<8) | b[i+3];
      i += 4;
    //}
    
      /// this will be in meters
      float elev = Float.intBitsToFloat(accum);
      heights[h][w] = elev;
    
      
      xs[w] = wToX(w);
      ys[h] = hToY(h);
      
      //println(h + " " + w + " " + heights[h][w]); 
        
//              int[] b = new int[4];
//          
//          for (int k = 0; k < 4; k++) {
//            b[k] = gridraw.read();  // the LSB, and the lowest address in intel
//            if (b[k] == -1) {println("error no more data"); return;}
//          }
//          
//          int accum = (b[3] <<24) | (b[2]<<16) | (b[1]<<8) | b[0];
//        
//          float hgt = Float.intBitsToFloat(accum);
//          if (hgt > maxh) maxh = hgt;
//          if (hgt < minh) minh = hgt;
  }}
  
    minll = indicesToVec(0,0);
    maxur = indicesToVec(nrows-1,ncols-1);
    
  }
  
  void draw() {
    pushMatrix();
    
    ambientLight(40,40,35);
    directionalLight(255,255,210,-0.6,-1,0);
    directionalLight(30,45,30,-0.2,1,0);
  
    translate(0,-(heights[(int)(nrows/2)][(int)(ncols/2)]),0);
    fill(255,255,255);
    
    //noFill();
    noStroke();
    textureMode(IMAGE);
    int skip = 8;
  
    for (int h = 0; h<= nrows-1-skip; h+= skip) {  
       beginShape(TRIANGLE_STRIP);
       texture(tex);
    for (int w = 0; w <= ncols-skip; w+= skip) {

       //fill(255,128+128*norm(xs[w],minll.y,maxur.y), 255*norm(heights[h][w],minll.z,maxur.z)) ;


        //println(xs[w] + ", " +  ys[h] +", " + heights[h][w] + ",\t" +
        //         xs[w] + ", " +  ys[h+1] +", " + heights[h+1][w] );
       vertex(xs[w], heights[h][w],      ys[h],       tex.width*w/ncols, tex.height*h/nrows);
       vertex(xs[w], heights[h+skip][w], ys[h+skip],  tex.width*w/ncols, tex.height*(h+skip)/nrows);
       
      }
      endShape();
  }
  popMatrix(); 
  }
};
