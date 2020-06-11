package greeter.implementation;

import haxe.SysTools;
import haxe.ds.ReadOnlyArray;

class DosCli extends Cli {
	function new() {
		final separators: ReadOnlyArray<OptionSeparator> = [Equal, Colon];
		super(Dos, "Dos", "^", separators, separators);
	}

	override public inline function acceptsSwitchar(switchar: Switchar): Bool
		return switch switchar {
			case Hyphen: true;
			case DoubleHyphen: true;
			case Slash: true;
		};

	override public inline function acceptsOptionSeparator(
		separator: OptionSeparator
	): Bool
		return switch separator {
			case None: true;
			case Space: true;
			case Equal: true;
			case Colon: true;
		}

	override public inline function quoteArgument(s: String): String
		return SysTools.quoteWinArg(s, true);
}
