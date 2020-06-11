package greeter;

/**
	Set of `Cli` instances.
**/
class Clis {
	public static final unix = @:privateAccess new Cli.UnixCli();
	public static final dos = @:privateAccess new Cli.DosCli();

	/**
		The CLI system of the current environment in which this program is running.
	**/
	public static final current = switch Sys.systemName() {
		case "Windows": dos;
		default: unix;
	}
}
