# greeter

Parse/build command lines. Both Unix and DOS (maybe).


## Usage

```haxe
import greeter.*;
```

```haxe
final inputRules = OptionParseRules.from([
	"--myOption" => [Space], // accepts a space-separated argument
	"--myFlag" => [] // no argument
]);

final cli = Cli.current; // Either Unix or DOS
final args = cli.parsePassedArguments(inputRules); // Parse args passed via Sys.args()

final summary = args.summary();
Sys.println(summary.toString());
```

If the arguments below is passed in the command line:

```
--myOption myOptionValue --myFlag myValue
```

Then the result is:

```
command values:
  myValue
options:
  --myOption myOptionValue
  --myFlag
```


## Caveats

Quite unstable!


## Current limitations

- Just single command lines. Does not support pipelines, redirection, stdin etc.
- No special handling of sub-command names. They are parsed in the same way as any other argument without switch character.
- Cannot parse/build multiple options unified (e.g. `-ab` instead of `-a -b`).
- Requires space before each option, while some systems do not always require (e.g. `DIR/Q/O`)
- Maybe more!


## Dependencies

- [sinker](https://github.com/fal-works/sinker) v0.3.0 or compatible

See also:
[FAL Haxe libraries](https://github.com/fal-works/fal-haxe-libraries)
