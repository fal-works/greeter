# greeter

Parse/build command lines. Both Unix and DOS (maybe).


## Overview

- A single command line is represented by a `CommandLine` instance.
- Use `Cli` for parsing any string array (like `Sys.args()`) and converting them to `CommandLine`.
- There are two `Cli` instances: `Cli.unix` and `Cli.dos`. And `Cli.current` is one of these two, depending on your current system.
- For applying any user-defined rules when parsing, create an `OptionParseRules` instance and pass it to `Cli`.
- Any `CommandLine` can be formatted for either `Cli`, but throws error if it contains invalid syntax for the selected `Cli`.

## Caveats

- Not yet very well tested.
- Quite unstable!

### Current Limitations

- Just single command lines. Does not support pipelines, redirection, stdin etc.
- No special handling of sub-command names. They are parsed in the same way as any other argument without switch character.
- Cannot parse/build multiple options unified (e.g. `-ab` instead of `-a -b`).
- Requires space before each option, while some systems do not always require (e.g. `DIR/Q/O`)
- Maybe more!


## Usage Example

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

```console
--myOption myOptionValue --myFlag myValue
```

Then the result is:

```console
command values:
  myValue
options:
  --myOption myOptionValue
  --myFlag
```


## Dependencies

- [sinker](https://github.com/fal-works/sinker) v0.3.0 or compatible

See also:
[FAL Haxe libraries](https://github.com/fal-works/fal-haxe-libraries)
