import hypermedia.net.*;


UDP udp; 

void setup() {
  
  frameRate(50);
  udp = new UDP( this, 6900 );
  udp.listen( false );
}

float t;

void draw() {
  
  t += 0.001;
  
  
  float[] tx = new float[7];
  
  tx[1] = 1000*sin(t*PI);
  tx[2] = 10*sin(t*PI*10);
  tx[0] = t;
  
  tx[3] = 0;
  tx[4] = 0.0;
  tx[5] = 1.0;
  tx[6] = 0;
  
  byte[] txb = new byte[tx.length*4];
  
  for (int i = 0; i < tx.length; i++) {
    int bits = Float.floatToIntBits(tx[i]);
    txb[i*4+0] = (byte) ((bits >> 0)  & 0xff);
    txb[i*4+1] = (byte) ((bits >> 8)  & 0xff);
    txb[i*4+2] = (byte) ((bits >> 16) & 0xff);
    txb[i*4+3] = (byte) ((bits >> 24) & 0xff);
  }
  

    udp.send( txb, "127.0.0.1", 6100);

}

