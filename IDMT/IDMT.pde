import supercollider.*;
import oscP5.*;
import netP5.*;

//window Properties
int windowWidth = 1250;
int windowHeight = 750;

// frequency mappings
float maxFreq = 1000;    // Maximum Frequency a shape can take (for mapping purposes)
float minFreq = 140;     // minimum frequency for mapping purposes.
boolean LOGARITHMIC = true;       // sets the scaling

OscP5 osc;

ArrayList<Shape> shapes;
Synth synth;

void setup() {

  size(windowWidth, windowHeight); // set the window size

  osc = new OscP5(this, 12000); // start listening for osc messages on port 12000

    // create OSC plugs to automatically trigger functions
  // when a /newsynth and /oldsynth osc message is recieved.
  osc.plug(this, "newShape", "/newsynth");
  osc.plug(this, "removeShape", "/oldsynth");

  // make an array to keep the shapes
  shapes = new ArrayList<Shape>();
}

void draw() {
  background(0);
  // iterate through the Array List
  for (int i = shapes.size()-1; i>=0;i--) {
    if (i >=shapes.size()) {    // if a shape has been removed in the middle of a draw loop
      // this stops everything until the next draw loop.
      println("something has gone wrong");
      break;
    }
    // as an extra crash prevention I've added a try catch pair so that if
    // an out of bound exception - or an unpredictable exception - happens
    // the programm will still run.
    try {
      Shape shape = shapes.get(i);              // retrieves the shape
      getSynthParameters(shape);                // updates its parameters
      shape.updateFreqRange(maxFreq, minFreq);  // updates the frequency range values in the shape
      shape.draw();                             // draws the shape
    } 
    catch(Exception e) {
      println("Exception Caught :"+e);
    }
  }
}

void newShape(int nodeID) {
  // make a new shape object and set its synth nodeID
  Shape shape = new Shape(windowWidth, windowHeight, nodeID, maxFreq, minFreq, LOGARITHMIC);
  getSynthParameters(shape);  // get parameter values from the synth
  shapes.add(shape);     // add to the shapes array.
}

void removeShape(int nodeID) {
  // find the right node ID shape and remove it.
  for (int i = shapes.size()-1; i>=0;i--) {  // Iterates backwards through the shape array list
    Shape shape = shapes.get(i);                   // retiving each shape from the array
    if (shape.synth.nodeID == nodeID) {    // if the synth's nodeID matches the removed nodeID
      shapes.remove(i);                      // the shape is removed
    }
  }
}

void getSynthParameters(Shape shape) {
  // Function to make is simplere to get/update paramter values from the synth
  shape.synth.get("freq", this, "getFreq");
  shape.synth.get("width", this, "getWidth");
  shape.synth.get("panning", this, "getPanning");
  shape.synth.get("amp", this, "getAmp");
  shape.synth.get("cutoff", this, "getCutoff");
  shape.synth.get("rq", this, "getQ");
}

void getValue (int nodeID, String arg, float value) {


  int shapeIndex = findShape(nodeID);           // find index of the shape with the synth that matches the nodeID
  Shape settingShape = shapes.get(shapeIndex);  // retrive the shape from the array lise
  if (arg == "freq") {
    println("param: "+arg+" "+value);
  }

  settingShape.setFreq(value);                  // set the frequency value
  shapes.set(shapeIndex, settingShape);         // return the shape to the shapes arrayList.
}

void getFreq (int nodeID, String arg, float value) {

  testFreq(value);                              // tests the frequency value.

  int shapeIndex = findShape(nodeID);           // find index of the shape with the synth that matches the nodeID
  Shape settingShape = shapes.get(shapeIndex);  // retrive the shape from the array lise
  settingShape.setFreq(value);                  // set the frequency value
  shapes.set(shapeIndex, settingShape);         // return the shape to the shapes arrayList.
}

void getWidth (int nodeID, String arg, float value) {

  int shapeIndex = findShape(nodeID);           // find index of the shape with the synth that matches the nodeID
  Shape settingShape = shapes.get(shapeIndex);  // retrive the shape from the array lise
  settingShape.setWidth(value);                 // set the width value
  shapes.set(shapeIndex, settingShape);         // return the shape to the shapes arrayList.
}

void getPanning (int nodeID, String arg, float value) {
  int shapeIndex = findShape(nodeID);           // find index of the shape with the synth that matches the nodeID
  Shape settingShape = shapes.get(shapeIndex);  // retrive the shape from the array lise
  settingShape.setPanning(value);               // set the width value
  shapes.set(shapeIndex, settingShape);         // return the shape to the shapes arrayList.
}

void getAmp (int nodeID, String arg, float value) {
  int shapeIndex = findShape(nodeID);           // find index of the shape with the synth that matches the nodeID
  Shape settingShape = shapes.get(shapeIndex);  // retrive the shape from the array lise
  settingShape.setAmp(value);                   // set the width value
  shapes.set(shapeIndex, settingShape);         // return the shape to the shapes arrayList.
}

void getCutoff (int nodeID, String arg, float value) {
  int shapeIndex = findShape(nodeID);           // find index of the shape with the synth that matches the nodeID
  Shape settingShape = shapes.get(shapeIndex);  // retrive the shape from the array lise
  settingShape.setCutoff(value);                // set the width value
  shapes.set(shapeIndex, settingShape);         // return the shape to the shapes arrayList.
}

void getQ(int nodeID, String arg, float value) {
  int shapeIndex = findShape(nodeID);           // find index of the shape with the synth that matches the nodeID
  Shape settingShape = shapes.get(shapeIndex);  // retrive the shape from the array lise
  settingShape.setQ(value);                     // set the width value
  shapes.set(shapeIndex, settingShape);         // return the shape to the shapes arrayList.
}

void stopAll() {

  for (int i = shapes.size()-1; i>=0;i--) {     // Iterates backwards through the shape array list
    Shape shape = shapes.get(i);                // retiving each shape from the array
    shape.stop();                               // stop the shapes
    shapes.set(i, shape);                       // update the arrayList
  }
}

void testFreq(float freq) {               // function to see if the maximum frequency is needed to be increased
                                          // saves having to rerun the sketch if unexpected frequencies are found.
  if ( freq > maxFreq)                    // if the freq is greater than the maximum frequency.
    maxFreq = freq +1;                    // increase the maximum frequency + 1 used so the actual maximum value can be sdisplayed

  if ( freq < maxFreq)                    // if the frequency is less than the minimum frequency.
    minFreq = freq;                       // decrease the minimum frequency.
}

int findShape(int nodeID) {
  int shapeIndex =0;

  for (int i = shapes.size()-1; i>=0;i--) {  // Iterates backwards through the shape array list
    Shape shape = shapes.get(i);             // retiving each shape from the array
    if (shape.synth.nodeID == nodeID) {      // if the synth's nodeID matches the removed nodeID
      shapeIndex = i;
    }
  }
  return shapeIndex;
}

void exit() {
  // stop all shapes
  stopAll();
  super.exit();
}

