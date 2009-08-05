import com.jmatio.io.*;
import com.jmatio.types.*;

String dir = sketchPath + "/data";
File file = new File(dir);

String names[] = file.list();


for (int i = 0; i <1 /* names.length()*/; i++) {
  //println(names[i]); 
  MatFileReader mfr = null;
  try {
    mfr = new MatFileReader(sketchPAth + "/data/" + names[i] + "/veh_x.mat" );
  } catch (IOException e) {
   e.printStackTrace();
   exit(); 
  }
  //get array of a name "my_array" from file
  
  if (mfr != null) {
  double[][] data = ((MLDouble)mfr.getMLArray( "veh_x" )).getArray();
  //or get the collection of all arrays that were stored in the file
  //Map content = mfr.getContent();
  
  println(data.length +" " + data[0].length + " "  + data[0][0]);
  
  }

}




