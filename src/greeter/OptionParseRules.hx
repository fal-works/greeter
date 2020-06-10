package greeter;

import haxe.ds.ReadOnlyArray;

/**
	Table of rules for parsing an option string.
**/
class OptionParseRules {
	/**
		Function for creating an `OptionParseRule` instance.
	**/
	public static final createRule = function(
			switchar: Switchar,
			optionName: String,
			acceptedSeparators: ReadOnlyArray<OptionSeparator>
	): OptionParseRule {
		return {
			option: { switchar: switchar, name: optionName },
			separators: acceptedSeparators
		};
	};

	static final emptyStringList: Array<String> = [];

	/**
		Creates a `OptionParseRules` instance.
		@param rules Should not have elements with duplicate keys (`switchar` and `name`).
		@param defaultOptionSeparators If not provided, `CommandLineInterface.current.defaultOptionSeparators` is used.
	**/
	public static function from(
		rules: ReadOnlyArray<OptionParseRule>,
		?defaultOptionSeparators: ReadOnlyArray<OptionSeparator>
	): OptionParseRules {
		final ruleSet = new Map<String, Bool>();
		final nonSeparatedParameterOptions: Array<CommandOption> = [];

		for (rule in rules) {
			final option = rule.option;
			final key = option.toString();
			if (ruleSet.exists(key)) throw 'Duplicate option parsing rule: $key';
			ruleSet.set(key, true);

			if (rule.separators.indexOf(None) != -1)
				nonSeparatedParameterOptions.push(option);
		}

		final cli = CommandLineInterface.current;
		return new OptionParseRules(
			rules,
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
