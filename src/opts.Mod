MODULE opts;

IMPORT Out, Strings, optsos := optsosv;
TYPE
   string* = optsos.string;

   Option* = POINTER TO OptionDesc;

   OptionDesc* = RECORD;
         name- : string;
  haslongname- : BOOLEAN;
     longname- : string;
       hasval- : BOOLEAN;
          val- : string;
  description- : string;
          next : Option;
       setName : PROCEDURE(VAR opt: Option; name: ARRAY OF CHAR; hasval: BOOLEAN);
   setLongName : PROCEDURE(VAR opt: Option; name: ARRAY OF CHAR);
       setDesc : PROCEDURE(VAR opt: Option; desc: ARRAY OF CHAR);
      END;

    Options* = POINTER TO OptionsDesc;
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

PROCEDURE setOptName*(VAR opt: Option; name: ARRAY OF CHAR; hasval: BOOLEAN);
VAR
  l: LONGINT;
BEGIN
  l := Strings.Length(name);
  NEW(opt.name, l+1);
  COPY(name, opt.name^);
  opt.hasval := hasval
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
  o.val := NIL;
  o.description := NIL;
  o.next := NIL;
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
   opt := opts.first;
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
      opt := opt.next
   UNTIL opt = NIL;
END listOptions;

PROCEDURE listFoundOptions*(VAR fopts : Options);
BEGIN
   IF fopts # NIL THEN
     listOptions(fopts)
   END
END listFoundOptions;

PROCEDURE IsOption (VAR s : ARRAY OF CHAR; VAR opts : Options) : Option;
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
   UNTIL (opt = opts.last) OR (opt = NIL);
   RETURN NIL;
END IsOption;

PROCEDURE copyOpt(VAR opt: Option): Option;
VAR
  fopt: Option;
BEGIN
  fopt := createOpt();
  setOptName(fopt, opt.name^, opt.hasval);
  IF opt.haslongname THEN setOptLName(fopt, opt.longname^) END;
  IF opt.description # NIL THEN setOptDesc(fopt, opt.description^) END;
END copyOpt;

PROCEDURE populateOptions*(VAR opts : Options): Options;
VAR
  s : string;
  opt, fopt: Option;
  fopts: Options;
BEGIN
   fopts := createOptions();
   IF opts = NIL THEN HALT(1) END;
   s := optsos.Get();
   REPEAT
      opt := IsOption(s^, opts); (* check if s is expected option *)
      IF opt # NIL THEN  (* if yes then *)
         fopt := copyOpt(opt);
         fopts.add(fopts, fopt); (* record it *)
         IF opt.hasval THEN (* check if after this option value expected *)
           s := optsos.Get();
           opt.val := s;
	 END;
      END;
      s := optsos.Get()
   UNTIL s = NIL;
   RETURN fopts
END populateOptions;

END opts.
