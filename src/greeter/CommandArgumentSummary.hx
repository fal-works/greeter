package greeter;

/**
	Summary of a `CommandArgumentList`.
	- Stores command parameters and options in separated lists.
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

		final commandParameters: Array<String> = [];
		final optionParametersMap = new Map<CommandOption, Array<String>>();

		for (arg in commandArguments) switch arg {
			case Parameter(value):
				commandParameters.push(value);
			case OptionUnit(option):
				option = getRepresentativeOption(option);
				if (!optionParametersMap.exists(option))
					optionParametersMap.set(option, []);
			case OptionParameter(option, _, value):
				option = getRepresentativeOption(option);
				final commandParameters = optionParametersMap.get(option);
				if (commandParameters != null) commandParameters.push(value);
				else optionParametersMap.set(option, [value]);
		}

		return {
			commandParameters: commandParameters,
			optionParametersMap: optionParametersMap
		};
	}

	/**
		List of parameters.
	**/
	public final commandParameters: Array<String>;

	/**
		Mapping from options to their values.
	**/
	public final optionParametersMap: Map<CommandOption, Array<String>>;

	/**
		Formats `this` and returns as `String`.
	**/
	public function toString(): String {
		var s = 'command parameters: \n';
		final params = this.commandParameters;
		if (params.length == 0) s += "  (none)\n";
		else for (param in params) s += '  $param\n';

		s += 'options: \n';
		for (option => params in this.optionParametersMap) {
			final paramsStr = switch params.length {
				case 0: "";
				case 1: ' ${params[0]}';
				default: ' ${params.toString()}';
			}
			s += '  ${option.toString()}$paramsStr\n';
		}
		return s;
	}

	function new(
		commandParameters: Array<String>,
		optionParametersMap: Map<CommandOption, Array<String>>
	) {
		this.commandParameters = commandParameters;
		this.optionParametersMap = optionParametersMap;
	}
}
