package greeter;

/**
	A semantic unit consisting of one or more tokens that may be passed to a command.
**/
@:using(greeter.CommandArgument.CommandArgumentExtension)
enum CommandArgument {
	Parameter(value: String);
	OptionUnit(option: CommandOption);
	OptionParameter(
		option: CommandOption,
		separator: OptionSeparator,
		value: String
	);
}

class CommandArgumentExtension {
	/**
		Converts a `CommandArgument` to `String` without quoting or escaping.
	**/
	public static function toString(arg: CommandArgument): String {
		return switch arg {
			case Parameter(value): value;
			case OptionUnit(option): option.toString();
			case OptionParameter(option, separator, value):
				'${option.toString()}$separator$value';
		}
	}

	/**
		@return `String` that can be used in `cli`.
	**/
	public static function quote(arg: CommandArgument, cli: Cli): String {
		return switch arg {
			case Parameter(value): cli.quoteArgument(value);
			case OptionUnit(option):
				final switchar = option.switchar;
				validateSwitchar(cli, switchar);
				cli.quoteArgument(switchar + option.name);
			case OptionParameter(option, separator, value):
				final switchar = option.switchar;
				validateSwitchar(cli, switchar);
				validateOptionSeparator(cli, separator);
				switch separator {
					case Space: '${cli.quoteArgument(switchar + option.name)}$separator${cli.quoteArgument(value)}';
					default: cli.quoteArgument('$switchar${option.name}$separator$value');
				}
		}
	}

	static extern inline function validateSwitchar(cli: Cli, switchar: Switchar): Void
		if (!cli.acceptsSwitchar(switchar))
			throw 'Invalid argument. ${cli.name} does not accept switchar: \"$switchar\"';

	static extern inline function validateOptionSeparator(
		cli: Cli,
		separator: OptionSeparator
	): Void
		if (!cli.acceptsOptionSeparator(separator))
			throw 'Invalid argument. ${cli.name} does not accept option separator: \"$separator\"';
}
