MODULE testopts;
IMPORT opts, Out;

VAR options  : opts.Options;
    foptions : opts.Options;
         opt : opts.Option;

BEGIN

  options := opts.createOptions();
  foptions := opts.createOptions();
  opt     := opts.createOpt();
  opts.setOptName(opt, "-s");
  opts.setOptHasVal(opt, FALSE);
  opts.setOptRequired(opt, FALSE);
  opts.setOptLName(opt, "--symbol");
  opts.setOptDesc(opt, "update symbol file");

  options.add(options, opt);

  opt     := opts.createOpt();
  opts.setOptName(opt, "-m");
  opts.setOptHasVal(opt, TRUE);
  opts.setOptRequired(opt, TRUE);
  opts.setOptLName(opt, "--main");
  opts.setOptDesc(opt, "main module");

  options.add(options, opt);

  opt     := opts.createOpt();
  opts.setOptName(opt, "-F");
  opts.setOptHasVal(opt, TRUE);
  opts.setOptRequired(opt, TRUE);
  opts.setOptDesc(opt, "some fancy description");

  options.add(options, opt);
  Out.String ("possible options linked list lenght is "); Out.Int(options.count,3); Out.Ln;

  opts.showHelp(options);
  Out.String("----------------------"); Out.Ln;
  opts.listOptions(options);
  Out.String("----------------------"); Out.Ln;
  foptions := opts.populateOptions(options);
  Out.String("populated"); Out.Ln;
  opts.listOptions(foptions);

  IF opts.reqsSatisfied(options, foptions) THEN
    Out.String("required opts provided");
  ELSE
    Out.String("required opts not provided");
  END;
  Out.Ln;

  (*
  NEW (options, 3);

  options[0].name := "-s";
  options[0].haslongname := TRUE;
  options[0].longname := "--static";
  options[0].hasarg := FALSE;
  options[0].description := "aaa";

  options[1].name := "-m";
  options[1].haslongname := TRUE;
  options[1].longname := "--main";
  options[1].hasarg := TRUE;

  options[2].name := "-F";
  options[2].haslongname := FALSE;
  options[2].hasarg := TRUE;

  Out.String ("Array lenght is "); Out.Int(LEN(options^),3); Out.Ln;
  opts.ListOptions(options);

  Out.String("hm"); Out.Ln;

  opts.PopulateOptions(options, foptions);
  Out.String("hm"); Out.Ln;
  opts.ListOptions(options);
  opts.ListFoundOptions(options, foptions);
  *)
END testopts.
