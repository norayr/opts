MODULE optsosv; (* v for vishap *)
(* os/compiler dependent argument functions to use in opts.Mod *)
(* voc version, uses Args module. should work with ofront as well *)

IMPORT Args, Strings;

TYPE
  string* = POINTER TO ARRAY OF CHAR;

VAR
  argscount-: INTEGER;
  cur:        INTEGER;

PROCEDURE Get*(): string;
VAR
  s0: ARRAY 64 OF CHAR;
  s: string;
BEGIN
  s := NIL;
  INC(cur);
  IF cur <= argscount THEN
    Args.Get(cur, s0);
    NEW(s, Strings.Length(s0)+1);
    COPY(s0, s^)
  END;
  RETURN s
END Get;

BEGIN
  argscount := Args.argc - 1;
  cur := 0;
END optsosv. (* v for vishap *)
