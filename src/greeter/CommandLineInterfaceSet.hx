package greeter;

/**
	Set of `CommandLineInterface` instances.
**/
class CommandLineInterfaceSet {
	public static final unix = @:privateAccess new CommandLineInterface.UnixCli();
	public static final dos = @:privateAccess new CommandLineInterface.DosCli();

	/**
		The CLI system of the current environment in which this program is running.
	**/
	public static final current = switch Sys.systemName() {
		case "Windows": dos;
		default: unix;
	}
}
