package greeter;

/**
	Command option consisting of a `Switchar` and a name, e.g. `--version`.
	Each instance is unique for its contents.
**/
@:notNull @:forward
abstract CommandOption(Data) {
	/**
		Stores a set of unique `CommandOption` instances.
	**/
	static final instanceMap = new Map<String, CommandOption>();

	/**
		Returns (or creates if it not exists) an unique instance of `CommandOption`.
	**/
	public static inline function get(
		switchar: Switchar,
		name: String
	): CommandOption {
		final key = switchar + name;
		final instance = Maybe.from(instanceMap.get(key));
		return if (instance.isSome()) instance.unwrap() else {
			final newInstance = new CommandOption({ switchar: switchar, name: name });
			instanceMap.set(key, newInstance);
			newInstance;
		}
	}

	@:op(A == B) public extern inline function equals(other: CommandOption): Bool
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

	extern inline function new(data: Data)
		this = data;
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
