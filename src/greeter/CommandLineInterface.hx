package greeter;

import haxe.SysTools;
import haxe.ds.ReadOnlyArray;

/**
	Object representing a CLI that abstracts system-specific behavior.
**/
class CommandLineInterface {
	/**
		CLI of the current system.
	**/
	public static var current(get, never): CommandLineInterface;

	static extern inline function get_current()
		return CommandLineInterfaceSet.current;

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
	public final defaultAcceptedSeparators: ReadOnlyArray<OptionSeparator>;

	/**
		List of separators that can be used for parsing key-value options on `this` CLI.
	**/
	public final keyValueOptionSeparators: ReadOnlyArray<OptionSeparator>;

	function new(
		type: CliType,
		name: String,
		lineDivider: String,
		defaultAcceptedSeparators: ReadOnlyArray<OptionSeparator>,
		keyValueOptionSeparators: ReadOnlyArray<OptionSeparator>
	) {
		this.type = type;
		this.name = name;
		this.lineDivider = lineDivider;
		this.defaultAcceptedSeparators = defaultAcceptedSeparators;
		this.keyValueOptionSeparators = keyValueOptionSeparators;
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

class UnixCli extends CommandLineInterface {
	function new() {
		final separators: ReadOnlyArray<OptionSeparator> = [Equal];
		super(Unix, "Unix", "\\", separators, separators);
	}

	override public inline function acceptsSwitchar(switchar: Switchar): Bool
		return switch switchar {
			case Hyphen: true;
			case DoubleHyphen: true;
			case Slash: false;
		};

	override public inline function acceptsOptionSeparator(
		separator: OptionSeparator
	): Bool
		return switch separator {
			case None: true;
			case Space: true;
			case Equal: true;
			case Colon: false;
		}

	override public inline function quoteArgument(s: String): String
		return SysTools.quoteUnixArg(s);
}

class DosCli extends CommandLineInterface {
	function new() {
		final separators: ReadOnlyArray<OptionSeparator> = [Equal, Colon];
		super(Dos, "Dos", "^", separators, separators);
	}

	override public inline function acceptsSwitchar(switchar: Switchar): Bool
		return switch switchar {
			case Hyphen: true;
			case DoubleHyphen: true;
			case Slash: true;
		};

	override public inline function acceptsOptionSeparator(
		separator: OptionSeparator
	): Bool
		return switch separator {
			case None: true;
			case Space: true;
			case Equal: true;
			case Colon: true;
		}

	override public inline function quoteArgument(s: String): String
		return SysTools.quoteWinArg(s, true);
}

enum abstract CliType(Int) {
	final Unix;
	final Dos;
}
