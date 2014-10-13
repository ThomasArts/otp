-module(cover_eqc).

-include_lib("eqc/include/eqc.hrl").
-compile(export_all).

-define(TEST_MODULE, myerlangprog).

prop_cover() ->
  eqc:numtests(10,
  ?FORALL(Code, eqc_erlang_program:module(?TEST_MODULE,[{maps,true},{macros,true}]),
  begin
    File = lists:concat([?TEST_MODULE, ".erl"]),
    file:write_file(File, Code),
    Res      = (catch cover:compile(File)),
    Expected = {ok, ?TEST_MODULE},
    ?WHENFAIL(eqc:format("~s\n", [Code]),
          equals(Res, Expected))
  end)).
