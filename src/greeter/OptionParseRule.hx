package greeter;

import haxe.ds.ReadOnlyArray;

/**
	Rule for parsing an option with a specific switchar and name.
	`switchar` and `name` are used as a composite primary key.
**/
typedef OptionParseRule = {
	switchar: Switchar,
	name: String,

	/**
		List of accepted separator characters for this option type.
		`Colon` is ignored if parsing an Unix command line.
	**/
	separators: ReadOnlyArray<OptionSeparator>
};
