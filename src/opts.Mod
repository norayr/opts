MODULE opts;

IMPORT Out, Strings, optsos := optsosv;

TYPE
   string* = optsos.string;

   Option* = POINTER TO OptionDesc;
   Options* = POINTER TO OptionsDesc;

   OptionDesc* = RECORD;
         name- : string;
  haslongname- : BOOLEAN;
     longname- : string;
       hasval- : BOOLEAN;
     required- : BOOLEAN;
          val- : string;
  description- : string;
          next : Option;
       setName : PROCEDURE(VAR opt: Option; name: ARRAY OF CHAR);
   setLongName : PROCEDURE(VAR opt: Option; name: ARRAY OF CHAR);
       setDesc : PROCEDURE(VAR opt: Option; desc: ARRAY OF CHAR);
     setHasVal : PROCEDURE(VAR opt: Option; hasval: BOOLEAN);
   setRequired : PROCEDURE(VAR opt: Option; req: BOOLEAN);
        branch : Options;
      END;

    OptionsDesc* = RECORD
     add* : PROCEDURE(VAR opts: Options; VAR opt: Option);
         first- : Option;
    last- : Option;
   count- : INTEGER;
   END;

PROCEDURE addOpt*(VAR opts: Options; VAR opt: Option);
BEGIN
  IF opts.first = NIL THEN
    opts.first := opt;
  ELSE
    opts.last.next := opt;
  END;
  opts.last := opt;
  opt.next := NIL;
  INC(opts.count);
END addOpt;

PROCEDURE createOptions*(): Options;
VAR
  opts: Options;
BEGIN
  NEW(opts);
  opts.add   := addOpt;
  opts.first := NIL;
  opts.last  := NIL;
  opts.count := 0;
  RETURN opts
END createOptions;

PROCEDURE setOptHasVal*(VAR opt: Option; hasval: BOOLEAN);
BEGIN
  opt.hasval := hasval
END setOptHasVal;

PROCEDURE setOptRequired*(VAR opt: Option; req: BOOLEAN);
BEGIN
  opt.required := req
END setOptRequired;

PROCEDURE setOptBranch*(VAR opt: Option; branch: Options);
BEGIN
  opt.branch := branch
END setOptBranch;

PROCEDURE setOptName*(VAR opt: Option; name: ARRAY OF CHAR);
VAR
  l: LONGINT;
BEGIN
  l := Strings.Length(name);
  NEW(opt.name, l+1);
  COPY(name, opt.name^)
END setOptName;

PROCEDURE setOptLName*(VAR opt:  Option; name: ARRAY OF CHAR);
VAR
  l: LONGINT;
BEGIN
  opt.haslongname := TRUE;
  l := Strings.Length(name);
  NEW(opt.longname, l+1);
  COPY(name, opt.longname^)
END setOptLName;

PROCEDURE setOptDesc*(VAR opt: Option; desc: ARRAY OF CHAR);
VAR
  l: LONGINT;
BEGIN
  l := Strings.Length(desc);
  NEW(opt.description, l+1);
  COPY(desc, opt.description^);
END setOptDesc;

PROCEDURE createOpt*(): Option;
VAR
  o: Option;
BEGIN
  NEW(o);
  o.name := NIL;
  o.haslongname := FALSE;
  o.longname := NIL;
  o.hasval := FALSE;
  o.required := FALSE;
  o.val := NIL;
  o.description := NIL;
  o.next := NIL;
  o.branch := NIL;
  o.setName := setOptName;
  o.setLongName := setOptLName;
  o.setDesc := setOptDesc;
  RETURN o
END createOpt;

PROCEDURE showHelp*(VAR opts : Options);
VAR
  opt: Option;
BEGIN
   Out.String("options:"); Out.Ln; Out.Ln;
   opt := opts.first;

   IF opt = NIL THEN
     Out.String("No options available to show."); Out.Ln;
     RETURN;
   END;

   WHILE opt # NIL DO
      (* Debugging: print option status *)
      (*
      IF opt # NIL THEN
        Out.String("Processing option..."); Out.Ln;
      ELSE
        Out.String("Option is NIL."); Out.Ln;
      END;

      Out.String("    ");
      *)

      (* Check if the option name is NIL before printing *)
      IF opt.name # NIL THEN
        Out.String(opt.name^);
      ELSE
        Out.String("<no name>");
      END;

      IF opt.haslongname THEN
         Out.String(", ");
         IF opt.longname # NIL THEN
           Out.String(opt.longname^);
         ELSE
           Out.String("<no long name>");
         END;
      END;


      IF opt.hasval THEN
         Out.String (" = VALUE")
      END;

      Out.Ln;
      Out.String("               ");

      (* Check if the description is NIL before printing *)

      IF opt.description # NIL THEN
        Out.String(opt.description^);
      ELSE
        Out.String("<no description>");
      END;

      Out.Ln;

      (* Move to the next option *)
      opt := opt.next;
   END;
END showHelp;

PROCEDURE findOpt* (s : ARRAY OF CHAR; VAR opts : Options) : Option;
VAR
  opt: Option;
