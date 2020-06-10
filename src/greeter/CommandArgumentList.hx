package greeter;

private typedef Data = Array<CommandArgument>;

/**
	List of `CommandArgument` instances.
**/
@:forward
@:using(sinker.extensions.ArrayExtension)
@:using(sinker.extensions.ArrayFunctionalExtension)
abstract CommandArgumentList(Data) from Data to Data {}
