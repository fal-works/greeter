package greeter;

/**
	CLI type that can be used for `switch` expressions.
**/
enum abstract CommandLineInterfaceType(Int) {
	/**
		@return The CLI instance which `this` corresponds to.
	**/
	public inline function getCli(): CommandLineInterface {
		return switch (cast this: CommandLineInterfaceType) {
			case Unix: CommandLineInterfaceSet.unix;
			case Dos: CommandLineInterfaceSet.dos;
		}
	};

	final Unix;
	final Dos;
}
