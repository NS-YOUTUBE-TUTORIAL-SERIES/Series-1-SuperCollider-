//EPISODE 10 CODE EXAMPLES (https://youtu.be/eTASSane-GU)

/*II. OSC Responder Functions*/

//First, boot the server via Server > Boot Server.

//Here we'll have a non-interpolating low frequency noise generator produce a new random float between 0.0 and
//1.0 every second. We send the value out via the SendTrig class (which is hardcoded to send over the OSC path
//'/tr'):
(
~test = {
	var sig = LFNoise0.kr(1).abs;

	SendTrig.kr(Impulse.kr(1), value: sig);
}.play;

//The following is an OSCFunc that will pass the entire OSC message sent out by SendTrig into the function,
//posting its contents to the Post Window:
OSCFunc({ |msg, time, addr, recvPort| [msg, time, addr, recvPort].postln }, '/tr');
)

//Command-period will terminate all running OSCFuncs/OSCdefs. One can change this behavior by setting an OSC
//responder function's permanent flag to true, though in the case of OSCFunc it is highly recommended to assign
//it to an interpreter/environmental variable so one has a means of disabling it manually later on:
~resp = OSCFunc({ |msg, time, addr, recvPort| [msg, time, addr, recvPort].postln }, '/tr').permanent_(true);

//Now let's adapt this code so that the trigger is tripped only when the LFNoise generator outputs a value
//above 0.7:
(
~test = {
	var sig  = LFNoise0.kr(1).abs;

	SendTrig.kr(sig > 0.7, value: sig);
}.play;

//The value being sent via SendTrig is located in index 3 of the OSC message:
OSCFunc({ |msg| ("The random number received is" ++ msg[3] ++ ". If not greater than 0.7, then something went wrong.").postln }, '/tr');
)