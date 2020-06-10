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
		@param defaultOptionSeparators If not provided, `CommandLineInterface.current.defaultOptionSeparators` is used.
	**/
	public static function from(
		acceptedSeparatorsMap: Map<CommandOption, ReadOnlyArray<OptionSeparator>>,
		?defaultOptionSeparators: ReadOnlyArray<OptionSeparator>
	): OptionParseRules {
		final nonSeparatedParameterOptions: Array<CommandOption> = [];
		final ruleRecords: Array<OptionParseRule> = [];

		for (option => acceptedSeparators in acceptedSeparatorsMap) {
			ruleRecords.push({ option: option, separators: acceptedSeparators });
			if (acceptedSeparators.indexOf(None) != -1)
				nonSeparatedParameterOptions.push(option);
		}

		final cli = CommandLineInterface.current;
		return new OptionParseRules(
			ruleRecords.std(),
			nonSeparatedParameterOptions.std(),
			Nulls.coalesce(defaultOptionSeparators, cli.defaultOptionSeparators)
		);
	}

	final records: ReadOnlyArray<OptionParseRule>;
	final nonSeparatedParameterOptions: ReadOnlyArray<CommandOption>;
	final defaultOptionSeparators: ReadOnlyArray<OptionSeparator>;

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
		var found = this.defaultOptionSeparators;
		for (rule in this.records) {
			final option = rule.option;
			if (option.switchar == switchar && option.name == optionName) {
				found = rule.separators;
				break;
			}
		}
		return found;
	}

	function new(
		records: ReadOnlyArray<OptionParseRule>,
		nonSeparatedParameterOptions: ReadOnlyArray<CommandOption>,
		defaultOptionSeparators: ReadOnlyArray<OptionSeparator>
	) {
		this.records = records;
		this.nonSeparatedParameterOptions = nonSeparatedParameterOptions;
		this.defaultOptionSeparators = defaultOptionSeparators;
	}
}
