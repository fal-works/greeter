package greeter;

/**
	Summary of a `CommandArgumentList`.
	- Stores command values and options in separated lists.
	- If there are multiple argument values for an option, they are listed in a single array.
**/
@:structInit
class CommandArgumentSummary {
	/**
		Creates a summary from `commandArguments`.
		@param optionAliasMap Mapping from alias options to representative options.
	**/
	public static function from(
		commandArguments: CommandArgumentList,
		?optionAliasMap: Map<CommandOption, CommandOption>
	): CommandArgumentSummary {
		final optionAliasMap = if (optionAliasMap != null) optionAliasMap else new Map();

		inline function getRepresentativeOption(option: CommandOption) {
			var current = option;
			var next = optionAliasMap.get(current);

			while (next != null) {
				if (next == option)
					throw 'Circular recursion in the alias map: ${option.toString()}';
				current = next;
				next = optionAliasMap.get(next);
			}

			return current;
		}

		final commandValues: Array<String> = [];
		final optionValuesMap = new CommandOptionValuesMap();

		for (arg in commandArguments) switch arg {
			case Parameter(value):
				commandValues.push(value);
			case OptionUnit(option):
				option = getRepresentativeOption(option);
				if (!optionValuesMap.exists(option))
					optionValuesMap.set(option, []);
			case OptionParameter(option, _, value):
				option = getRepresentativeOption(option);
				final commandValues = optionValuesMap.get(option);
				if (commandValues != null) commandValues.push(value);
				else optionValuesMap.set(option, [value]);
		}

		return {
			commandValues: commandValues,
			optionValuesMap: optionValuesMap
		};
	}

	/**
		List of values provided to the command.
	**/
	public final commandValues: Array<String>;

	/**
		Mapping from options to their values.
	**/
	public final optionValuesMap: CommandOptionValuesMap;

	/**
		Gets the value assuming that just one value has been passed to the command.
		@return The first command value.
		Throws error if zero or multiple command values have been passed.
	**/
	public extern inline function oneCommandValue(): String {
		final values = this.commandValues;
		switch values.length {
			case UInt.zero:
				throw 'Passed no command value.';
			case UInt.one:
				return values.getFirst();
			default:
				throw 'Passed too many command values.';
		}
	}

	/**
		Formats `this` and returns as `String`.
	**/
	public function toString(): String {
		var s = 'command values: \n';
		final values = this.commandValues;
		if (values.isEmpty()) s += "  (none)\n";
		else for (value in values) s += '  $value\n';

		s += 'options: \n';
		for (option => values in this.optionValuesMap) {
			final valuesStr = switch values.length {
				case UInt.zero: "";
				case UInt.one: ' ${values.getFirst()}';
				default: ' ${values.toString()}';
			}
			s += '  ${option.toString()}$valuesStr\n';
		}
		return s;
	}

	function new(
		commandValues: Array<String>,
		optionValuesMap: CommandOptionValuesMap
	) {
		this.commandValues = commandValues;
		this.optionValuesMap = optionValuesMap;
	}
}

/**
	Mapping from each option to a list of values provided for the option.
	Provides methods for getting values with cardinality checks.
**/
@:forward
abstract CommandOptionValuesMap(
	Map<CommandOption, Array<String>>
) to Map<CommandOption, Array<String>> {
	public extern inline function new()
		this = new Map();

	/**
		Gets the value for `option` assuming that only one value is provided.
		- Use `exists()` for just checking if `option` has been passed regardless of its values.
		- Use `zeroOrOne()` if the value is optional for `option`.
		@return The first value for `option`, or `Maybe.none()` if `option` itself is not found.
		Throws error if zero or multiple values have been provided for `option`.
	**/
	public function one(option: CommandOption): Maybe<String> {
		final values = this.get(option);
		if (values == null)
			return Maybe.none();

		switch values.length {
			case UInt.zero:
				throw 'No value provided for option: ${option.toString()}';
			case UInt.one:
				return values.getFirst();
			default:
				throw 'Too many values provided for option: ${option.toString()}';
		}
	}

	/**
		Gets the value for `option` assuming that only zero or one value is provided.
		@return The first value for `option`, or `Zero` if no value, or `Maybe.none()` if `option` is not found.
		Throws error if multiple values have been provided for `option`.
	**/
	public function zeroOrOne(option: CommandOption): Maybe<ZeroOrOne> {
		final values = this.get(option);
		if (values == null)
			return Maybe.none();

		switch values.length {
			case UInt.zero:
				return Maybe.from(ZeroOrOne.Zero);
			case UInt.one:
				return Maybe.from(ZeroOrOne.One(values.getFirst()));
			default:
				throw 'Too many values provided for option: ${option.toString()}';
		}
	}

	/**
		Gets the values for `option` assuming that at least one value is provided.
		@return Values provided for `option`, or `Maybe.none()` if `option` itself is not found.
	**/
	public function oneOrMore(option: CommandOption): Maybe<Array<String>> {
		final values = this.get(option);
		if (values != null && values.isEmpty())
			throw 'No value provided for option: ${option.toString()}';
		return Maybe.from(values).or([]);
	}

	/**
		Gets the values for `option`.
		@return Values provided for `option`, or `Maybe.none()` if `option` itself is not found.
	**/
	public function zeroOrMore(option: CommandOption): Maybe<Array<String>>
		return Maybe.from(this.get(option));
}

private enum ZeroOrOne {
	/**
		Represents that no value has been provided.
	**/
	Zero;

	/**
		Represents that just one value has been provided.
	**/
	One(value: String);
}

private enum ZeroOrMore {
	/**
		Represents that no value has been provided.
	**/
	Zero;

	/**
		Represents that just one value has been provided.
	**/
	One(value: String);

	/**
		Represents that more than one values have been provided.
	**/
	More(values: Array<String>);
}
