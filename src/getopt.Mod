MODULE getopt;

IMPORT Args, Console;
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
   Console.String ("options:"); Console.Ln; Console.Ln;

   FOR i := 0 TO LEN(opts^) -1 DO
      Console.String ("   ");
      Console.String(opts^[i].name);
      IF opts[i].hasarg THEN 
               Console.String (" <value>")
      END;
      IF opts[i].haslongname THEN
       Console.Ln;
       Console.String ("   ");
       Console.String(opts^[i].longname);
       IF opts[i].hasarg THEN
          Console.String (" <value>");
       END;
      END;
      Console.Ln;
      Console.String ("               ");
      Console.String (opts[i].description); Console.Ln; Console.Ln;
   END;
END ShowHelp;




PROCEDURE ListOptions*(VAR opts : TOptions);
VAR i : LONGINT;
BEGIN
   FOR i := 0 TO LEN(opts^) -1 DO
      Console.Int(i,1); Console.String (": "); Console.Ln;
      Console.String("name : "); Console.String(opts^[i].name); Console.Ln;
      IF opts[i].haslongname THEN
         Console.String("long name : "); Console.String(opts^[i].longname); Console.Ln;
      END;
      IF opts[i].hasarg THEN 
         Console.String ("expects value") 
      ELSE 
         Console.String ("does not expect value") 
      END; 
      Console.Ln;
   END;

END ListOptions;

PROCEDURE ListFoundOptions*(VAR opts : TOptions; VAR fopts : TFoundOpts);
 VAR l, k : LONGINT;
BEGIN
   IF (opts # NIL) &  (fopts # NIL) THEN
       k := LEN(fopts^) -1;
       l := 0;
       REPEAT
         Console.Int(l, 0); Console.String (" :"); Console.Ln;
	 Console.String (opts[fopts[l].type].name); Console.Ln;
	 IF opts[fopts[l].type].hasarg THEN
            Console.String("value: "); Console.String(fopts[l].value); Console.Ln;
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
   Console.String(s); Console.Ln;
   Args.Get(0, s);
   Console.String(s); Console.Ln;
   Args.Get(1, s);
   Console.String(s); Console.Ln;*)
   IF opts = NIL THEN HALT(1) END;
   argscount := Args.argc -1 ;
   Console.String ("args count "); Console.Int(argscount, 3); Console.Ln; 
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

Console.String ("Array lenght is "); Console.Int(LEN(options^),3); Console.Ln;
ListOptions(options);

Console.String("hm"); Console.Ln;
PopulateOptions(options, foptions);
Console.String("hm"); Console.Ln;
ListOptions(options);
ListFoundOptions(options, foptions);
*)
END getopt.