package greeter;

import haxe.ds.ReadOnlyArray;

/**
	Rule for parsing an option.
**/
typedef OptionParseRule = {
	/**
		`CommandOption` to which this rule applies.
		Used as a key for searching in `OptionParseRules`.
	**/
	option: CommandOption,

	/**
		List of accepted separator characters for this option type.
		`Colon` is ignored if parsing an Unix command line.
	**/
	separators: ReadOnlyArray<OptionSeparator>
};
