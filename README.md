# greeter

Parse/build command lines. Supports both Unix and DOS (maybe).

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
