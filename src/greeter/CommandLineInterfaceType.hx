package greeter;

/**
	CLI type that can be used for `switch` expressions.
**/
enum abstract CommandLineInterfaceType(Int) {
	final Unix;
	final Dos;
}
