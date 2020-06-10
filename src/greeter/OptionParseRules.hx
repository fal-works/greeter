package greeter;

import haxe.ds.ReadOnlyArray;

/**
	Table of rules for parsing an option string.
**/
class OptionParseRules {
	/**
		Creates an `OptionParseRules` instance.
		@param acceptedSeparatorsMap Mapping from each option to a list of accepted separators.
		If an option has no parameter, it should have an empty separator list.
		@param defaultAcceptedSeparators Separators accepted by any option not registered in `acceptedSeparatorsMap`.
		If not provided, `CommandLineInterface.current.defaultAcceptedSeparators` is used.
	**/
	public static function from(
		acceptedSeparatorsMap: Map<CommandOption, ReadOnlyArray<OptionSeparator>>,
		?defaultAcceptedSeparators: ReadOnlyArray<OptionSeparator>
	): OptionParseRules {
		final nonSeparatedParameterOptions: Array<CommandOption> = [];
		final optionRecords: Array<OptionParseRuleRecord> = [];

		for (option => acceptedSeparators in acceptedSeparatorsMap) {
			optionRecords.push({
				switchar: option.switchar,
				name: option.name,
				separators: acceptedSeparators
			});
			if (acceptedSeparators.indexOf(None) != -1)
				nonSeparatedParameterOptions.push(option);
		}

		final cli = CommandLineInterface.current;
		return new OptionParseRules(
			optionRecords.std(),
			nonSeparatedParameterOptions.std(),
			Nulls.coalesce(defaultAcceptedSeparators, cli.defaultAcceptedSeparators)
		);
	}

	final records: ReadOnlyArray<OptionParseRuleRecord>;
	final nonSeparatedParameterOptions: ReadOnlyArray<CommandOption>;
	final defaultAcceptedSeparators: ReadOnlyArray<OptionSeparator>;

	/**
		@return List of option names that accepts a parameter without a separator character
		(e.g. `-Dval` -> `{ name: "D", value: "val" }`).
	**/
	public function getNonSeparatedParameterOptions(
		switchar: Switchar
	): Array<CommandOption> {
		// TODO: refactor
		return this.nonSeparatedParameterOptions.filter(opt -> opt.switchar == switchar);
	}

	/**
		Checks if a given combination is accepted.
	**/
	public function acceptsSeparator(
		switchar: Switchar,
		optionName: String,
		separator: OptionSeparator
	): Bool {
		return this.getAcceptedSeparators(
			switchar,
			optionName
		).indexOf(separator) != -1;
	}

	/**
		Returns a list of accepted separators for a given option.
	**/
	function getAcceptedSeparators(
		switchar: Switchar,
		optionName: String
	): ReadOnlyArray<OptionSeparator> {
		var found = this.defaultAcceptedSeparators;
		for (rule in this.records) {
			if (rule.switchar == switchar && rule.name == optionName) {
				found = rule.separators;
				break;
			}
		}
		return found;
	}

	function new(
		records: ReadOnlyArray<OptionParseRuleRecord>,
		nonSeparatedParameterOptions: ReadOnlyArray<CommandOption>,
		defaultAcceptedSeparators: ReadOnlyArray<OptionSeparator>
	) {
		this.records = records;
		this.nonSeparatedParameterOptions = nonSeparatedParameterOptions;
		this.defaultAcceptedSeparators = defaultAcceptedSeparators;
	}
}

/**
	Data record that represents a rule for parsing a specific option.
	`switchar` and `name` are used as primary composite key for searching in `OptionParseRules`.
**/
private typedef OptionParseRuleRecord = {
	/**
		Switchar of option to which this rule applies.
	**/
	final switchar: Switchar;

	/**
		Name of option to which this rule applies.
	**/
	final name: String;

	/**
		List of accepted separator characters for this option.
		`Colon` is not used if parsing an Unix command line.
	**/
	final separators: ReadOnlyArray<OptionSeparator>;
};
