//EPISODE 9 CODE EXAMPLES (https://youtu.be/XSjbHH7RIqs)

/*I. Server-side Implementation*/

//First, boot the server via Server > Boot Server.

//The following function will return an A major triad when a random number generator returns 1 (i.e. 'true'),
//but a Bb augmented triad if 0, or 'false', is returned. Since LFNoise0 can return negative numbers, let's
//apply the .abs (absolute value) method to the result, followed by .round(1) to make sure the result is rounded
//either up to 1 (>= 0.5) or down to 0 (< 0.5). Finally, .poll will post, in this case 10 times per second, the
//value returned by LFNoise0 to the Post Window so we can keep tabs on it.
(
~rngsin = {
	var rnum = LFNoise0.kr(1).abs.round(1).poll(10);
	var sig1 = Mix(SinOsc.ar([57, 61, 64].midicps, mul: [0.2, 0.1, 0.15])).dup;
	var sig2 = Mix(SinOsc.ar([70, 74, 78].midicps, mul: [0.2, 0.1, 0.15])).dup;

	if (rnum, sig1, sig2); //If rnum is 1, return sig1, else return sig2.
}.play;
)

//However, since LFNoise returns floats, not booleans (i.e. 'true' and 'false'), Any result not precisely 0
//or 1 will return a mixture of the two signals:
(
~rngsin = {
	var rnum = LFNoise1.kr(1).abs.poll(10); //We use LFNoise1 for smoother transitions.
	var sig1 = Mix(SinOsc.ar([57, 61, 64].midicps, mul: [0.2, 0.1, 0.15])).dup;
	var sig2 = Mix(SinOsc.ar([70, 74, 78].midicps, mul: [0.2, 0.1, 0.15])).dup;

	if (rnum, sig1, sig2);
}.play;
)

//This is because the formula used for server-side UGen.if is:
//(receiverUGen * (trueUGen - falseUGen)) + falseUGen
//We can test this as follows, plugging in 0.8 for the trueUGen and 0.2 for the falseUGen:
(1 * (0.8 - 0.2)) + 0.2; //Since the receiver returns 1 ('true'), we get 0.8 (the 'trueUGen').
(0 * (0.8 - 0.2)) + 0.2; //Since the receiver returns 0 ('false'), we get 0.2 (the 'falseUGen')
(0.5 * (0.8 - 0.2)) + 0.2; //Since the receiver returns 0.5, a 50-50 mix of true- and falseUGens is observed (0.5)

//Certain comparative binary operators exist as unit generators. If they would normally evaluate to 'true' on the
//client side, they return 1 on the server. As one might expect, a 'false' comparison results in a 0 value:
(
~rngsin = {
	var rnum = LFNoise0.kr(1).abs.poll(10);
	var sig1 = Mix(SinOsc.ar([57, 61, 64].midicps, mul: [0.2, 0.1, 0.15])).dup;
	var sig2 = Mix(SinOsc.ar([70, 74, 78].midicps, mul: [0.2, 0.1, 0.15])).dup;

	//If the random number is greater than 0.3, then return sig1, else return sig2. (No possibility for mixture.)
	if (rnum > 0.3, sig1, sig2);
}.play;
)
~rngsin.release;

//Binary operator unit generators do not need to compare a fluxuating value to a static one. Two UGens can be
//compared with each other. In this case, we're going to compare the amplitudes of two LFNoise generators.
//If 'rnum1' returns a value lower than 'rnum2', 'sig1' will be output. Otherwise, we will hear 'sig2':

(
~rngsin = {
	var rnum1 = LFNoise0.kr(1).abs.poll(10, "rnum1");
	var rnum2 = LFNoise0.kr(0.25).abs.poll(10, "rnum2");
	var sig1  = Mix(SinOsc.ar([57, 61, 64].midicps, mul: [0.2, 0.1, 0.15])).dup;
	var sig2  = Mix(SinOsc.ar([70, 74, 78].midicps, mul: [0.2, 0.1, 0.15])).dup;

	if (rnum1 < rnum2, sig1, sig2);
}.play;
)
~rngsin.release;

