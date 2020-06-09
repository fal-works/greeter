package greeter;

/**
	Separator character between a command option and its argument.
**/
enum abstract OptionSeparator(String) to String {
	final None = "";
	final Space = " ";
	final Equal = "=";
	final Colon = ":"; // for DOS
}
