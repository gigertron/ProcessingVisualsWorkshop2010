import saito.objloader.*;

import processing.opengl.*;

//fft stuff
import krister.Ess.*;

int BINS=125;
float[] bars = new float[BINS];
float[] dots = new float[BINS];
float[] rings = new float[BINS];

//audio stuff
float myDamp=.9f;
float slowDamp=0.98f;
float fastDamp=0.9f;
float minLimit=.005;
float maxLimit=.05;
int numAverages=1;
int bufferSize;
int steps;

FFT myFFT;
AudioInput myInput;

OBJModel model;

void setup() {
  size(1280, 800, OPENGL);
  frameRate(60);
  setupEss();    
  model = new OBJModel(this);
  model.debugMode();
  model.load("ring.obj");
}

void setupEss()
{
  // start up Ess
  Ess.start(this);  
  
  // set up our AudioInput
  bufferSize=512;
  myInput=new AudioInput(bufferSize);
  
  // set up our FFT
  myFFT=new FFT(bufferSize*2);
  myFFT.equalizer(true);
  
  // set up our FFT normalization/dampening
  myFFT.limits(minLimit,maxLimit);
  myFFT.noDamp();
  myFFT.averages(5);
    
  myInput.start();
}
float foo=0;
float rotY=0;
float rotX=0;

void draw() 
{  
  background(50);     // darkish grey background
  strokeWeight(2);    // sets the line drawing to 2 pixels wide
  stroke(80,83,193);  // a nice color (use the color selector!)
  lights();
  int y;
  //draw a line for each bin
  for(int x=0;x<BINS;x++)
  {            
    // grab the current fft for the lines
    bars[x] = myFFT.spectrum[x]; 
    // draw lines
    y = int(height*bars[x]);
    line(x*4,
    height,
    0,
    x*4,
    height-y,
    0);
    // move the dots slowly towards where they need to be
    float diff = myFFT.spectrum[x]-dots[x];
    if(diff>0)
    {
      dots[x] += fastDamp*diff;
    }
    dots[x]*=slowDamp;
    // now draw some of them. maybe the interesting ones?

    //draw a white circle above interesting points
    y = int(height*dots[x]);
    ellipse(x*4,
    height-y,
    int(gPulseSize*(bars[x]+dots[x])),
    int(gPulseSize*(bars[x]+dots[x])));
    
    rings[x]+=gRingSpeed*myFFT.spectrum[x];
  }
  int ringsz=10;
  float[] avgs = reduce(rings,30,BINS,4);
  
  for(int x=0;x<10;x++)
  {
    ringsz+=25;
    ring(ringsz,avgs[x],avgs[x+10],avgs[x+20]);
  }  
}

//average the fft down to a smaller number of bins
float[] reduce(float[] in, int newbins, int bins,int ratio)
{
  float[] out = new float[newbins];
  int binNumber=0;
  int contributionsToThisBin=0;
  int x=0;
  while(binNumber < newbins)
  {
    out[binNumber]+=in[x++]/ratio;
    if(++contributionsToThisBin>=ratio) 
    { 
      binNumber++; 
      contributionsToThisBin=0;
    }
  }
  return out;
}


void ring(float sz, float rx, float ry, float rz)
{
  model.drawMode(TRIANGLES);
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(0.9+rx);
  rotateY(ry);
  rotateZ(0.9+rz);
  scale(sz);
  model.draw();
  popMatrix();
  
}

float circle(float x)
{
  //basic idea is aa spiral
  return sin(x);//well it;s a start
}
//handle data input events
public void audioInputData(AudioInput theInput) 
{
  myFFT.getSpectrum(myInput);
}

float gPulseSize=37.0f;
boolean bTexture = true;
boolean bStroke = true;
float gRingSpeed=0.39f;
public void keyPressed() {
  switch (key) 
  {
    case 'a': 
      gPulseSize*=1.1; 
      println("gPulseSize:"+gPulseSize);
      break;
    case 'z': 
      gPulseSize*=0.9f; 
      println("gPulseSize:"+gPulseSize);
      break;
      
     case 'd': 
      gRingSpeed*=1.1; 
      println("gRingSpeed:"+gRingSpeed);
      break;
    case 'c': 
      gRingSpeed*=0.9f; 
      println("gRingSpeed:"+gRingSpeed);
      break;
     
  }
  
  
  ///////////////
  if(key == 't'){
    if(!bTexture){
      model.enableTexture();
      bTexture = true;
    } else {
      model.disableTexture();
      bTexture = false;
    }
  }
  if(key == 's'){
    if(!bStroke){
      stroke(10, 10, 10, 100);
      bStroke = true;
    } else {
      noStroke();
      bStroke = false;
    }
  }
  else if(key=='1')
  model.drawMode(POINTS);
  else if(key=='2')
  model.drawMode(LINES);
  else if(key=='3')
  model.drawMode(TRIANGLES);
  else if(key=='4')
  model.drawMode(POLYGON);

  //////////////
  
  
  
  
  
  
}

