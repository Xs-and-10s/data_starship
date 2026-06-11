-module(data_starship_usage).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/data_starship_usage.gleam").
-export([main/0]).

-file("src/data_starship_usage.gleam", 84).
-spec print_section(binary(), binary()) -> nil.
print_section(Name, Body) ->
    gleam_stdlib:println(<<<<"-- "/utf8, Name/binary>>/binary, " --"/utf8>>),
    gleam_stdlib:println(Body).

-file("src/data_starship_usage.gleam", 77).
-spec assert_equal(binary(), binary(), binary()) -> nil.
assert_equal(Name, Actual, Expected) ->
    case Actual =:= Expected of
        true ->
            nil;

        false ->
            erlang:error(#{gleam_error => panic,
                    message => Name,
                    file => <<?FILEPATH/utf8>>,
                    module => <<"data_starship_usage"/utf8>>,
                    function => <<"assert_equal"/utf8>>,
                    line => 80})
    end.

-file("src/data_starship_usage.gleam", 63).
-spec property_check(binary()) -> nil.
property_check(Json) ->
    Actual = begin
        _pipe = data_starship:patch_signals(Json),
        erlang:iolist_to_binary(_pipe)
    end,
    Expected = <<<<<<"event: datastar-patch-signals\n"/utf8,
                "data: signals "/utf8>>/binary,
            Json/binary>>/binary,
        "\n\n"/utf8>>,
    assert_equal(<<"property-check"/utf8>>, Actual, Expected).

-file("src/data_starship_usage.gleam", 16).
-spec main() -> nil.
main() ->
    Elements = begin
        _pipe = data_starship:patch_elements(
            <<"<section id=\"panel\">Hello from Gleam</section>"/utf8>>
        ),
        erlang:iolist_to_binary(_pipe)
    end,
    Signals = begin
        _pipe@1 = data_starship:patch_signals(
            <<"{\"message\":\"Hello from Gleam\",\"count\":7}"/utf8>>
        ),
        erlang:iolist_to_binary(_pipe@1)
    end,
    Script = begin
        _pipe@2 = data_starship:execute_script(
            <<"window.gleamReady = true;</script>"/utf8>>
        ),
        erlang:iolist_to_binary(_pipe@2)
    end,
    assert_equal(
        <<"patch-elements"/utf8>>,
        Elements,
        <<"event: datastar-patch-elements\n"/utf8,
            "data: elements <section id=\"panel\">Hello from Gleam</section>\n\n"/utf8>>
    ),
    assert_equal(
        <<"patch-signals"/utf8>>,
        Signals,
        <<"event: datastar-patch-signals\n"/utf8,
            "data: signals {\"message\":\"Hello from Gleam\",\"count\":7}\n\n"/utf8>>
    ),
    assert_equal(
        <<"execute-script"/utf8>>,
        Script,
        <<<<<<"event: datastar-patch-elements\n"/utf8,
                    "data: selector body\n"/utf8>>/binary,
                "data: mode append\n"/utf8>>/binary,
            "data: elements <script data-effect=\"el.remove()\">window.gleamReady = true;<\\/script></script>\n\n"/utf8>>
    ),
    property_check(<<"{\"value\":\"\"}"/utf8>>),
    property_check(<<"{\"value\":\"A\"}"/utf8>>),
    property_check(<<"{\"value\":\"A & B\"}"/utf8>>),
    property_check(<<"{\"value\":\"Line 1\\nLine 2\"}"/utf8>>),
    print_section(<<"patch-elements"/utf8>>, Elements),
    print_section(<<"patch-signals"/utf8>>, Signals),
    print_section(<<"execute-script"/utf8>>, Script),
    print_section(<<"property-checks"/utf8>>, <<"ok"/utf8>>).
