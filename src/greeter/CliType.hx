package greeter;

/**
	CLI type that can be used for `switch` expressions.
**/
enum abstract CliType(Int) {
	/**
		@return The CLI instance which `this` corresponds to.
	**/
	public inline function getCli(): Cli {
		return switch (cast this: CliType) {
			case Unix: Clis.unix;
			case Dos: Clis.dos;
		}
	};

	final Unix;
	final Dos;
}