BEGIN
  IF opts = NIL THEN
    Out.String("Options list is NIL!"); Out.Ln;
    RETURN NIL;
  END;

  opt := opts.first;
  WHILE opt # NIL DO
    IF opt.name # NIL THEN
      IF opt.name^ = s THEN
        RETURN opt;
      END;
    END;

    IF opt.haslongname & (opt.longname # NIL) THEN
      IF opt.longname^ = s THEN
        RETURN opt;
      END;
    END;

    (* Move to the next option, but make sure opt isn't NIL *)
    opt := opt.next;
  END;

  RETURN NIL;
END findOpt;

PROCEDURE reqsSatisfied*(opts, fopts: Options): BOOLEAN;
VAR
  opt, opt2: Option;
BEGIN
  IF (fopts # NIL) & (opts # NIL) THEN
    opt := opts.first;
    REPEAT
      IF opt.required THEN
        opt2 := findOpt(opt.name^, fopts);
        IF opt2 = NIL THEN RETURN FALSE END;
      END;
      opt := opt.next
    UNTIL opt = NIL;
    RETURN TRUE
  END;
  RETURN FALSE
END reqsSatisfied;

PROCEDURE copyOpt(VAR opt: Option): Option;
VAR
  fopt: Option;
BEGIN
  fopt := createOpt();
  setOptName(fopt, opt.name^);
  setOptHasVal(fopt, opt.hasval);
  fopt.haslongname := opt.haslongname;
  IF opt.haslongname THEN setOptLName(fopt, opt.longname^) END;
  fopt.required := opt.required;
  IF opt.description # NIL THEN setOptDesc(fopt, opt.description^) END;
  RETURN fopt
END copyOpt;

PROCEDURE populateOptions*(VAR opts : Options): Options;
VAR
  s : string;
  opt, fopt: Option;
  fopts: Options;
BEGIN
   (*Out.String("Starting populateOptions..."); Out.Ln;*)

   fopts := createOptions();
   IF opts = NIL THEN
     Out.String("No options defined, exiting"); Out.Ln;
     HALT(1)
   END;

   s := optsos.Get();
   WHILE s # NIL DO
     (*Out.String("Current argument: "); Out.String(s^); Out.Ln;*)

     opt := findOpt(s^, opts); (* Check if s is an expected option *)
     IF opt # NIL THEN
       (*Out.String("Option found: "); Out.String(s^); Out.Ln;*)
       fopt := copyOpt(opt);
       fopts.add(fopts, fopt); (* Record the option *)

       IF opt.hasval THEN (* Check if the option requires a value *)
         (*Out.String("Option requires a value: "); Out.String(s^); Out.Ln;*)
         s := optsos.Get(); (* Get the next argument, which should be the value *)
         IF s # NIL THEN
           (*Out.String("Expecting value for option: "); Out.String(fopt.name^); Out.Ln;
           Out.String("Assigning value: "); Out.String(s^); Out.Ln;*)
           opt.val := s; (* Assign the value to the original option *)
           fopt.val := s; (* Assign the value to the copied option *)

           IF s^[0] = '-' THEN
             Out.String("Warning: Value starts with dash?"); Out.Ln;
           END;
         ELSE
           Out.String("Option '"); Out.String(opt.name^); Out.String("' should be followed by a value"); Out.Ln;
           HALT(5);
         END;
       END;
     ELSE
       (* Here is the key change: Instead of treating 'aaa.txt' as an option,
          assume it is the value for '-f' if '-f' is missing *)
       fopt := findOpt("-f", opts); (* Find the '-f' option *)
       IF (fopt # NIL) & (fopt.val = NIL) THEN
         (*Out.String("Assigning value '"); Out.String(s^); Out.String("' to '-f'"); Out.Ln;*)
         fopt.val := s; (* Set the value of '-f' *)
       ELSE
         Out.String("Undefined option: "); Out.String(s^); Out.Ln;
         showHelp(opts); (* Show help and exit if an unknown option is encountered *)
         HALT(6);
       END;
     END;

     s := optsos.Get(); (* Get the next argument *)
   END;

   RETURN fopts;
END populateOptions;

PROCEDURE valOfOpt*(o: ARRAY OF CHAR; VAR foptions: Options; VAR val: ARRAY OF CHAR);
VAR
  fopt: Option;
BEGIN
  COPY("", val);  (* Initialize val with an empty string *)
  (*Out.String("Looking for value of option: "); Out.String(o); Out.Ln;*)  (* Debugging: Show option name *)
  fopt := findOpt(o, foptions);  (* Find the option by its name *)

  IF fopt # NIL THEN
   (* Out.String("Option found: "); Out.String(fopt.name^); Out.Ln;*)  (* Debugging: Option found *)
    IF fopt.val # NIL THEN
      (*Out.String("Value found: "); Out.String(fopt.val^); Out.Ln;*)  (* Debugging: Value found *)
      COPY(fopt.val^, val);  (* Copy the value if it exists *)
    ELSE
      Out.String("No value provided for option: "); Out.String(o); Out.Ln;
    END;
  ELSE
    Out.String("Option '"); Out.String(o); Out.String("' not found in command-line arguments."); Out.Ln;
  END;
END valOfOpt;

PROCEDURE listOptions*(VAR opts : Options);
VAR
  opt: Option;
BEGIN
  IF opts # NIL THEN
    opt := opts.first;
    IF opt # NIL THEN
      REPEAT
        Out.String("name : ");
        Out.String(opt.name^); Out.Ln;
        IF opt.haslongname THEN
           Out.String("long name : "); Out.String(opt.longname^); Out.Ln;
        END;
        IF opt.hasval THEN
           Out.String ("expects value")
        ELSE
           Out.String ("does not expect value")
        END;
        Out.Ln;
        IF opt.required THEN
          Out.String ("required option");
        ELSE
          Out.String ("not required");
        END;
        Out.Ln;
        opt := opt.next
      UNTIL opt = NIL;
    ELSE
      Out.String("first argument received is NIL, exiting"); Out.Ln
    END
  ELSE
    Out.String("options received are empty, exiting");
    Out.Ln
  END
END listOptions;

END opts.

