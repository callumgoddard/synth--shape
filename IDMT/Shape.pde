class Shape {

  // Window Parameters
  int windowWidth;
  int windowHeight;
  float frequencyArea;

  // Mapping Parameters
  float freqRange;
  float maxFreq;

  Synth synth; // the synth connected to the shape.

  // Synth parameters
  float freq;
  float width;
  float panning;
  float amp;
  float cutoff;
  float q;

  // Shape Parameters
  float shapeCenterX;
  float shapeCenterY;
  float shapeWidth;
  float shapeHeight;
  float cornerRadii;    // radii for rounding shape corners.
  float shapeArea;
  float longestSide;   // the longest value the width or height the shape can take.
  float shortestSide;  // the shortest value the width or height the shape can take.

  // Shape Color Values
  float shapeAlpha;

  //frequency scaling
  boolean logarithmic;

  // blank constructor to make dummy shapes
  Shape() {
  }

  // main constructor
  Shape(int windowWidth, int windowHeight, int nodeID, float maxFreq, float minFreq, boolean logarithmic) {

    // update the display window dimensions and calculate the area
    this.windowWidth = windowWidth;
    this.windowHeight = windowHeight;

    // find out if one window dimension is greater than the other
    // find the smallest dimension and use this to create a square area
    // that will be used for the frequency mapping.
    if (windowWidth == windowHeight)
      this.frequencyArea = windowWidth*windowHeight;  // square window
    if (windowHeight>=windowWidth)
      this.frequencyArea = pow(windowWidth, 2);       // window width^2 for frequency area
    if (windowWidth>=windowHeight)
      this.frequencyArea = pow(windowHeight, 2);      // window height^2 for frequency area


    synth = new Synth("sound");           // make a new synth
    synth.created = true;                 // that has been created
    synth.nodeID = nodeID;                // set the nodeID of the synth.

    this.logarithmic = logarithmic;       //setup the scaling for the frequency range.
    
    updateFreqRange(maxFreq, minFreq);    // update the frequenct range values of the shape.

    shapeCenterY = 0.5*windowHeight;      // puts shape in middle of window vertically.
  }

  void draw() {
    rectMode(CENTER);      // set rectangle mode.
    fill(255, shapeAlpha); // make the shape white
    rect(shapeCenterX, shapeCenterY, shapeWidth, shapeHeight, cornerRadii); // draw the shape according to the dimesions.
  }

  void setFreq(float freq) {

    this.freq = freq;
    if (logarithmic)
      shapeArea = ((maxFreq - log10(this.freq))/freqRange)*frequencyArea*0.5;  // uses the log10 frequency value to generate the shape area.
    else
      shapeArea = ((maxFreq - this.freq)/freqRange)*frequencyArea*0.5;         // uses the frequency value to generate the shape area.
      
    longestSide = sqrt(shapeArea);                                             // work out length of longest side of the shape.
    shapeWidth = longestSide;                                                  // set shape's longest dimension
  }

  void setWidth(float width) {

    this.width = constrain(width, 0, 1); // constrains the value between 0 and 1.
    // scales the shape width and height of the shape so that
    // the ratio between them is determined by the width of the synth.
    if (this.width == 0.5) {
      shapeWidth = shapeHeight = shortestSide = longestSide;        // shape is square
    } 
    else if (this.width < 0.5) {
      shapeHeight = longestSide;                                    // vertical rectangle
      shortestSide = shapeWidth = shapeHeight*this.width*2;         // scales shape width by correct ration. *2 to scale it to a value between 0 and 1.
    }
    else if (this.width > 0.5) {
      shapeWidth = longestSide;                                     // horizontal rectangle
      shortestSide = shapeHeight = shapeWidth*(1-this.width)*2;     // scales shape height to the correct rati0.
      // 1-width to invert and *2 to scale between 0 and 1.
    }
  }

  void setPanning(float panning) {

    this.panning = constrain(panning, -1, 1);                       // constrain panning to be between -1 and 1.
    //uses the panning value to set the center X coordinate of the shape
    float scaling = map(panning, -1, 1, 0, 1);                      // maps the panning range to a scaling factor
    shapeCenterX = windowWidth*scaling;                             // calculates the centerX coordinate for the shape.
  }

  void setAmp(float amp) {

    this.amp = amp;     // set amplitude value.
  }

  void setCutoff(float cutoff) {

    this.cutoff = constrain(cutoff, 0, 10);                        // constrains then update the shape cutoff value.
    cornerRadii = shortestSide * map(this.cutoff, 0, 10, 1, 0.01); // map the cutoff to scaling for rounding radius.
  }

  void setQ(float q) {
    this.q = constrain(q, 0, 10);                                  // constrain q value to between 0 and 10 
    shapeAlpha = map(this.q, 0, 10, 255, 0);                       // maps q value to alpha
  }

  void updateFreqRange(float maxFreq, float minFreq){
     if (logarithmic) {                            // if logarihmic scaling = true
      this.maxFreq = log10(maxFreq+1);             // find log value of max frequenct note: using max frequency so large shapes = lower frequency. (+ 1 to allow shapes of max frequency to be displayed)
      this.freqRange = log10(maxFreq-minFreq);     // uses the freqency range to set log of minimum frequency in later calculations
    } 
    else {                                         // use linear scaling.
      this.maxFreq = maxFreq+1;                    // using max frequency so large shapes = lower frequency. (+ 1 to allow shapes of max frequency to be displayed)
      this.freqRange = maxFreq-minFreq;            // uses the freqency range to set minimum frequency in later calculations
    }
    
    
  }

  // Calculates the base-10 logarithm of a number
  // taken from - http://processing.org/reference/log_.html
  float log10 (float x) {
    return (log(x) / log(10));
  }

  void stop() {
    synth.free();
  }
}

