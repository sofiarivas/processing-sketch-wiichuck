import oscP5.*;
import netP5.*;
import processing.serial.*;

OscP5 osc; // mensaje que se va a dar 
//NetAddress remote; // a donde 

Serial myPort;                // The serial port

Particula p; 
int n = 100; 
Particula [] partis = new Particula [n]; //inicializamos el arreglo de particulas 

//--------------------

float xmag, ymag = 0;
float newXmag, newYmag = 0; 
int sensorCount = 5;
int BAUDRATE = 9600; 
char DELIM = ','; // the delimeter for parsing incoming data
float sensorX, sensorZ;

//--------------------

void setup () {
  size (1280, 720);
  background(255);

  osc = new OscP5 (this, 12000);
  //remote = new NetAddress ("127.0.0.1", 57120); // 57120 puerto de donde provienen los datos
  //dirección del local host "127.0.0.1
  p = new Particula(100, 200, osc);
  for (int i=0; i < n; i++) {
    partis [i] = new Particula(i*(width/n), height/2, osc);
    
  }
  
   myPort = new Serial(this, Serial.list()[1], BAUDRATE);
  // clear the serial buffer:
  myPort.clear();
}

//--------------------

void draw() {

  p.draw();
  for ( int i = 0; i < n; i++) {
    partis[i].draw();
   
  }
  //fill(255, 70);
  //noStroke();
  //rect(0, 0, width, height);
  
    newXmag = mouseX/float(width) * TWO_PI;
    newYmag = mouseY/float(height) * TWO_PI;
  
    float diff = xmag-newXmag;
    if (abs(diff) >  0.01) { 
      xmag -= diff/4.0; 
    }
  
    diff = ymag-newYmag;
    if (abs(diff) >  0.01) { 
      ymag -= diff/4.0; 
    }
  
  //  if ((sensorValues[1] > 15) && (sensorValues[1] < 165)) {
      sensorZ = sensorValues[0] / 180 * PI;
      sensorX = sensorValues[1] / 180 * PI;
   // }
}
void keyPressed() {
  if (key =='s') {  
    saveFrame ("particula-###.png");
  }
  
  if (key =='f') {  
    background(255,5);
  }
}

float[] sensorValues = new float[sensorCount];  // array to hold the incoming values
void serialEvent(Serial myPort) {
  String serialString = myPort.readStringUntil('\n');
  
  if (serialString != null) {
    //println(serialString);
    String[] numbers = split(serialString, DELIM);
    if (numbers.length == sensorCount) {
      for (int i = 0; i < numbers.length; i++) {
        if (i <= sensorCount) {
          numbers[i] = trim(numbers[i]);
          sensorValues[i] =  float(numbers[i]);
          if (i == 0) {
            sensorValues[i] = map(sensorValues[i], 28, 222, 0, width);
          } else if (i == 1) {
            sensorValues[i] = map(sensorValues[i], 33, 220, 0, height);
          }
        }
        print(numbers[0]);
      }
    }
  }
}

class Particula {

  //------- VARIABLES ----------

  float posX = 300;
  float posY = 200;
  float incX = 2;
  float incY = 5;
  PVector pos = new PVector ( posX, posY);
  PVector inc = new PVector (incX, incY);
  PVector mouse = new PVector ();
  PVector m2p = new PVector();
  PVector g = new PVector (0, 0.1);
  PVector vel = new PVector (0, 0);
  float r = 0;
  float gr= 0;
  float b= 0;
  float damp = 0.99;
  int listoFlag = 0;

  // ----- las particulas sepan a donde mandar mensaje //
  OscP5 osc;
  NetAddress sc;


  //------- CONSTRUCTOR ----------
  Particula(OscP5 _osc) {
    sc = new NetAddress ("127.0.0.1", 57120);
    osc = _osc;
  }

  //------- FUNCTION OVERWRITING ----------

  Particula(int x, int y, OscP5 _osc) {
    posX = x;
    posY = y;
    pos.set(x, y);
    r=30;
    sc = new NetAddress ("127.0.0.1", 57120);
    osc = _osc;
  }

  //------- CADA PARTICULA SE DIBUJA A SI MISMA ----------

  void draw() {

    mouse.set(sensorValues[0], sensorValues[1]);
    m2p = mouse.get ();
    m2p.sub(pos); // vector entre particula y ratón

    inc = m2p.get();
    //hacer la magnituda igual a 1.
    inc.normalize();


    inc.mult(0.6); // este valor define la fuerza de atracción (repulsión si es que es negativa)
    r=255*abs(cos(pos.x*0.003));
    gr=255*abs(cos(pos.y*0.003));
    b=255*abs(cos(pos.y*0.003));
    fill (r, gr, b);
    //sc = new NetAddress ("127.0.0.1", 57120);

    stroke (m2p.mag()*0.5);
    //strokeWeight(1);
    noStroke();
    ellipse (pos.x, pos.y, 5, 5);
    stroke(r, gr, b);
    line(pos.x, pos.y, pos.x+m2p.x, pos.y+m2p.y);
    //g.mult(0.04);

    //
    if (m2p.mag() > 50 && m2p.mag() < 650) {
      vel.add(inc);
    }

    vel.add(g);
    vel.mult(damp); // a la velocidad total, 
    //multiplicarla por un valor menor a uno que reduce su velocidad
    pos.add(vel);
    // posX = posX + incX;
    //posY = posY + incY;
    fronteras();
    listoFlag++;
  }

  void fronteras() {

    if (pos.x < 0) {
      pos.x = 0;
      vel.x = vel.x * -1;
      OscMessage msg = new OscMessage ("/frontera");
      msg.add(pos.x);
      if (listoFlag >100 ) {
        osc.send(msg, sc);
        listoFlag = 0;
      }
    } 
    if (pos.x > width) {
      pos.x = width;
      vel.x *= -1;
      OscMessage msg = new OscMessage ("/frontera");
      msg.add(pos.x);
      if (listoFlag >100 ) {
        osc.send(msg, sc);
        listoFlag = 0;
      }
    }
    if (pos.y < 0 ) {
      pos.y = 0;
      vel.y *= -1;
      OscMessage msg = new OscMessage ("/frontera");
      msg.add(pos.x);
      if (listoFlag >100 ) {
        osc.send(msg, sc);
        listoFlag = 0;
      }
    }

    if (pos.y > height ) {
      pos.y = height;
      vel.y *=-1;
      OscMessage msg = new OscMessage ("/frontera");
      msg.add(pos.x);
      //if (listoFlag >100 ) {
        //osc.send(msg, sc);
        //listoFlag = 0;
     // }
      
      if (vel.mag() > 5) {
        osc.send(msg, sc);
        listoFlag = 0;
      }
    }
  }
}