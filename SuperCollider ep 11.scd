//EPISODE 11 CODE EXAMPLES (https://youtu.be/5pT35gN24OM)

//NOTE: This was originally meant to be part of Episode 10, but that episode would have been 35 minutes had I
//not split section III off into its own video.

/*III. Bridging the Gap*/

//First, let's boot the server by executing the following code:
s.options.memSize_(2 pow: 20); //This allocates 1GiB of memory to the server (it's set to 8192KiB by default)
s.boot; //This boots the server

//Our objective this episode is to write code that will instance Synths once a continually rerolling RNG produces
//a value exceeding some threshold, the Synths instanced in question being determined by the location of the mouse
//pointer on the screen.

//Synth 1 (using Klank)
(
~klank = { |pan=0, amp=0.2|
	var sig, freq;
	var freqs, amps, rings, specs;

	//Rand operates much like client-side rrand, except that it generates a new number each time the Synth is
	//instanced (rrand will only produce a new value if the SynthDef itself is recompiled), and it always returns
	//floats (rrand returns integers if no decimal is given):
	freq = Rand(100, 5000);
	sig  = Impulse.ar(0.1);

	//Array.series prefills an array with an arithmetic series, in this case the first 12 partials above the
	//randomly generated fundamental:
	freqs = Array.series(13, freq, freq);

	//Array.fill prefills an array using values returned from its user-defined function. Here we're returning
	//amplitude values derived from the reciprocal of the one-indexed partial number:
	amps = Array.fill(13, { |i|
		var partial = i + 1;

		partial.reciprocal;
	});
	rings = Array.fill(13, { Rand(0.1, 2) });

	//A tick mark (`) preceding an array will set up a reference to that array, thus preventing SuperCollider
	//from automatically expanding the signal across multiple audio channels:
	specs = `[freqs, amps, rings];

	sig = Klank.ar(specs, sig);

	//As our code will spawn many Synths, we have to provide some way for the server to release them once they've
	//stopped sounding, otherwise each new Synth will continue to pile on as new running processes without any
	//of the old ones clearing, eventually leading to CPU overload and client/server crash. This can be achieved
	//through DetectSilence, with Done.freeSelf (or simply 2) placed in the doneAction argument:
	DetectSilence.ar(sig, doneAction: Done.freeSelf); //'doneAction: 2' without quotes also works
	Pan2.ar(sig * amp, pan); //Here we opt for Pan2 instead of .dup to be able to spatialize across the stereo field.
}.asDefName;
)

//Now let's test our code!
x = Synth(~klank); //Since we used .asDefName, the environmental variable is used as the Synth name.

//Synth 2 (using Klang)
(
~klang = { |pan=0, amp=0.1|
	var sig, freq, env;
	var freqs, amps, phases, specs;

	freq = Rand(100, 5000);

	freqs = Array.series(13, freq, freq);
	amps  = Array.fill(13, { |i|
		var partial = i + 1;

		partial.reciprocal;
	});
	//Where Klank uses ring times, Klang makes use of initial phase settings:
	phases = Array.fill(13, { Rand(0, 0.99) });
	specs = `[freqs, amps, phases];

	sig = Klang.ar(specs);

	//As Klang, unlike Klank, has no built-in decay, DetectSilence would be of no use to us here. Instead we
	//must shape the sound manually with EnvGen (we'll use a sinusoidal envelope with a random duration between
	//2 and 10 seconds):
	env = EnvGen.kr(Env.sine(Rand(2, 10)), doneAction: Done.freeSelf);

	//We'll need to multiply the signal going out by the envelope as well for it to take effect:
	Pan2.ar(sig * amp * env, pan);
}.asDefName;
)

//Testing:
x = Synth(~klang);

//Now let's construct our Synth/OSCFunc combo responsible for spawning our Synths:
(
~spawn = { |rate=5|
	var rand  = LFNoise0.kr(rate).abs;
	var mouse = MouseX.kr;

	//We use SendReply instead of SendTrig in order to be able to send an array of values. As an added bonus,
	//SendReply allows for the specification of OSC path names; it's not hard-coded like SendTrig's!
	//An Impulse UGen oscillating at 30 times a second will act as our trigger:
	SendReply.kr(Impulse.kr(30), '/spawn', [rand, mouse]);
}.play;

//While not strictly necessary, we assign index 3 of our OSC message (the random number) to a variable named
//'rand' to avoid confusion. Likewise, index 4 (the MouseX value) is set to a variable named 'mouse'.
OSCFunc({ |msg|
	var rand  = msg[3];
	var mouse = msg[4];

	//If the random number received is greater than 0.5, move to the next conditional, otherwise do nothing:
	if (rand > 0.5) {
		// If the MouseX value is less than 0.5, spawn ~klank with random panning, else spawn ~klang with random panning:
		if (mouse < 0.5) { Synth(~klank, [\pan, rrand(-1.0, 1.0)]) } { Synth(~klang, [\pan, rrand(-1.0, 1.0)]) };
	};
}, '/spawn'); //This OSCFunc is listening over path '/spawn'
)

