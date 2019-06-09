//EPISODE 5 CODE EXAMPLES (https://youtu.be/TFBLvSvRQqM)

//First, boot the server via Server > Boot Server.

//The following code instances two SinOsc UGens, both at 880Hz and with their amplitudes modulated by
//LFPulse UGens. The LFPulse UGens are both themselves pulsing once every two seconds at 20% max amplitude
//and 10% duty cycle, though the LFPulse modulating the second SinOsc is offset by 50% (1 second):
(
~pulse = {
	[ //Arrays (discussed thoroughly in Episode 6) are enclosed between square brackets.
		SinOsc.ar(880, mul: LFPulse.kr(0.5, 0,   0.1, 0.2)), //This SinOsc will be bussed to the left channel (0)
		SinOsc.ar(880, mul: LFPulse.kr(0.5, 0.5, 0.1, 0.2))  //This SinOsc will be bussed to the right channel (1)
	];
}.play;
)

//Our "Hello World" example:

{ SinOsc.ar(mul: 0.2).dup }.play;

//Is actually shorthand for the following:

{ [ SinOsc.ar(mul: 0.2), SinOsc.ar(mul: 0.2) ] }.play;

//In order to modulate parameters of sound-generating functions after compilation, one must use arguments.
//They are similar to variables with the following differences:
/*
    • Arguments must be declared before local variables (if any)
	• Arguments must all be declared in one instruction
	• Arguments can have values passed into a function externally, and
	• Arguments cannot be set to UGens, or be directly set by UGens
*/
//Two syntactical variations for argument declarations exist. The older method, established in SuperCollider 2
//(Mac OS 8/9), makes use of an arg tag:
(
~pulse = { arg freq=880, rate=0.5, width=0.1, amp=0.2;
	[
		SinOsc.ar(freq, mul: LFPulse.kr(rate, 0,   width, amp)),
		SinOsc.ar(freq, mul: LFPulse.kr(rate, 0.5, width, amp))
	];
}.play;
)

//The newer method, introduced in SuperCollider 3, bookends arguments between vertical pipes:
(
~pulse = { |freq=880, rate=0.5, width=0.1, amp=0.2|
	[
		SinOsc.ar(freq, mul: LFPulse.kr(rate, 0,   width, amp)),
		SinOsc.ar(freq, mul: LFPulse.kr(rate, 0.5, width, amp))
	];
}.play;
)

//While both are perfectly valid and popular, the latter method is what will be used in this tutorial series.
//(It often helps to have the extra visual aid to distinguish arguments from variables.)

/***BONUS (not in video)***/
//NamedControls can be used in lieu of arguments, and as of SC 3.10 they provide an extra 'lag' argument that
//can help in smoothing modulation:
(
~pulse = {
	[
		SinOsc.ar(\freq.kr(880), mul: LFPulse.kr(\rate.kr(0.5),   0,   \width.kr(0.1), \amp.kr(0.2))),
		SinOsc.ar(\freq.kr,      mul: LFPulse.kr(\rate.kr,      0.5,   \width.kr,      \amp.kr))
	];
}.play;
)
//NamedControls do not require declaration, but do need sampling rate specified when used (arguments are control
//rate by default). NamedControl defaults are included as the first argument after sampling rate, and lag, if
//any, would be set via the second argument. Their behavior, including everything discussed past this point,
//are identical to arguments, so methods like .set work as expected.
/***END OF BONUS CONTENT***/

//One can now modulate these parameters by use of the .set method:
~pulse.set(\freq, 660); //This changes the frequency to 660Hz for both SinOscs.

//Multiple parameters can be modulated at once:
~pulse.set(\freq, 330, \width, 0.2, \amp, 0.4);
~pulse.release;

//If one wishes to modulate each SinOsc independently, then more arguments are needed:
(
~pulse = { |freq1=880, rate1=0.5, width1=0.1, amp1=0.2,
	        freq2=880, rate2=0.5, width2=0.1, amp2=0.2|
	[
		SinOsc.ar(freq1, 0, LFPulse.kr(rate1,   0, width1, amp1)),
		SinOsc.ar(freq2, 0, LFPulse.kr(rate2, 0.5, width2, amp2))
	];
}.play;
)

//Try out each of the following instructions, and feel free to experiment with your own!
~pulse.set(\freq1, 440, \freq2, 660, \width1, 0.75, \width2, 0.5);
~pulse.set(\rate1, 1, \rate2, 1.5);
~pulse.set(\amp1, 0.3, \amp2, 0.15, \freq1, 220, \freq2, 1320);
~pulse.set(\rate1, 2, \rate2, 3);
~pulse.set(\rate1, 0.33, \rate2, 9);