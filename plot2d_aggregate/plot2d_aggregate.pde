
MatFileReader mfr = new MatFileReader( "mat_file.mat" );
 //get array of a name "my_array" from file
 MLArray mlArrayRetrived = mfr.getMLArray( "my_array" );
 //or get the collection of all arrays that were stored in the file
Map content = mfr.getContent();


