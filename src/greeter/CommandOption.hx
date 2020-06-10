package greeter;

/**
	Command option consisting of a `Switchar` and a name, e.g. `--version`.
**/
@:notNull @:forward
abstract CommandOption(Data) from Data {
	@:op(A==B) public extern inline function equals(other: CommandOption): Bool
		return this.switchar == other.switchar && this.name == other.name;

	/**
		@return `String` representation of `this` without quoting or escaping.
	**/
	@:to public extern inline function toString(): String
		return this.switchar + this.name;

	/**
		@return `String` that can be used as a single command line argument in `cli`.
	**/
	public extern inline function quote(cli: CommandLineInterface): String
		return cli.quoteArgument(toString());
}

#if eval
private typedef Data = {
	/**
		Switch character.
	**/
	final switchar: Switchar;

	/**
		Option name.
	**/
	final name: String;
};
#else
@:structInit
private class Data {
	/**
		Switch character.
	**/
	public final switchar: Switchar;

	/**
		Option name.
	**/
	public final name: String;

	public function new(switchar: Switchar, name: String) {
		this.switchar = switchar;
		this.name = name;
	}
}
#end
