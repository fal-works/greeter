package greeter;

private typedef Data = Array<CommandArgument>;

/**
	List of `CommandArgument` instances.
**/
@:forward
@:using(sinker.extensions.ArrayExtension)
@:using(sinker.extensions.ArrayFunctionalExtension)
abstract CommandArgumentList(Data) from Data to Data {
	/**
		Creates a summary from `this`.
		@param optionAliasMap Mapping from alias options to representative options.
	**/
	public function summary(
		?optionAliasMap: Map<CommandOption, CommandOption>
	): CommandArgumentSummary {
		return CommandArgumentSummary.from(this, optionAliasMap);
	}

	/**
		@return `this` as an array of `String` without quoting or escaping.
	**/
	public function toStringArray(): Array<String>
		return this.map(arg -> arg.toString());

	/**
		@return `this` as an array of `String` that can be used as command line arguments in `cli`.
	**/
	public function toQuotedStringArray(cli: Cli): Array<String>
		return this.map(arg -> arg.quote(cli));

	/**
		@return `this` in `String` representation.
	**/
	public function toString(): String
		return toStringArray().toString();
}
