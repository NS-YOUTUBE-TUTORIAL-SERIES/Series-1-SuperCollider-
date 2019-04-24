//EPISODE 2 CODE EXAMPLES (https://youtu.be/knCWBdz98lo)

//First, boot the server via Server > Boot Server.

//The following is a function that will produce a sine wave unit generator, oscillating at its default 440Hz
//at 20% of its max amplitude. The .play instance method allows for the monitoring of the SinOsc's output over
//the user's default audio configuration. (This was our "Hello World" test from Episode 1.)

{ SinOsc.ar(mul: 0.2) }.play; //each instruction must end with a semicolon (;)

//An Alternative syntax to the above is function call notation, where the instance method precedes the class,
//enclosing it within parentheses. (In this case, the class in question is an instance of Function and is
//notated by enclosing its contents in curly braces: { })

play({ SinOsc.ar(mul: 0.2) });

//Instance methods that allow for a function as their first argument (and in which cases any succeeding arguments
//are left blank) can omit the parentheses:

play { SinOsc.ar(mul: 0.2) };

//If instructions take up more than one line, one can either highlight all applicable lines and evaluate them using
//shift-return (Mac)/shift-enter (Linux/Windows), or enclose the code in parentheses, place their cursor inside
//the parentheses (doesn't matter where) and depress command-return (Mac)/control-enter (Linux/Windows):

(
play {
	SinOsc.ar(mul: 0.2);
};
)