import processing.opengl.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

//this is how many lines out of the FFT we're going to draw. 
//the top half is always just high frequency noise
int BINS=125;
float[] bars = new float[BINS];
float[] dots = new float[BINS];

//audio stuff
AudioInput myInput;
Minim minim;
FFT myFFT;
float myDamp=.9f;
float slowDamp=0.99f;
float fastDamp=0.99f;
int bufferSize=512;
int sampleRate=22000;//I don't know this actually, but 11,22 and 44K all work

void setup() {
  size(1024, 600,OPENGL);
  frameRate(60);
  bufferSize=512;
  setupMinim();
}

void setupMinim()
{
  minim=new Minim(this);
  //mono, bit depth 16, 512 buffer size
  myInput=minim.getLineIn(Minim.MONO,bufferSize);
  myFFT=new FFT(bufferSize,sampleRate);
}

void draw() 
{  
  background(0);     // darkish grey background
  strokeWeight(2);    // sets the line drawing to 2 pixels wide
  stroke(80,83,193);  // a nice color (use the color selector!)
  int y;
  //perform the FFT on our audio sample
  myFFT.forward(myInput.mix);
  //draw a line for each bin
  for(int x=0;x<BINS;x++)
  {            
    // grab the current fft for the lines
    bars[x] = myFFT.getBand(x);
    
    // draw lines
    y = int(height*bars[x]);
    line(x*4,height,x*4,height-y);

    // move the dots slowly towards where they need to be
    //this is just a damped control system
    float diff = myFFT.getBand(x)-dots[x];
    if(diff>0)
    {
      dots[x] += fastDamp*diff;
    }
    dots[x]*=slowDamp;

    //draw a white circle above interesting points
    y = int(height*dots[x]);
    ellipse(x*4,
    height-y,
    int(gPulseSize*(bars[x]+dots[x])),
    int(gPulseSize*(bars[x]+dots[x])));
  }
}

float gPulseSize=37.0f;
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
  }
}

