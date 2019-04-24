//EPISODE 4 CODE EXAMPLES (https://youtu.be/Q4wE7kKLhEw)

/*I. Local Variables*/

//First, boot the server via Server > Boot Server.

//The following invokes a low-frequency pulse oscillator set to a frequency of 100Hz, with a 50% duty cycle,
//at 10% max amplitude:
~pulse = { LFPulse.ar(freq: 100, iphase: 0, width: 0.5, mul: 0.1).dup }.play;
~pulse.release; //.release frees the Synth with a 0.1 second (unless otherwise specified in its first argument) release.

//.scope works like .play but adds an oscilloscope view:
~sin = { SinOsc.ar(mul: 0.2).dup }.scope(1); //"Hello World" example w/ oscilloscope
~sin.release;

//Same pulse wave as above but with an oscilloscope view this time:
~pulse = { LFPulse.ar(freq: 100, iphase: 0, width: 0.5, mul: 0.1).dup }.scope(1);
~pulse.release;

//Compare that same pulse wave with a duty cycle of 25% to one with a duty cycle of 75%. Why do you think it
//sounds the same? (Answer is in the video.)
~pulse = { LFPulse.ar(freq: 100, iphase: 0, width: 0.25, mul: 0.1).dup }.scope(1);
~pulse.release;
~pulse = { LFPulse.ar(freq: 100, iphase: 0, width: 0.75, mul: 0.1).dup }.scope(1);
~pulse.release;

//Same pulse wave, but this time with a low-frequency triangle wave acting as an LFO modulating the width:
~pulse = { LFPulse.ar(freq: 100, iphase: 0, width: LFTri.ar(0.2, 0, 0.5, 0.5), mul: 0.1).dup }.scope(1);

//Same as above, but now with a low-frequency sawtooth wave acting as an LFO modulating the frequency of the
//low-frequency triangle wave LFO:
~pulse = { LFPulse.ar(freq: 100, iphase: 0, width: LFTri.ar(LFSaw.ar(0.33, 0, 0.5, 0.5), 0, 0.5, 0.5), mul: 0.1).dup }.scope(1);

//This is where local variables come in handy. We can compartmentalize each of these LFO UGens into their own
//variable, thus leading to better organized and legible code:
(
~pulse = {
	var lfo1, lfo2; //Local variables must first be declared using a 'var' tag.

	lfo1 = LFSaw.ar(0.33, 0, 0.5, 0.5); //lfo1 stores our LFSaw UGen (innermost nested UGen)...
	lfo2 = LFTri.ar(lfo1, 0, 0.5, 0.5); //...while lfo2 contains our LFTri UGen, using lfo1 to modulate freq.

	LFPulse.ar(100, 0, lfo2, 0.1).dup;
}.scope(1);
)

//Variables can refer to themselves recursively, thus allowing for the chaining of variables if one so desires:
(
~pulse = {
	var lfo; //Only declaring one variable this time.

	lfo = LFSaw.ar(0.33, 0, 0.5, 0.5);
	lfo = LFTri.ar(lfo, 0, 0.5, 0.5); //lfo is now being reset to the LFTri UGen, using the previous lfo as its LFO

	LFPulse.ar(100, 0, lfo, 0.1).dup;
}.scope(1);
)

//One has the option of reducing their lines of code further by combining the variable declaration with its
//initial value setting:
(
~pulse = {
	var lfo = LFSaw.ar(0.33, 0, 0.5, 0.5); //Combining declaration with initial setting

	lfo = LFTri.ar(lfo, 0, 0.5, 0.5);

	LFPulse.ar(100, 0, lfo, 0.1).dup;
}.scope(1);
)

//The only instruction bussed out of the function is the final one, the one being returned by the function.
//Even though our LFSaw UGen is now oscillating within the audible range, we don't hear it separately, as it's
//only being used to modulate, and thus remains inaudible separately.
(
~pulse = {
	var lfo;

	lfo = LFSaw.ar(33, 0, 0.5, 0.5);
	lfo = LFTri.ar(lfo, 0, 0.5, 0.5);

	LFPulse.ar(100, 0, lfo, 0.1).dup; //This is the only audio rate instruction we will hear.
}.scope(1);
)

//To better demonstrate this, if we were to append our "Hello World" example to this function...
(
~pulse = {
	var lfo;

	lfo = LFSaw.ar(33, 0, 0.5, 0.5);
	lfo = LFTri.ar(lfo, 0, 0.5, 0.5);

	LFPulse.ar(100, 0, lfo, 0.1).dup; //...this instruction is still calculated, but is *not* bussed out!
	SinOsc.ar(mul: 0.2).dup; //The sine wave is the only audio we will hear.
}.scope(1);
)

/*II. Audio Rate vs. Control Rate*/

//Control rate (.kr) class methods for UGens are sampled at 1/64 of the sampling rate of the server (typically
//44.1KHz by default but it depends on one's audio hardware configuration). Using the .kr counterpart for any
//controlling low-frequency oscillator is highly recommended, as it significantly cuts down on CPU usage that
//is otherwise being wasted.
(
~pulse = {
	var lfo;

	lfo = LFSaw.kr(0.33, 0, 0.5, 0.5); //We're using .kr for our LFOs instead
	lfo = LFTri.kr(lfo, 0, 0.5, 0.5);

	LFPulse.ar(100, 0, lfo, 0.1).dup;
}.play;
)