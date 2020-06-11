package greeter;

/**
	Command option consisting of a `Switchar` and a name, e.g. `--version`.
	Each instance is unique for its contents.
**/
@:notNull @:forward
abstract CommandOption(Data) to Data {
	static inline final hyphenCode = "-".code;
	static inline final slashCode = "/".code;

	/**
		Stores a set of unique `CommandOption` instances.
	**/
	static final instanceMap = new Map<String, CommandOption>();

	/**
		Returns (or creates if it not exists) an unique instance of `CommandOption`.
	**/
	public static function get(switchar: Switchar, name: String): CommandOption {
		final key = switchar + name;
		final instance = Maybe.from(instanceMap.get(key));

		return if (instance.isSome()) instance.unwrap() else {
			final newInstance = new CommandOption({ switchar: switchar, name: name });
			instanceMap.set(key, newInstance);
			newInstance;
		}
	}

	/**
		Returns an unique instance of `CommandOption`.
		If not yet created, parses `s` and creates a new instance.
	**/
	@:from public static function fromString(s: String): CommandOption {
		final instance = Maybe.from(instanceMap.get(s));

		return if (instance.isSome()) instance.unwrap() else {
			final maybeSwitchar = tryExtractSwitchar(s);
			if (maybeSwitchar.isNone())
				throw 'Failed to create a command option instance. The given string does not start with switchar: $s';

			final switchar = maybeSwitchar.unwrap();
			final name = s.substr(switchar.length);
			final newInstance = new CommandOption({ switchar: switchar, name: name });
			instanceMap.set(s, newInstance);
			newInstance;
		}
	}

	/**
		Tries to extract switchar character(s) from `s`.
		@return `Maybe.none()` if `s` does not start with any switchar.
	**/
	public static function tryExtractSwitchar(s: String): Maybe<Switchar> {
		if (s.length == 0) return Maybe.none();
		final firstCode = s.charCodeAt(0);

		if (firstCode != hyphenCode) {
			if (firstCode == slashCode)
				return Switchar.Slash;
			else
				return Maybe.none();
		}

		if (s.length == 1)
			return Switchar.Hyphen;

		if (s.charCodeAt(1) != hyphenCode)
			return Switchar.Hyphen;

		return Switchar.DoubleHyphen;
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
	public extern inline function quote(cli: Cli): String
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
