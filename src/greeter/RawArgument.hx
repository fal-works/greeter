package greeter;

/**
	Space-separated argument string before parsed.
**/
@:forward
abstract RawArgument(String) to String {
	static inline final hyphenCode = "-".code;
	static inline final slashCode = "/".code;
	static final emptyString = "";

	/**
		Determines the type of `this` argument.
	**/
	public function getType(cli: CommandLineInterface): RawArgumentType {
		final maybeRawOption = tryGetRawOption(cli);
		if (maybeRawOption.isNone()) return Parameter(this);
		final rawOption = maybeRawOption.unwrap();

		if (rawOption.optionString.length == 0)
			return OnlySwitchar(rawOption.switchar);

		return Option(rawOption);
	}

	/**
		@return `true` if `this` starts with any switchar character.
	**/
	public function isOption(cli: CommandLineInterface): Bool {
		if (this.length == 0) return false;
		final firstCode = this.charCodeAt(0);
		return firstCode == hyphenCode
			|| (cli.acceptsSwitchar(Slash) && firstCode == slashCode);
	}

	/**
		@return `true` if `this` does not start with any switchar character.
	**/
	public inline function isNotOption(cli: CommandLineInterface): Bool
		return !isOption(cli);

	/**
		Tries to split `this` to a switch character and the remaining string.
	**/
	function tryGetRawOption(cli: CommandLineInterface): Maybe<RawOption> {
		if (this.length == 0) return Maybe.none();
		final firstCode = this.charCodeAt(0);

		if (firstCode != hyphenCode) {
			if (cli.acceptsSwitchar(Slash) && firstCode == slashCode)
				return { switchar: Switchar.Slash, optionString: this.substr(1) };

			return Maybe.none();
		}

		if (this.length == 1)
			return { switchar: Switchar.Hyphen, optionString: emptyString };

		if (this.charCodeAt(1) != hyphenCode) {
			// multiple option (e.g. -ab as -a -b) is not supported
			return { switchar: Switchar.Hyphen, optionString: this.substr(1) };
		}

		return { switchar: Switchar.DoubleHyphen, optionString: this.substr(2) };
	}

	inline extern function new(s: String)
		this = s;
}

private enum RawArgumentType {
	Parameter(value: String);
	Option(rawOption: RawOption);
	OnlySwitchar(switchar: Switchar);
}

private typedef RawOption = { switchar: Switchar, optionString: String };
