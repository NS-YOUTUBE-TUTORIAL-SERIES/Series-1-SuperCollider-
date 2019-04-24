//EPISODE 3 CODE EXAMPLES (https://youtu.be/EEeNZc2sRpw)

/*I. Help Browser and SuperCollider Class Arguments*/

//First, boot the server via Server > Boot Server.

//This plays a sawtooth wave with middle C as its fundamental pitch, at 20% max amplitude, out of the left channel (0):
{ Saw.ar(261, 0.2) }.play;

//The .dup instance method duplicates this signal, emitting a carbon copy of the audio out of the right channel (1):
{ Saw.ar(261, 0.2).dup }.play;

//The following is our "Hello World" test with all relevant arguments included (.dup appended this time):
{ SinOsc.ar(440, 0, 0.2).dup }.play; //440Hz, no phase offset, 0.2x max amplitude

//Alternatively, one can use the .midicps (MIDI note value -> cycles per second) and .dbamp (dB[FS] -> amplitude
//multiplier) conversion methods if one is more comfortable using these units instead (or if it makes more sense
//to in a particular context):
{ Saw.ar(60.midicps, -14.dbamp).dup }.play;

//Function call notation works rather nicely with these methods:
{ Saw.ar(midicps(60), dbamp(-14)).dup }.play;

/*II. Interpreter and Environmental Variables*/

//Similar to the Saw wave above, but using a non-band-limited triangle wave generator instead:
{ LFTri.ar(64.midicps, -16.dbamp).dup }.play;

//One can assign both of these functions to interpreter variables:
(
x = { Saw.ar(60.midicps, -14.dbamp).dup }.play;
y = { LFTri.ar(64.midicps, -16.dbamp).dup }.play;
)

//Then use either .free or .release to end playback:
x.free; //Immediate release, will most likely result in a pop or click unless sound has already died out
y.release; //Imposes a 0.1 second release by default, mitigating pops and clicks

//.release has a fadeTime argument which allows one to control the length of the release. For example:
y.release(1); //...will fade out the triangle wave over 1 second.

//In case one ever accidentally overwrites the interpreter variable 's', this is how normal functionality
//can be restored:
Server.default = s = Server.local;

//Environmental ~variables can be used in lieu of interpreter variables for more descriptive naming possibilities:
(
~saw = { Saw.ar(60.midicps, -14.dbamp).dup }.play;
~tri = { LFTri.ar(64.midicps, -16.dbamp).dup }.play;
)

~saw.release(2); ~tri.release(1);