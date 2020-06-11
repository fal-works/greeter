package greeter.implementation;

/**
	Set of `Cli` instances.
**/
class CliInstances {
	public static final unix = @:privateAccess new UnixCli();
	public static final dos = @:privateAccess new DosCli();

	/**
		The CLI system of the current environment in which this program is running.
	**/
	public static final current = switch Sys.systemName() {
			case "Windows": dos;
			default: unix;
		}
}
