package greeter;

/**
	Space-separated argument string before parsed.
**/
@:forward
abstract RawArgument(String) to String {
	static inline final hyphenCode = "-".code;
	static inline final slashCode = "/".code;

	/**
		Determines the type of `this` argument.
	**/
	public function getType(cli: Cli): RawArgumentType {
		final maybeRawOption = tryGetRawOption();
		if (maybeRawOption.isNone())
			return Parameter(this);

		final rawOption = maybeRawOption.unwrap();
		final switchar = rawOption.switchar;
		if (!cli.acceptsSwitchar(switchar))
			return Parameter(this);

		if (rawOption.optionString.length == 0)
			return OnlySwitchar(switchar);

		return Option(rawOption);
	}

	/**
		@return `true` if `this` starts with any switchar character.
	**/
	public function isOption(cli: Cli): Bool {
		if (this.length == 0) return false;
		final firstCode = this.charCodeAt(0);
		return firstCode == hyphenCode
			|| (cli.acceptsSwitchar(Slash) && firstCode == slashCode);
	}

	/**
		@return `true` if `this` does not start with any switchar character.
	**/
	public inline function isNotOption(cli: Cli): Bool
		return !isOption(cli);

	/**
		Tries to split `this` to a switch character and the remaining string.
	**/
	function tryGetRawOption(): Maybe<RawOption> {
		final maybeSwitchar = CommandOption.tryExtractSwitchar(this);
		if (maybeSwitchar.isNone()) return Maybe.none();
		final switchar = maybeSwitchar.unwrap();

		return Maybe.from({
			switchar: switchar,
			optionString: this.substr(switchar.length)
		});
	}

	inline extern function new(s: String)
		this = s;
}

private enum RawArgumentType {
	Parameter(value: String);
	Option(rawOption: RawOption);
	OnlySwitchar(switchar: Switchar);
}

private typedef RawOption = {
	final switchar: Switchar;
	final optionString: String;
};
