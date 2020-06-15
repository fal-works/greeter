class Main {
	static function main() {
		Sys.println('Passed: ${Sys.args()}\n');

		#if eval
		final inputRules = OptionParseRules.from([
			"--cwd" => [Space],
			"--class-path" => [Space],
			"--library" => [Space],
			"-lib" => [Space],
			"--main" => [Space],
			"--dce" => [Space],
			"--macro" => [Space],
			"--debug" => [],
			"--interp" => []
		]);
		#else
		final inputRules = OptionParseRules.from(["--dummyOption" => [Space], "--dummyFlag" => []]);
		#end

		final cli = Cli.current;
		final args = cli.parsePassedArguments(inputRules);

		for (arg in args) Sys.println(arg.toString());

		Sys.println("\n[summary]");

		Sys.println(args.summary(["-lib" => "--library"]).toString());
	}
}
