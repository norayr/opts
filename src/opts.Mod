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
   Out.String ("options:"); Out.Ln; Out.Ln;
   opt := opts.first;
   REPEAT
      Out.String("    ");
      Out.String(opt.name^);
      IF opt.haslongname THEN
         Out.String(", "); Out.String(opt.longname^);
      END;
      IF opt.hasval THEN 
         Out.String (" = VALUE") 
      END; 
      Out.Ln;
      Out.String("               ");
      Out.String(opt.description^);
      Out.Ln;
      opt := opt.next
   UNTIL opt = NIL;
END showHelp;

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

PROCEDURE listFoundOptions*(VAR fopts : Options);
BEGIN
   IF fopts # NIL THEN
     listOptions(fopts)
   END
END listFoundOptions;

PROCEDURE findOpt* (s : ARRAY OF CHAR; VAR opts : Options) : Option;
VAR 
  opt: Option;
BEGIN
   opt := opts.first;
   REPEAT
      IF opt.name^ = s THEN
         RETURN opt;
      ELSE
         IF opt.haslongname THEN
            IF opt.longname^ = s THEN
	            RETURN opt
	          END;
	       END;
      END;
      opt := opt.next
   UNTIL opt = NIL;
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
   fopts := createOptions();
   IF opts = NIL THEN
     Out.String("no options defined, exiting"); Out.Ln;
     HALT(1)
   END;
   s := optsos.Get();
   IF s = NIL THEN
     (*Out.String("no options on command line"); Out.Ln;
     showHelp(opts);*)
     RETURN NIL
     (*HALT(4);*)
   ELSE
     REPEAT
        opt := findOpt(s^, opts); (* check if s is expected option *)
        IF opt # NIL THEN  (* if yes then *)
           fopt := copyOpt(opt);
           fopts.add(fopts, fopt); (* record it *)
           IF opt.hasval THEN (* check if after this option value expected *)
             s := optsos.Get();
	     IF s # NIL THEN
               opt.val := s;
               fopt.val := s;
	       IF s^[0] = '-' THEN
                 Out.String ("warning: value starts with dash?"); Out.Ln;
	       END
	     ELSE
	       Out.String("option '"); Out.String(opt.name^);
	       Out.String("' should follow by value"); Out.Ln;
	       HALT(5);
	     END;
  	   END;
        ELSE
          Out.String("undefined option "); Out.String(s^); Out.Ln;
          showHelp(opts);
	  HALT(6)
        END;
        IF s # NIL THEN
	  s := optsos.Get();
	END;
     UNTIL s = NIL;
   END;
   RETURN fopts
END populateOptions;

PROCEDURE valOfOpt*(o: ARRAY OF CHAR; VAR foptions: Options; VAR val: ARRAY OF CHAR);
VAR
  fopt: Option;
BEGIN
  COPY("", val);
  fopt := createOpt();
  fopt := findOpt(o, foptions);
  IF fopt # NIL THEN
    IF fopt.val # NIL THEN
      COPY(fopt.val^, val);
    ELSE
      Out.String("no value for "); Out.String(o); Out.Ln
    END
  ELSE
    Out.String("option "); Out.String(o); Out.String(" wasn't found on commandline"); Out.Ln
  END
END valOfOpt;

END opts.
