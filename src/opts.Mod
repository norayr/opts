MODULE opts;

IMPORT Out, Strings, optsos := optsosv;
TYPE
   string* = POINTER TO ARRAY OF CHAR;

   Option = POINTER TO OptionDesc;

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

      FoundOpt = POINTER TO FoundOptDesc;

 FoundOptDesc* = RECORD
         type* : LONGINT;
	value* : string;
         next* : FoundOpt;
	END;

    Options = POINTER TO OptionsDesc;
    OptionsDesc = RECORD
	   add* : PROCEDURE(VAR opts: Options; VAR opt: Option);
         first* : Option;
	  last* : Option;
	 count* : INTEGER;
	 END;

    FoundOptions = POINTER TO FoundOptionsDesc;
    FoundOptionsDesc = RECORD
         first* : Option;
	  last* : Option;
	 count* : INTEGER;
	 END;

PROCEDURE addOpt*(VAR opts: Options; VAR opt: Option);
BEGIN
  IF opts.first = NIL THEN
    opts.first := opt;
  ELSE
    opts.last.next := opt;
  END;
  opts.last := opt;
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
  NEW(opt.name, l);
  COPY(name, opt.name^);
  opt.hasval := hasval
END setOptName;

PROCEDURE setOptLName*(VAR opt:  Option; name: ARRAY OF CHAR);
VAR
  l: LONGINT;
BEGIN
  opt.haslongname := TRUE;
  l := Strings.Length(name);
  NEW(opt.longname, l);
  COPY(name, opt.longname^)
END setOptLName;
                           
PROCEDURE setOptDesc(VAR opt: Option; desc: ARRAY OF CHAR);
VAR
  l: LONGINT;
BEGIN
  l := Strings.Length(desc);
  NEW(opt.description, l);
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
   UNTIL opt = opts.last;
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
   UNTIL opt = opts.last;
END listOptions;

PROCEDURE listFoundOptions*(VAR opts : Options; VAR fopts : FoundOptions);
 VAR
   opt: Option;
BEGIN
   IF (opts # NIL) &  (fopts # NIL) THEN
       k := LEN(fopts^) - 1;
       l := 0;
       REPEAT
         Out.Int(l, 0); Out.String (" :"); Out.Ln;
	 Out.String (opts[fopts[l].type].name); Out.Ln;
	 IF opts[fopts[l].type].hasarg THEN
            Out.String("value: "); Out.String(fopts[l].value); Out.Ln;
	 END;
	 INC(l);
       UNTIL fopts[l].type < 0;
   END
END listFoundOptions;

PROCEDURE isSet* (s : string; VAR opts: TOptions; VAR fopts : TFoundOpts; VAR hasarg: BOOLEAN; VAR value : string): BOOLEAN;
VAR l, k : LONGINT;
BEGIN
   hasarg := FALSE;
   IF fopts # NIL THEN
      k := LEN(fopts^) -1;
      l := 0;
      REPEAT
	 IF opts[fopts[l].type].name = s THEN

            IF opts[fopts[l].type].hasarg THEN
	       hasarg := TRUE;
	       value := fopts[l].value;
               RETURN TRUE;
	    END;
	 END;
	 INC(l)
      UNTIL fopts[l].type < 0;
   END;
RETURN FALSE
END isSet;

PROCEDURE FindOption (VAR s : ARRAY OF CHAR; VAR opts : Options) : Option;
VAR 
  opt: Option;
BEGIN
   opt := opts.first;
   IF opts = NIL THEN HALT(1) END;
   k := LEN(opts^) -1 ;
   FOR i := 0 TO k DO
      IF opts^[i].name = s THEN
         RETURN i;
      ELSE
         IF opts^[i].haslongname THEN
            IF opts^[i].longname = s THEN
	       RETURN i
	    END;
	 END;
      END;
   END;
   RETURN -1;
END isOption;

PROCEDURE populateOptions*(VAR opts : Options; VAR fopts : FoundOptons);
VAR
  s : string;
BEGIN
   IF opts = NIL THEN HALT(1) END;
   optsos.Get(s);
   WHILE s # NIL DO
      l := IsOption(s, opts); (* check if s is expected option *)
      IF l >=0 THEN  (* if yes then *)
         fopts[k].type := l; (* record it *)
         IF opts[l].hasarg THEN (* check if after this option value expected *)
            IF i < argscount THEN
               INC(i);
               b := optsos.Get(s);
               fopts[k].value := s;
	    END;
	 END;
	 INC(k);
	 fopts[k].type := -1;
      END;
   END;
END populateOptions;

PROCEDURE addOption(opt: Option);

BEGIN

END addOption;

END opts.
