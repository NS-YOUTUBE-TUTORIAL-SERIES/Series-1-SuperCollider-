//EPISODE 12 CODE EXAMPLES (https://youtu.be/6XdTV1mVBC4)

/*I. NodeProxies*/

//As usual, let's boot the server:
s.options.memSize_(2 pow: 20);
s.boot;

//NodeProxies can be instanced in any of the following ways:

//1) Manually, where a NodeProxy is declared and later set to some source Object.

(
~mouseNP = NodeProxy.control;
~mouseNP.source_({ MouseX.kr.poll(10) });
//~mouseNP.source = { MouseX.kr.poll(10) }; //alternative notation
)

//2) Using ProxySpace.

(
p = ProxySpace.push(s); //can replace s with s.boot if the server is not yet booted

~mousePS = { MouseX.kr.poll(10) };
)

//3) Using the NodeProxy definition class (Ndef).

Ndef(\mouseNd, { MouseX.kr.poll(10) });

/*
The first method is the "long way" of utilizing NodeProxies. The main advantages of this include:
	- One can continue to use environmental variables normally.
	- One can assign NodeProxies to environmental variables.

The primary disadvantage is that it's quite a bit more cumbersome to write, as one needs to manually initialize
a NodeProxy and then specify the proxy's source via the .source method.

The second method, ProxySpace, allows the programmer to set up special Environments in which NodeProxies can be
stored. The main advantages to this approach are:
	- One can assign NodeProxies to environmental variables
	- One can create multiple banks of NodeProxies (i.e. multiple ProxySpaces) and switch between them
	- NodeProxy creation is handled automatically, so one can set the source directly to the variable (without
      needing to use .source).

The primary disadvantages are:
	- One can no longer use environmental variables normally without popping out of ProxySpace
	- One cannot create and play a proxy in one instruction.
	  ~variable = { function }.play;
	  This will still work like Function.play; despite being set to an environmental variable! One needs to
      separate the instructions like so:
	  ~variable.play; ~variable = { function };

The third method, Ndef, behaves much like ProxySpace, except that all Ndefs are stored in only one ProxySpace
(so there is no environmental switching), and it uses SynthDef-like syntax. Its main advantages include:
	- No need to declare a ProxySpace; one is created automatically when the Interpreter starts.
	- One can create and play a proxy in one instruction. Ndef(\proxy, { function }).play; works as intended.
	- One can continue to use environmental variables normally.
The primary disadvantages include:
	- One cannot switch between ProxySpaces, so one cannot have two Ndefs share the same name.
      (I've not found this to be an issue in practice, however.)
	- More problematic is that the syntax is a bit cumbersome, leading to cluttered-looking code fairly quickly.
*/

//ProxySpace is my preferred method, mainly because it's much cleaner and neater to use for live coding. One can
//find plenty of examples online of code using any one of these methods, so feel free to pick your poison for
//your own projects.

/*II. Working with ProxySpace*/

//You don't have to execute the following lines if your server is still booted and your session is still
//popped into ProxySpace. If you started over, however, please execute the following:
s.options.memSize_(2 pow: 20);
p = ProxySpace.push(s.boot);

//The following outputs a non-bandlimited pulse wave. While traditional arguments could be used here, I've
//chosen to use NamedControls instead. NamedControls do use slightly more CPU cycles than arguments, but
//for controlling parameters in a UGen have some handy extra features that make them particularly attractive.
//(SC3.10+). Their syntax is \nameOfControl.samplingRate(defaultValue, lag, fixedLag(bool)). Placing a value
//in lag will wrap the control in a Lag UGen, thus smoothing the modulation further.
~out = { LFPulse.ar(\freq.kr(440), 0, \width.kr(0.5), \amp.kr(0.2)).dup };

//The following control rate NodeProxy takes the position of the mouse cursor along the Y axis and maps the
//value exponentially between 40 and 5120(Hz):
~freq = { MouseY.kr(40, 5120, 1) }; //The '1' in the warp argument denotes exponential mapping.

//The following control rate NodeProxy takes the position of the mouse cursor along the X axis and mpas the
//value linearly between 0 and 0.5. This will be used to control the width of the pulse wave:
~width = { MouseX.kr(0, 0.5) };

//This fades in our pulse wave over an interval of three seconds. Keep in mind that the pulse wave has
//been active all along; it has simply been routed over a private audio bus reserved for the NodeProxy ~out.
//.play adds a secondary routing to the default hardware audio outputs for monitoring: busses 0 and 1.
~out.play(fadeTime: 3);

//.stop stops the monitoring of the NodeProxy, though the signal itself is still going strong over the private
//bus:
~out.stop(0.1); //The only argument for .stop is fadeTime.

//Let's turn on ~out's monitors again:
~out.play;

//In order to patch our control rate NodeProxies into our audio rate ~out, using our NamedControls as inlets,
//the <>> and/or <<> operators must be used. They work as follows:
/*
Source <>>.NamedControl Destination
Destination <<>.NamedControl Source
(Specifying .NamedControl is not necessary when patching to a NamedControl labelled \in.)
*/
//These operators can be combined in a single instruction to facilitate patching two sources to one
//destination:
~freq <>>.freq ~out <<>.width ~width;

/***BONUS (not in video)***/
//To sever a control rate connection between two proxies, simply use the .unmap instance method of NodeProxy:
~out.unmap(\freq);
~out.unmap(\width);