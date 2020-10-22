MODULE getopt;

IMPORT Args, Out;
CONST StrLen* = 123;

TYPE
   string* = ARRAY StrLen OF CHAR;

   TOption* = RECORD;
        name* : string;
      haslongname* : BOOLEAN;
     longname*: string;
      hasarg* : BOOLEAN;
      argvalue*  : string;
      description* : string;
      END;


     TFoundOpt* = RECORD
        type* : LONGINT;
	value* : string;
	END;

     TOptions* = POINTER TO ARRAY OF TOption;
     TFoundOpts* = POINTER TO ARRAY OF TFoundOpt;

(* for test *)
VAR options : TOptions;
    foptions : TFoundOpts;

PROCEDURE ShowHelp*(VAR opts : TOptions);
VAR i : LONGINT;
BEGIN
   Out.String ("options:"); Out.Ln; Out.Ln;

   FOR i := 0 TO LEN(opts^) -1 DO
      Out.String ("   ");
      Out.String(opts^[i].name);
      IF opts[i].hasarg THEN 
               Out.String (" <value>")
      END;
      IF opts[i].haslongname THEN
       Out.Ln;
       Out.String ("   ");
       Out.String(opts^[i].longname);
       IF opts[i].hasarg THEN
          Out.String (" <value>");
       END;
      END;
      Out.Ln;
      Out.String ("               ");
      Out.String (opts[i].description); Out.Ln; Out.Ln;
   END;
END ShowHelp;




PROCEDURE ListOptions*(VAR opts : TOptions);
VAR i : LONGINT;
BEGIN
   FOR i := 0 TO LEN(opts^) -1 DO
      Out.Int(i,1); Out.String (": "); Out.Ln;
      Out.String("name : "); Out.String(opts^[i].name); Out.Ln;
      IF opts[i].haslongname THEN
         Out.String("long name : "); Out.String(opts^[i].longname); Out.Ln;
      END;
      IF opts[i].hasarg THEN 
         Out.String ("expects value") 
      ELSE 
         Out.String ("does not expect value") 
      END; 
      Out.Ln;
   END;

END ListOptions;

PROCEDURE ListFoundOptions*(VAR opts : TOptions; VAR fopts : TFoundOpts);
 VAR l, k : LONGINT;
BEGIN
   IF (opts # NIL) &  (fopts # NIL) THEN
       k := LEN(fopts^) -1;
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
END ListFoundOptions;

PROCEDURE IsSet* (s : string; VAR opts: TOptions; VAR fopts : TFoundOpts; VAR hasarg: BOOLEAN; VAR value : string): BOOLEAN;
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
END IsSet;

PROCEDURE IsOption (VAR s : ARRAY OF CHAR; VAR opts : TOptions) : LONGINT;
VAR i, k : LONGINT;
BEGIN
   IF opts = NIL THEN RETURN -2 END;
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
END IsOption;


PROCEDURE PopulateOptions*(VAR opts : TOptions; VAR fopts : TFoundOpts);
VAR s : string;
   i, k  : INTEGER;
   l, argscount : LONGINT;
BEGIN
   (*Args.Get(0, s);
   Out.String(s); Out.Ln;
   Args.Get(0, s);
   Out.String(s); Out.Ln;
   Args.Get(1, s);
   Out.String(s); Out.Ln;*)
   IF opts = NIL THEN HALT(1) END;
   argscount := Args.argc -1 ;
   Out.String ("args count "); Out.Int(argscount, 3); Out.Ln; 
   IF argscount > 0 THEN
      NEW (fopts, argscount);
      k := 0; (* index of destination array for found options *)
      i := 0; (* current argument number *)
      REPEAT
         INC(i);
         Args.Get(i, s);
         l := IsOption(s, opts); (* check if s is expected option *)
         IF l >=0 THEN  (* if yes then *)
            fopts[k].type := l; (* record it *)
	    IF opts[l].hasarg THEN (* check if after this option value expected  *)
               IF i < argscount THEN
                  INC(i);
	          Args.Get(i, s);
	          fopts[k].value := s;
	       END;
	    END;
	    INC(k);
	    fopts[k].type := -1;
         END;
      UNTIL i = argscount;
   END
END PopulateOptions;

BEGIN
(*
NEW (options, 3);

options[0].name := "-s";
options[0].haslongname := TRUE;
options[0].longname := "--static";
options[0].hasarg := FALSE;

options[1].name := "-m";
options[1].haslongname := TRUE;
options[1].longname := "--main";
options[1].hasarg := TRUE;

options[2].name := "-F";
options[2].haslongname := FALSE;
options[2].hasarg := TRUE;

Out.String ("Array lenght is "); Out.Int(LEN(options^),3); Out.Ln;
ListOptions(options);

Out.String("hm"); Out.Ln;
PopulateOptions(options, foptions);
Out.String("hm"); Out.Ln;
ListOptions(options);
ListFoundOptions(options, foptions);
*)
END getopt.
