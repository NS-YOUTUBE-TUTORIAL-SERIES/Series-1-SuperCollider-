//EPISODE 13 CODE EXAMPLES (https://youtu.be/kA25Et4Q5bk)

/*II. Our First Sound*/

//Let's boot the server and push our ProxySpace:
s.options.memSize_(2 pow: 20);
p = ProxySpace.push(s.boot);

//We start by writing a function, iterating over a do-loop, that populates eight buffers with waveform and
//amplitude data.
(
8.do { |i|
	//This creates an array that is first filled with as many zeros as the current iteration dictates
	//(i.e., no zeros during the first iteration, one zero during the second, and so on), followed by
	//0.5, 1, and 0.5. This array provides amplitude data for each represented harmonic.
	var a = Array.fill(i, 0) ++ [0.5, 1, 0.5];

	//The following instruction sends a message to the server to allocate a buffer in memory, assign it the
	//ID of whatever 'i' happens to be in the current iteration, and gives it a length of 1024 samples.
	s.sendMsg(\b_alloc, i, 1024);

	//Since we're passing an array of data to the server, we have to use the .performList instance method
	//instead of .sendMsg here (though with a \sendMsg message included). '\b_gen' tells the server to fill
	//a buffer, with the ID of the current value of 'i'. VOsc3 requires the use of the '\sine1' message, to which
	//we specify flag code 7, or 'normalize + wavetable + clear' (see the Server Command Reference help file
	//for more information), and the amplitude array 'a'.
	s.performList(\sendMsg, \b_gen, i, \sine1, 7, a);
};
)

//For the second signal of our forthcoming NodeProxy Synth, we'll need another set of eight buffers.
(
8.do { |i|
	//Since our first set of buffers began with the ID of 0, we'll need to offset our second batch by 8.
	var newIndex = i + 8;
	var n = (i + 1) * 8;
	var a;

	//We must ensure that our newIndex variable is used to assign buffer IDs instead of 'i'.
	s.sendMsg(\b_alloc, newIndex, 1024);

	//As we want our second signal in our NodeProxy to fade in once the mouse cursor hits a certain horizontal
	//threshold, we ensure that NodeIDs of 8, 9, and 10 are silent. We can achieve this effect by the use
	//of an if-then statement.
	if (newIndex < 11) { a = Array.fill(n, 0) } {
		a = Array.fill(n, 0);

		//Bitwise arithmetic operators will be explored in greater depth down the road, but for now content
		//yourself with the understanding that, for a certain number of randomly-selected partials in the signal,
		//their otherwise zeroed-out amplitude will be replaced by a one, or maximum, amplitude.
		(n >> 1).do { a[n.rand] = 1 }
	};

	s.performList(\sendMsg, \b_gen, newIndex, \sine1, 7, a);
};
)

/***BONUS (not in video)***/
//To see the values of the bit-shifted 'n' over each iteration of the do-loop, execute the following code:
(
8.do { |i|
	var n = (i + 1) * 8;

	(n >> 1).postln;
}
)

//Furthermore, it occurred to me that a more elegant solution to the second buffer-filling function is as
//follows, as 'a = Array.fill(n, 0)' is executed whether the if-then statement returns true or false.
(
8.do { |i|
	var newIndex = i + 8;
	var n = (i + 1) * 8;
	var a;

	s.sendMsg(\b_alloc, newIndex, 1024);
	a = Array.fill(n, 0);

	if (newIndex > 10) { (n >> 1).do { a[n.rand] = 1 } };

	s.performList(\sendMsg, \b_gen, newIndex, \sine1, 7, a);
};
)
/***END OF BONUS CONTENT***/

//Now to set up the NodeProxy.

(
//Remember that, in ProxySpace, we CANNOT combine the .play instance method with the proxy itself. It must
//inhabit its own instruction. (This restriction does not apply if you're using the Ndef notation
//alternative.)
~ground.play;

//Since we're using two sets of buffers but only one input solution to choose between them (our computer's
//mouse/trackpad), we need to make sure buffer ID offsets are provided.
~ground = { |bufoffset1=0, bufoffset2=8|
	//mouseX will be used to scrub between the buffers.
	var mouseX  = MouseX.kr(0, 7);

	//mouseY1 will be restricted to a one octave range, beginning at 80Hz by default. The lag argument is
	//used for smooth transitions should one wish to modulate this value.
	var mouseY1 = MouseY.kr(\fund.kr(80, \lag.kr(1)), \fund.kr * 2 * \partial.kr(1, \lag.kr), 1);

	//mouseY2 is mapped similarly, but at an interval of two octaves and a major third above mouseY1.
	var mouseY2 = MouseY.kr(\fund.kr * 5, \fund.kr * 10 * \partial.kr, 1);
	var sig1, sig2, pulse;

	sig1 = VOsc3.ar(
		bufpos: bufoffset1 + mouseX, //sig1 will draw from the first set of 8 buffers
		freq1:  mouseY1 + [0, 1], //1Hz will be added to the signal sent to the right channel
		//.expexp is a mapping convenience function, expecting exponential input and returning
		//exponential output:
		freq2:  mouseY1.expexp(\fund.kr, \fund.kr*2, \fund.kr, \fund.kr*4 ) + [0.33,  1.1 ],
		freq3:  mouseY1.expexp(\fund.kr, \fund.kr*2, \fund.kr, \fund.kr*16) + [0.66, -0.33],
		mul:    0.2
	);

	sig2 = VOsc3.ar(
		bufpos: bufoffset2 + mouseX, //sig2 will draw from the second set of 8 buffers
		freq1:  mouseY2 + [0, 1],
		freq2:  mouseY2.expexp(\fund.kr*5, \fund.kr*10, \fund.kr*5, \fund.kr*20) + [0.33,  1.1 ],
		freq3:  mouseY2.expexp(\fund.kr*5, \fund.kr*10, \fund.kr*5, \fund.kr*40) + [0.66, -0.33],
		mul:    0.1
	);

	//The following sets up a non-band-limited pulse wave generator, oscillating at 440Hz (the default),
	//and with a variable width between 0 and 50%. This results in a timbral quality reminiscent of
	//granular synthesis (though it is not; it's amplitude modulation), and with the UGen.if instruction
	//is only mixed into the signal roughly half the time.
	pulse = LFPulse.kr(width: SinOsc.kr(0.2, 0, 0.5).abs);
	pulse = if (LFNoise1.kr(0.3).abs.round(1).lag(1), 1, pulse); //.lag(1) ensures a smooth 1-second transition

	//We set the pulse wave to modulate sig1, but NOT sig2.
	sig1 * pulse + sig2;
};
)

