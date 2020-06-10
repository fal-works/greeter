package greeter;

/**
	A single command line that can be run on the current OS.

	For example: `gcc input.c -o output.exe -lm`

	Here `gcc` is a command name, and `input.c`, `-o output.exe` and `-lm` are
	each a single `CommandArgument`.
**/
class CommandLine {
	/**
		Command name.
	**/
	public final name: String;

	/**
		List of command arguments.
	**/
	public final arguments: CommandArgumentList;

	public function new(name: String, arguments: CommandArgumentList) {
		this.name = name;
		this.arguments = arguments;
	}

	/**
		Runs `this` command.
		@param print If `true`, also prints the command line.
		@return The exit code.
	**/
	public function run(print: Bool = false): Int {
		final cmdString = this.toString();
		if (print) Sys.println(cmdString);
		return Sys.command(cmdString);
	}

	/**
		@return `this` as a one-line string without quoting or escaping.
	**/
	public function toString(): String
		return '${this.name} ${this.arguments.join(" ")}';

	/**
		@return `this` as a one-line string that can be used in `cli`.
	**/
	public function quote(cli: CommandLineInterface): String {
		final arguments = this.arguments.map(arg -> arg.quote(cli));
		return '${cli.quoteArgument(this.name)} ${arguments.join(" ")}';
	}

	/**
		@return `this` as a multi-line string that can be used in a script for `cli`.
	**/
	public function format(cli: CommandLineInterface): String {
		final name = this.name;
		final arguments = this.arguments;

		return switch arguments.length {
			case 0: name;
			case 1: '${name} ${arguments[0].quote(cli)}';
			default:
				final oneLiner = this.quote(cli);
				if (oneLiner.length <= 80) oneLiner else {
					final quotedArguments = arguments.map(arg -> arg.quote(cli));
					[name].concat(quotedArguments).join(' ${cli.lineDivider}\n');
				};
		}
	}
}
