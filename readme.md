# 🧰 opts — Command-Line Option Parser for Oberon

**opts** is a lightweight, modular command-line parser written in [Oberon](https://en.wikipedia.org/wiki/Oberon_(programming_language)) using the [Vishap Oberon Compiler (VOC)](https://github.com/vishapoberon/compiler). It provides a flexible system for defining and parsing options, flags, and positional arguments in command-line Oberon programs.

## 📦 Features

- Define short (`-m`) and long (`--main`) option names
- Support for options with or without values
- Required/optional option support
- Full positional argument handling
- Simple interface: define options → parse → use
- Modular structure: `opts` (core), `optsos` (OS argument source)
- Includes test/demo program (`testopts`)

## 📁 File Structure

- `opts.Mod` — Core implementation of the options parser
- `optsos.Mod` — OS-dependent integration layer (gets command-line args)
- `testopts.Mod` — Test suite and usage example

## 🚀 Example Usage

```oberon
MODULE testopts;
IMPORT opts, Out;

VAR options, parsed: opts.Options;
    opt: opts.Option;
    i: INTEGER;

BEGIN
  options := opts.createOptions();

  opt := opts.createOpt();
  opts.setOptName(opt, "-m");
  opts.setOptLName(opt, "--main");
  opts.setOptHasVal(opt, TRUE);
  opts.setOptRequired(opt, TRUE);
  opts.setOptDesc(opt, "Main module name");
  options.add(options, opt);

  opt := opts.createOpt();
  opts.setOptName(opt, "-s");
  opts.setOptLName(opt, "--symbol");
  opts.setOptHasVal(opt, FALSE);
  opts.setOptRequired(opt, FALSE);
  opts.setOptDesc(opt, "Update symbol file");
  options.add(options, opt);

  parsed := opts.populateOptions(options);

  IF opts.reqsSatisfied(options, parsed) THEN
    Out.String("All required options provided"); Out.Ln;
  ELSE
    Out.String("Missing required options!"); Out.Ln;
  END;

  i := 0;
  WHILE i < opts.NumPositionalArgs(parsed) DO
    Out.String("Positional arg "); Out.Int(i, 0); Out.String(": ");
    Out.String(opts.GetPositionalArg(parsed, i)^); Out.Ln;
    INC(i);
  END;

  opts.CleanupOptions(options);
  opts.CleanupOptions(parsed);
END testopts.
```

## 🛠 Build Instructions

To compile and run with VOC:

```sh
make
```

To build the test:

```
make tests
```

## 🧪 Output Samples

```
 $ build/testopts -s -m aaa

Defined options:
Options (3):
  -s / --symbol
  -m / --main [value] (required)
  -F [value] (required)

----------------------

Parsed options:
Options (2):
  -s / --symbol
  -m / --main [value] (required)

----------------------
Missing required options!

Test completed
```

Now requirements are satisfied:

```
 $ build/testopts -m a -F o

Defined options:
Options (3):
  -s / --symbol
  -m / --main [value] (required)
  -F [value] (required)

----------------------

Parsed options:
Options (2):
  -m / --main [value] (required)
  -F [value] (required)

----------------------
All required options provided

Test completed
```

## 📜 License

GPL-3.0 with linking exception.
