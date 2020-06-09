package greeter;

/**
	A semantic unit consisting of one or more tokens that may be passed to a command.
**/
@:using(greeter.CommandArgument.CommandArgumentExtension)
enum CommandArgument {
	Parameter(value: String);
	OptionUnit(switchar: Switchar, name: String);
	OptionParameter(
		switchar: Switchar,
		name: String,
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
			case OptionUnit(switchar, name): '$switchar$name';
			case OptionParameter(switchar, name, separator, value):
				'$switchar$name$separator$value';
		}
	}

	/**
		@return `String` that can be used in `cli`.
	**/
	public static function quote(
		arg: CommandArgument,
		cli: CommandLineInterface
	): String {
		return switch arg {
			case Parameter(value): cli.quoteArgument(value);
			case OptionUnit(switchar, name):
				validateSwitchar(cli, switchar);
				'$switchar${cli.quoteArgument(name)}';
			case OptionParameter(switchar, name, separator, value):
				validateSwitchar(cli, switchar);
				validateOptionSeparator(cli, separator);
				'$switchar${cli.quoteArgument(name)}$separator${cli.quoteArgument(value)}';
		}
	}

	static extern inline function validateSwitchar(
		cli: CommandLineInterface,
		switchar: Switchar
	): Void
		if (!cli.acceptsSwitchar(switchar))
			throw 'Invalid argument. ${cli.name} does not accept switchar: \"$switchar\"';

	static extern inline function validateOptionSeparator(
		cli: CommandLineInterface,
		separator: OptionSeparator
	): Void
		if (!cli.acceptsOptionSeparator(separator))
			throw 'Invalid argument. ${cli.name} does not accept option separator: \"$separator\"';
}
