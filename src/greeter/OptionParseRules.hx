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
			switchar: switchar,
			name: optionName,
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
		rules = rules.copy();
		final ruleSet = new Map<String, Bool>();
		final nspOptionNamesMap = new Map<Switchar, Array<String>>();

		for (rule in rules) {
			final switchar = rule.switchar;
			final optionName = rule.name;
			final key = switchar + optionName;
			if (ruleSet.exists(key)) throw 'Duplicate option parsing rule: $key';
			ruleSet.set(key, true);

			if (rule.separators.indexOf(None) != -1) {
				final nspOptionNames = nspOptionNamesMap.get(switchar);
				if (nspOptionNames == null) {
					nspOptionNamesMap.set(switchar, [optionName]);
					continue;
				}
				nspOptionNames.push(optionName);
			}
		}

		final cli = CommandLineInterface.current;
		return new OptionParseRules(
			rules,
			nspOptionNamesMap,
			Nulls.coalesce(defaultOptionSeparators, cli.defaultOptionSeparators)
		);
	}

	final records: ReadOnlyArray<OptionParseRule>;
	final nonSeparatedParameterOptionNames: Map<Switchar, Array<String>>;
	final defaultOptionSeparators: ReadOnlyArray<OptionSeparator>;

	/**
		@return List of option names that accepts a parameter without a separator character
		(e.g. `-Dval` -> `{ name: "D", value: "val" }`).
	**/
	public function getNonSeparatedParameterOptionNames(
		switchar: Switchar
	): Array<String> {
		return Nulls.coalesce(
			this.nonSeparatedParameterOptionNames.get(switchar),
			emptyStringList
		);
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
			if (rule.switchar == switchar && rule.name == optionName) {
				found = rule.separators;
				break;
			}
		}
		return found;
	}

	function new(
		records: ReadOnlyArray<OptionParseRule>,
		nonSeparatedParameterOptionNames: Map<Switchar, Array<String>>,
		defaultOptionSeparators: ReadOnlyArray<OptionSeparator>
	) {
		this.records = records;
		this.nonSeparatedParameterOptionNames = nonSeparatedParameterOptionNames;
		this.defaultOptionSeparators = defaultOptionSeparators;
	}
}
