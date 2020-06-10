package greeter;

using StringTools;

class Parser {
	/**
		Parses raw argument strings and converts them to a `CommandLine` instance.
		Sub-command names are parsed as `CommandArgument.Parameter` as well as other parameter values.
		@param args The first element must be a command name.
	**/
	public static function parseCommandLine(
		args: Array<RawArgument>,
		?optionParseRules: OptionParseRules,
		?cli: CommandLineInterface
	): CommandLine {
		final arguments = parseArguments(args, optionParseRules, cli);
		final firstArgument = arguments.shift();
		if (firstArgument.isNone()) throw 'Passed no arguments.';

		final commandName = switch firstArgument.unwrap() {
			case Parameter(s): s;
			default: throw 'The first argument "${firstArgument.unwrap().toString()}" must be a command name.';
		}

		return new CommandLine(commandName, arguments);
	}

	/**
		Parses raw argument strings and converts them to a list of `CommandArgument`.
	**/
	public static function parseArguments(
		args: Array<RawArgument>,
		?optionParseRules: OptionParseRules,
		?cli: CommandLineInterface
	): CommandArgumentList {
		final optionParseRules = if (optionParseRules != null) optionParseRules else
			OptionParseRules.from([]);
		final cli = if (cli != null) cli else CommandLineInterface.current;

		var index = 0;
		final length = args.length;
		final parsed: CommandArgumentList = [];

		inline function hasNext()
			return index < length;

		inline function next()
			return args[index++];

		inline function nextIsParameter()
			return hasNext() && args[index].isNotOption(cli);

		while (hasNext()) {
			final arg = next();

			// Try splitting this argument to a switchar and the remaining string
			var switchar: Switchar;
			var optionStr: String;
			switch arg.getType(cli) {
				case Parameter(value):
					parsed.push(Parameter(value));
					continue;
				case Option(rawOption):
					switchar = rawOption.switchar;
					optionStr = rawOption.optionString;
				case OnlySwitchar(sw):
					switch sw {
						case DoubleHyphen:
							// The next argument is just a parameter string even if it starts with switchar
							parsed.push(Parameter(next()));
						default:
							throw 'Unsupported argument: $sw';
					}
					continue;
			}

			// Try parsing non-separated option e.g. -Dval
			final nonSeparatedOption = tryParseNonSeparatedOption(
				switchar,
				optionStr,
				optionParseRules
			);
			if (nonSeparatedOption.isSome()) {
				parsed.push(nonSeparatedOption.unwrap());
				continue;
			}

			// Try parsing key=value e.g. -F=myFile
			var kvFound = false;
			for (kvSeparator in cli.keyValueOptionSeparators) {
				final kvOption = tryParseKeyValue(
					switchar,
					optionStr,
					kvSeparator,
					optionParseRules
				);
				if (kvOption.isSome()) {
					parsed.push(kvOption.unwrap());
					kvFound = true;
					break;
				}
			}
			if (kvFound) continue;

			// Now this string must be just an option name and doesn't contain any parameter value
			final optionName = optionStr;

			// Try parsing space-separated parameter e.g. --file myFile
			if (optionParseRules.acceptsSeparator(switchar, optionName, Space)) {
				if (nextIsParameter()) {
					parsed.push(OptionParameter(switchar, optionName, Space, next()));
					continue;
				}
			}

			// Now this argument must be just a single option without parameter
			parsed.push(OptionUnit(switchar, optionName));
		}

		return parsed;
	}

	/**
		Tries parsing non-separated option,
		e.g. -Dval -> { switchar: Hyphen, name: "D", separator: None, value: "val" }.
	**/
	static function tryParseNonSeparatedOption(
		switchar: Switchar,
		optionStr: String,
		optionParseRules: OptionParseRules
	): Maybe<CommandArgument> {
		final nspOptionNames = optionParseRules.getNonSeparatedParameterOptionNames(switchar);
		final optionStrLen = optionStr.length;

		for (name in nspOptionNames) {
			final nameLen = name.length;
			if (optionStrLen <= nameLen) continue;
			if (!optionStr.startsWith(name)) continue;

			final arg: CommandArgument = OptionParameter(
				switchar,
				name,
				None,
				optionStr.substr(nameLen)
			);
			return Maybe.from(arg);
		}

		return Maybe.none();
	}

	/**
		Try parsing key=value,
		e.g. -F=myFile -> { switchar: Hyphen, name: "F", separator: Equal, value: "myFile" }
	**/
	static function tryParseKeyValue(
		switchar: Switchar,
		optionStr: String,
		separator: OptionSeparator,
		optionParseRules: OptionParseRules
	): Maybe<CommandArgument> {
		final separatorPosition = optionStr.getIndexOf(separator);
		if (separatorPosition.isNone()) return Maybe.none();

		final pos = separatorPosition.unwrap();
		final key = optionStr.substr(0, pos);
		if (!optionParseRules.acceptsSeparator(switchar, key, separator))
			return Maybe.none(); // This option does not accept this separator

		final value = optionStr.substr(pos + 1);
		final arg: CommandArgument = OptionParameter(
			switchar,
			key,
			separator,
			value
		);
		return Maybe.from(arg);
	}
}
