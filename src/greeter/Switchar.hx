package greeter;

/**
	Character(s) preceding an option name in a command line.
**/
@:forward
enum abstract Switchar(String) to String {
	final Hyphen = "-";
	final DoubleHyphen = "--";
	final Slash = "/"; // for DOS
}
