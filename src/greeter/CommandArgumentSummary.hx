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
		Returns the first command value.
		Throws error if zero or multiple command values were provided to the command.
	**/
	public extern inline function getSingleCommandValue(): String {
		final values = this.commandValues;
		switch values.length {
			case 0:
				throw 'Found no command value.';
			case 1:
				return values[0];
			default:
				throw 'Too many command values.';
		}
	}

	/**
		Formats `this` and returns as `String`.
	**/
	public function toString(): String {
		var s = 'command values: \n';
		final values = this.commandValues;
		if (values.length == 0) s += "  (none)\n";
		else for (value in values) s += '  $value\n';

		s += 'options: \n';
		for (option => values in this.optionValuesMap) {
			final valuesStr = switch values.length {
				case 0: "";
				case 1: ' ${values[0]}';
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
**/
@:forward
abstract CommandOptionValuesMap(
	Map<CommandOption, Array<String>>
) to Map<CommandOption, Array<String>> {
	public extern inline function new()
		this = new Map();

	/**
		Returns the first value for `option`.
		Throws error if `option` is not found, or if zero or multiple values were provided for `option`.
	**/
	public extern inline function getSingle(option: CommandOption): String {
		final values = this.get(option);
		if (values == null)
			throw 'Option not found: ${option.toString()}';

		switch values.length {
			case 0:
				throw 'No value provided for option: ${option.toString()}';
			case 1:
				return values[0];
			default:
				throw 'Too many values provided for option: ${option.toString()}';
		}
	}

	/**
		@return Values provided for `option` in `Maybe` representation.
		`Maybe.none()` if `option` is not found.
	**/
	public extern inline function tryGet(option: CommandOption): Maybe<Array<String>>
		return Maybe.from(this.get(option));
}
