//fft stuff
import krister.Ess.*;

int BINS=125;
float[] bars = new float[BINS];
float[] dots = new float[BINS];

//audio stuff
float myDamp=.9f;
float slowDamp=0.99f;
float fastDamp=0.99f;
float minLimit=.005;
float maxLimit=.05;
int numAverages=1;
int bufferSize;
int steps;

FFT myFFT;
AudioInput myInput;

void setup() {
  size(800, 400);
  frameRate(30);
  smooth();  
  setupEss();  
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

void draw() 
{  
  background(50);     // darkish grey background
  strokeWeight(2);    // sets the line drawing to 2 pixels wide
  stroke(80,83,193);  // a nice color (use the color selector!)
  int y;
  //draw a line for each bin
  for(int x=0;x<BINS;x++)
  {            
    // grab the current fft for the lines
    bars[x] = myFFT.spectrum[x]; 
    // draw lines
    y = int(height*bars[x]);
    line(x*4,height,x*4,height-y);
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
    ellipse(x*4,height-y,int(gPulseSize*(bars[x]+dots[x])),int(gPulseSize*(bars[x]+dots[x])));
  }
}

//handle data input events
public void audioInputData(AudioInput theInput) 
{
  myFFT.getSpectrum(myInput);
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

