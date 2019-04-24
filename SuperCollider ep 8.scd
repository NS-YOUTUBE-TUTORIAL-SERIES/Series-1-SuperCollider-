//EPISODE 8 CODE EXAMPLES (https://youtu.be/pO_RsBnJmZs)

/*II. Client-side Implementation*/

//The following function generates two random integers between 0 and 9, and compares them to see which is larger:
//(I incorrectly say between 1 and 10 in the video. The function still works as intended, however.)
(
var x, y;

x = 10.rand; //.rand generates a random number between 0 and the receiver, exclusive.
y = 10.rand; //Since no decimal is included, the number returned will be an integer.

("x is equal to " ++ x).postln; //We post the results to the Post Window using .postln.
("y is equal to " ++ y).postln; //++ concatenates the string with the value stored in the respective variable.

//Next we use nested if-then statements:
if (x == y) { "x and y are equivalent".postln } {
	//If x and y are equivalent, post the string "x and y are equivalent", else perform the following:
	if (x > y) { "x is larger".postln } { "y is larger".postln }
	//If x is greater than y, print "x is larger," else print "y is larger."
};
)

//The same code as above without comments:
(
var x, y;

x = 10.rand;
y = 10.rand;

("x is equal to " ++ x).postln;
("y is equal to " ++ y).postln;

if (x == y) { "x and y are equivalent".postln } {
	if (x > y) { "x is larger".postln } { "y is larger".postln }
};
)

//Next we construct a function that will take two user-supplied values and compare them:
(
f = { |x, y| //The first value passed into the function will be assigned to x, the second to y.
	if (x == y) { "Both values are equivalent".postln } {
		if (x > y) { "The first value is larger".postln } { "The second value is larger".postln }
	};
}
)

//Now we test our function:
f.value(1, 2); //This runs the function plugging 1 into x and 2 into y.
f.value(15.7, 3.33); //Floats work just fine.

//A syntactical shortcut to .value is simply omitting the word "value" after the dot:
f.(8, 8);

//Problems with our code arise under the following circumstances:
f.(); //States both values are equivalent when nothing is passed into the function.
f.(0.666); //Throws a "binary operator '>' failed" error to the Post Window.

//The first of those instructions does not return an error because, if nothing is passed into the function,
//both x and y are set to nil. As such, checking for their equivalence evaluates to true.
//The second throws an error as SuperCollider doesn't understand the comparison between 0.666 and nil, the
//former being a float and the second simply uninitialized data.

//We can have the function throw a more meaningful error message — as well as produce an error message when
//not supplying any values to compare — by prepending the following conditional (|| is the operator for
//logical OR):
(
f = { |x, y|
	if ((x == nil) || (y == nil)) { "Not enough values for a comparison!".throw };
	//If x is nil OR if y is nil, throw an error to the Post Window stating there are not enough values for
	//a comparison.
	if (x == y) { "Both values are equivalent".postln } {
		if (x > y) { "The first value is larger".postln } { "The second value is larger".postln }
};
}
)

//Finally, let's expand this function to allow for the option of comparing three integers or floats:

(
f = { |x, y, z| //We add a third argument to our declaration list.
	if (z.notNil) { //If indeed three arguments are supplied:
		case //As soon as a condition in the list evaluates as true, the action is performed and the instruction stops.
		{ (x > y) && (x > z) } { "The first value is the largest".postln }
		{ (y > x) && (y > z) } { "The second value is the largest".postln }
		{ (z > x) && (z > y) } { "The third value is the largest".postln }
		{        x > z       } { "The first two values are equivalent and larger than the third".postln }
		{        x > y       } { "The first and third values are equivalent and larger than the second".postln }
		{        y > x       } { "The last two values are equivalent and larger than the first".postln }
		{        true        } { "All three values are equivalent".postln }
		//'true' marks the default behavior of the case statement.
	} { //If two or fewer arguments are provided:
		if ((x == nil) || (y == nil)) { "Not enough values for a comparison!".throw };
		if (x == y) { "Both values are equivalent".postln } {
			if (x > y) { "The first value is larger".postln } { "The second value is larger".postln }
		};
	};
};
)

//Let's test our new and improved function:
f.(3, 5, 7);
f.(6, 8); //If only two arguments are provided, the function swaps to the older behavior.
f.(9);
f.(9, 8, 7);
f.(10, 10, 10);