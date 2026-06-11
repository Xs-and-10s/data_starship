-module(space_cowboy_gleam_smoke).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/space_cowboy_gleam_smoke.gleam").
-export([main/0]).

-file("src/space_cowboy_gleam_smoke.gleam", 10).
-spec main() -> nil.
main() ->
    _pipe = data_starship:patch_signals(
        <<"{\"message\":\"Hello from Gleam\"}"/utf8>>
    ),
    _pipe@1 = erlang:iolist_to_binary(_pipe),
    gleam_stdlib:println(_pipe@1).
