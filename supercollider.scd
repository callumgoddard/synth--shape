(
s.internal;
s.boot;
s.reboot;
s.quit;

/***********************************************************************************/
/////////////////////////////////// OSC FUNCTIONS  //////////////////////////////////
/***********************************************************************************/
(
~processing = NetAddr.new("127.0.0.1", 12000); // make a netAddress for processing

// OSC fucntions that monitor the status of nodes on the SC server.
// recieves messages n_go - for nodes that start and n_end for nodes that have
// synths stopping/being freed.
~newSynthOSC = OSCFunc({ arg msg, time;
    [time, msg].postln; // prints the full message


	// if statement to check a synth is made and not a group
	if(msg[5] == 0,
	{
		msg[1].postln; 								// prints only the nodeID.
		~processing.sendMsg("/newsynth", msg[1]); 	//sends the nodeID of created object.
	});

},'/n_go', s.addr);

~oldSynthOSC = OSCFunc({ arg msg, time;
    [time, msg].postln;
	[time, msg].postln; 						// prints the full message
	msg[1].postln; 								// prints only the nodeID.
	~processing.sendMsg("/oldsynth", msg[1]); 	//sends the nodeID of created object.

},'/n_end', s.addr);

)

(
// to free the OSC functions.
~newSynthOSC.free;
~oldSynthOSC.free;
)


/***********************************************************************************/
///////////////////////////////////// SynthDef //////////////////////////////////////
/***********************************************************************************/
(
SynthDef(\sound, {
	arg out=0, freq=440,width=0.5, panning=0, amp=0.1, cutoff = 3, rq=1, gate=1, doneAction=2;

	var envelope = EnvGen.kr(Env.asr, gate, doneAction: doneAction); // attack, sustain release envelope to allow the synth to be used in patterns.

	var signal = RLPF.ar(Pulse.ar(freq, width, amp), freq*cutoff, rq); // a Square wave that is filtered with a resonant low pass filter
	signal = Pan2.ar(signal, panning); // 2 channel panner
	Out.ar(out,signal*envelope); // audio out

}).store;  // store the synth so it doesn't need to be added everytime the sketch is opened.
)

/***********************************************************************************/
///////////////////////////////////// Pbinds //////////////////////////////////////
/***********************************************************************************/

(
// PBind modified from: "http://sc3howto.blogspot.co.uk/2010/06/pbinds.html"
Pbind(
	\instrument, \sound,
	\freq,  Pseq([ 1/1, 3/2, 4/3, 9/8, 16/9, 5/4, 8/5 ] * 80, inf),
	\panning, Pseq([-0.2,0,0.6,0.1], inf),
	\dur,  Pseq([
      Pseq([1, 3], 2),
      Pseq([0.7, 0.4, 0.1], 1)
     ], 4)
 ).play
)

(
// Test patten that plays infinitely randomising the frequency, panning and cutoff
Pbind(
	\instrument, \sound,
	\freq, Prand([300, 200, 600], inf),
	\panning, Pseq([-1, -0.7, -0.3, 0, 0.3, 0.7, 1], inf),
	\cutoff, Prand([1,2,3,4,5,6,7,8,9,10], 4),
).play;
)

(
// Mary Had a Little Lamb Pbind. - with randomised synth parameters.
~range= 3; 	// for transposing the pitch of the song.
~speed = 1; // for changing the speed
p = Pbind(
	\instrument, \sound,
	\freq, Pseq([
		Pseq([40, 38, 36, 38].midicps*~range, 1),
		Pseq([40, 40, 40].midicps*~range, 1),
		Pseq([38, 38, 38].midicps*~range, 1),
		Pseq([40, 43, 43].midicps*~range, 1),
		Pseq([40, 38, 36, 38].midicps*~range, 1),
		Pseq([40, 40, 40, 40].midicps*~range, 1),
		Pseq([38, 38, 40, 38].midicps*~range, 1),
		Pseq([36].midicps*~range, 1)
	], 1),
	\dur, Pseq([
		Pseq([1, 1, 1, 1]/~speed,1),
		Pseq([1,1,2]/~speed, 3),
		Pseq([1,1,1,1]/~speed, 3),
		Pseq([4]/~speed, 1)
	], 1),
	\cutoff, Prand([1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7.5,8,8.5,9,9.5,9.9], inf),
	\panning, Prand([-1,-0.9,-0.8,-0.7,-0.6,-0.5, -0.4,-0.3,-0.2,-0.1,0,1,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1],inf),
	\width, Prand([0.1,1,2,3,4,5,6,7,8,9,9.9]/10,inf),

).play;
)
36.midicps*1.2
p.stop;
)

/***********************************************************************************/
///////////////////////////////////// Synths //////////////////////////////////////
/***********************************************************************************/

a = Synth.new(\sound);		// make new synth 'a' with default values.
a.set(\panning, 1);			// set panning value to 1 (far left)
a.set(\freq, 1000);			// set freq to 100hz
a.set(\gate, 0);			// set gate to 0 - which will close the gate, ending the envelope.
a.free;						// free synth a


// make new synth 'x' with freq 800, pulse width 0.1, panning value of -0.5 and filter cutoff 10
x = Synth.new(\sound, [\freq, 800, \width, 0.1, \panning, -0.5, \cutoff, 10]);
x.set(\rq, 1);			// set the relational q to 1
x.set(\cutoff, 1.6);	// set cutoff scaling to 1.6
x.set(\freq, 2300);		// set freq to 2300Hz
x.set(\freq, 690);		// set freq to 690Hz
x.set(\width, 0.2);		// set width to 0.2
x.free;					// free the synth

y = Synth.new(\sound, [\freq, 1000, \width, 0.7, \panning, 0.5]);	// make new synth 'y' with freq = 1000, width = 0.7 and panning = 0.5
y.set(\panning, 1);		// set panning to 1
y.free;					// free synth

)