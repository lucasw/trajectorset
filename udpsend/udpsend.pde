import hypermedia.net.*;


UDP udp; 

void setup() {
  
  frameRate(5);
  udp = new UDP( this, 6900 );
  udp.listen( false );
}

float t;

float x = 0;
float y = 0;
float z = 0;
float vx = 0;
float vy = 0;
float vz = 0;

void draw() {
  
  t += 0.001;
  
  
  vx += 100*(0.2+sin(t/100.0*PI)) + 50*(noise(t)-0.49);
  vy += 1.0*noise(t+1000);
  vz += 15.0*(noise(t+2000)-0.5);  
  x += vx/100.0;
  y += vy/100.0;
  z += vz/100.0;
  
  float[] tx = new float[10];
  
  tx[0] = x;
  tx[1] = y;
  tx[2] = z;
  
  tx[3] = noise(100 + t*3.0);
  tx[4] = 0.0;
  tx[5] = sqrt(1.0 - tx[3]*tx[3]);
  tx[6] = 0;
  
  tx[7] = vx;
  tx[8] = vy;
  tx[9] = vz;
  
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