~ground.set(\fund, 420);
~ground.set(\lag, 10);
~ground.set(\fund, 200);
~ground.set(\fund, 80);
~ground.end(1);

/***BONUS (not in video)***/
//NodeProxy and Ndef alternatives:

x = NodeProxy.audio(s, 2);
(
x.play;
x.source = { |bufoffset1=0, bufoffset2=8|
	var mouseX  = MouseX.kr(0, 7);
	var mouseY1 = MouseY.kr(\fund.kr(80, \lag.kr(1)), \fund.kr * 2  * \partial.kr(1, \lag.kr), 1);
	var mouseY2 = MouseY.kr(\fund.kr * 5,    \fund.kr * 10 * \partial.kr      , 1);
	var sig1, sig2, pulse;

	sig1 = VOsc3.ar(
		bufpos: bufoffset1 + mouseX,
		freq1:  mouseY1 + [0, 1],
		freq2:  mouseY1.expexp(\fund.kr, \fund.kr*2, \fund.kr, \fund.kr*4 ) + [0.33,  1.1 ],
		freq3:  mouseY1.expexp(\fund.kr, \fund.kr*2, \fund.kr, \fund.kr*16) + [0.66, -0.33],
		mul:    0.2
	);

	sig2 = VOsc3.ar(
		bufpos: bufoffset2 + mouseX,
		freq1:  mouseY2 + [0, 1],
		freq2:  mouseY2.expexp(\fund.kr*5, \fund.kr*10, \fund.kr*5, \fund.kr*20) + [0.33,  1.1 ],
		freq3:  mouseY2.expexp(\fund.kr*5, \fund.kr*10, \fund.kr*5, \fund.kr*40) + [0.66, -0.33],
		mul:    0.1
	);

	pulse = LFPulse.kr(width: SinOsc.kr(0.2, 0, 0.5).abs);
	pulse = if (LFNoise1.kr(0.3).abs.round(1).lag(1), 1, pulse);

	sig1 * pulse + sig2;
};
)

x.set(\fund, 420);
x.set(\lag, 10);
x.set(\fund, 200);
x.set(\fund, 80);
x.end(1);

(
Ndef(\ground, { |bufoffset1=0, bufoffset2=8|
	var mouseX  = MouseX.kr(0, 7);
	var mouseY1 = MouseY.kr(\fund.kr(80, \lag.kr(1)), \fund.kr * 2  * \partial.kr(1, \lag.kr), 1);
	var mouseY2 = MouseY.kr(\fund.kr * 5,    \fund.kr * 10 * \partial.kr      , 1);
	var sig1, sig2, pulse;

	sig1 = VOsc3.ar(
		bufpos: bufoffset1 + mouseX,
		freq1:  mouseY1 + [0, 1],
		freq2:  mouseY1.expexp(\fund.kr, \fund.kr*2, \fund.kr, \fund.kr*4 ) + [0.33,  1.1 ],
		freq3:  mouseY1.expexp(\fund.kr, \fund.kr*2, \fund.kr, \fund.kr*16) + [0.66, -0.33],
		mul:    0.2
	);

	sig2 = VOsc3.ar(
		bufpos: bufoffset2 + mouseX,
		freq1:  mouseY2 + [0, 1],
		freq2:  mouseY2.expexp(\fund.kr*5, \fund.kr*10, \fund.kr*5, \fund.kr*20) + [0.33,  1.1 ],
		freq3:  mouseY2.expexp(\fund.kr*5, \fund.kr*10, \fund.kr*5, \fund.kr*40) + [0.66, -0.33],
		mul:    0.1
	);

	pulse = LFPulse.kr(width: SinOsc.kr(0.2, 0, 0.5).abs);
	pulse = if (LFNoise1.kr(0.3).abs.round(1).lag(1), 1, pulse);

	sig1 * pulse + sig2;
}).play;
)

Ndef(\ground).set(\fund, 420);
Ndef(\ground).set(\lag, 10);
Ndef(\ground).set(\fund, 200);
Ndef(\ground).set(\fund, 80);
Ndef(\ground).end(1);