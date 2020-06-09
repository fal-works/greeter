class Main {
	static function main() {
		#if greeter_unix
		Sys.println("Current CLI: Unix\n");
		#elseif greeter_dos
		Sys.println("Current CLI: DOS\n");
		#end

		Sys.println('Passed: ${Sys.args()}\n');

		final rule = OptionParseRules.createRule;

		#if eval
		final inputRules = OptionParseRules.from([
			rule(DoubleHyphen, "cwd", [Space]),
			rule(DoubleHyphen, "class-path", [Space]),
			rule(DoubleHyphen, "library", [Space]),
			rule(DoubleHyphen, "main", [Space]),
			rule(DoubleHyphen, "dce", [Space]),
			rule(DoubleHyphen, "macro", [Space]),
			rule(DoubleHyphen, "debug", []),
			rule(DoubleHyphen, "interp", [])
		]);
		#else
		final inputRules = OptionParseRules.from([
			rule(DoubleHyphen, "dummyOption", [Space]),
			rule(DoubleHyphen, "dummyFlat", [])
		]);
		#end

		final cli = CommandLineInterface.current;
		final args = cli.parseArguments(inputRules);

		for (arg in args) Sys.println(arg.toString());
	}
}