//For some reason, == does not convert to a binary operator UGen automatically. We have to manually set it up
//via the BinaryOpUGen class ourselves:
(
~rngsin = {
	var sig1  = Mix(SinOsc.ar([57, 61, 64].midicps, mul: [0.2, 0.1, 0.15])).dup;
	var sig2  = Mix(SinOsc.ar([70, 74, 78].midicps, mul: [0.2, 0.1, 0.15])).dup;

	//Rounding is necessary here, as human beings typically do not exhibit the precision necessary to place
	//the mouse cursor at exactly the halfway mark on the screen.
	if (BinaryOpUGen('==', MouseX.kr.round(0.1), 0.5), sig1, sig2);
}.play;
)

//A big limitation of UGen.if is that, as it only selects between two UGens, it's impossible to nest multiple
//UGen.ifs. Thankfully, this limitation has a solution: Select and SelectX! Both classes allow for switching
//between as many UGens as one wants (though keep in mind that all UGens will be running regardless of whether
//or not they are actually sounding through one's speakers), though for audible material SelectX should always
//be preferred as it allows for crossfading between sources (switching audio sources with Select will always
//result in an audible pop or click artifact).

//In the following example, a B diminished triad has been added to the mix as sig3:
(
~rngsin = {
	var rnum = LFNoise1.kr(0.66);
	var sig1 = Mix(SinOsc.ar([57, 61, 64].midicps + rnum.midicps, mul: [0.2, 0.1, 0.15])).dup;
	var sig2 = Mix(SinOsc.ar([70, 74, 78].midicps + rnum.midicps, mul: [0.2, 0.1, 0.15])).dup;
	var sig3 = Mix(SinOsc.ar([83, 86, 89].midicps + rnum.midicps, mul: [0.2, 0.1, 0.15])).dup;
	//It's helpful to have MouseX output values between 0 and 2 as there are now three UGens to choose from.
	var mouse = MouseX.kr(0, 2);
	//One fundamental difference between UGen.if and Select/X is that the first entry in the array corresponds
	//to 0, not 1. That is, in UGen.if, if (receiver, n==1, n==0), while in Select/X, [n==0, n==1, n==2...]
	var array = [sig1, sig2, sig3];

	SelectX.ar(mouse, array);
}.play;
)

//To get around the equal power crossfade inherent in SelectX but to avoid the pop inherent in Select, one
//can use SelectX, round to the nearest integer, and then wrap the UGen in a Lag UGen (most simply via the
//.lag convenience method) set to 10ms:
(
~rngsin = {
	var rnum = LFNoise1.kr(0.66);
	var sig1 = Mix(SinOsc.ar([57, 61, 64].midicps + rnum.midicps, mul: [0.2, 0.1, 0.15])).dup;
	var sig2 = Mix(SinOsc.ar([70, 74, 78].midicps + rnum.midicps, mul: [0.2, 0.1, 0.15])).dup;
	var sig3 = Mix(SinOsc.ar([83, 86, 89].midicps + rnum.midicps, mul: [0.2, 0.1, 0.15])).dup;
	//The following is identical to Lag.kr(MouseX.kr(0, 2).round(1), 0.1):
	var mouse = MouseX.kr(0, 2).round(1).lag(0.1);
	var array = [sig1, sig2, sig3];

	SelectX.ar(mouse, array);
}.play;
)

/*II. Logical Operator Equivalents*/

//Logical AND:
~brown = { (MouseX.kr > 0.5) * (MouseY.kr < 0.5) * BrownNoise.ar(0.1) }.play;

//Logical OR:
//(The comparison to 0 prevents multiplication by 2 in case both conditions are true)
~brown = { (MouseX.kr > 0.5) + (MouseY.kr < 0.5) > 0 * BrownNoise.ar(0.1) }.play;

//Logical XOR:
~brown = { BinaryOpUGen('==', (MouseX.kr > 0.5) + (MouseY.kr < 0.5), 1) * BrownNoise.ar(0.1) }.play;