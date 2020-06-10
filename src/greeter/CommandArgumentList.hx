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
}
