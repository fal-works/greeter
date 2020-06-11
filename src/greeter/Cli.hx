package greeter;

import haxe.ds.ReadOnlyArray;
import greeter.implementation.CliInstances;

/**
	Object representing a CLI that abstracts system-specific behavior.
**/
class Cli {
	/**
		CLI of the current system.
	**/
	public static var current(get, never): Cli;

	/**
		Unix CLI.
	**/
	public static var unix(get, never): Cli;

	/**
		DOS CLI.
	**/
	public static var dos(get, never): Cli;

	static extern inline function get_current()
		return CliInstances.current;

	static extern inline function get_unix()
		return CliInstances.unix;

	static extern inline function get_dos()
		return CliInstances.dos;

	/**
		CLI type that can be used for `switch` expressions.
	**/
	public final type: CliType;

	/**
		The name of `this` CLI.
	**/
	public final name: String;

	/**
		Character code for dividing one command line into multiple lines.
	**/
	public final lineDivider: String;

	/**
		A default list of separators that are accepted by an option
		if no other rule is provided to an `OptionParseRules` instance.
	**/
	public final defaultAcceptedOptionSeparators: ReadOnlyArray<OptionSeparator>;

	/**
		List of separators that can be used for parsing key-value options on `this` CLI.
	**/
	public final keyValueOptionSeparators: ReadOnlyArray<OptionSeparator>;

	function new(
		type: CliType,
		name: String,
		lineDivider: String,
		defaultAcceptedOptionSeparators: ReadOnlyArray<OptionSeparator>,
		keyValueOptionSeparators: ReadOnlyArray<OptionSeparator>
	) {
		this.type = type;
		this.name = name;
		this.lineDivider = lineDivider;
		this.defaultAcceptedOptionSeparators = defaultAcceptedOptionSeparators;
		this.keyValueOptionSeparators = keyValueOptionSeparators;
	}

	/**
		Parses raw argument strings and converts them to a `CommandLine` instance.
		Sub-command names are parsed as `CommandArgument.Parameter` as well as other parameter values.
		@param args The first element must be a command name.
	**/
	@:access(greeter.RawArgument)
	public function parseCommandLine(
		args: Array<String>,
		?optionParseRules: OptionParseRules
	): CommandLine {
		return Parser.parseCommandLine(
			args.map(s -> new RawArgument(s)),
			optionParseRules,
			this
		);
	}

	/**
		Parses all argument strings that were passed (via `Sys.args()`).
		@return Arguments as a list of `CommandArgument`.
	**/
	@:access(greeter.RawArgument)
	public function parseArguments(
		?optionParseRules: OptionParseRules
	): CommandArgumentList {
		return Parser.parseArguments(
			Sys.args().map(s -> new RawArgument(s)),
			optionParseRules,
			this
		);
	}

	/**
		@return `true` if `this` CLI accepts `switchar` as a command option switchar.
	**/
	public function acceptsSwitchar(switchar: Switchar): Bool
		throw "This method must be overridden by a sub-class.";

	/**
		@return `true` if `this` CLI accepts `separator` as a command option separator.
	**/
	public function acceptsOptionSeparator(separator: OptionSeparator): Bool
		throw "This method must be overridden by a sub-class.";

	/**
		@return String that can be used as a single command line argument.
	**/
	public function quoteArgument(s: String): String
		throw "This method must be overridden by a sub-class.";
}
