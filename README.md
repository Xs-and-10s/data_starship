# data_starship

Build Datastar SSE responses once, then use them from Erlang, Elixir, Gleam,
or any other BEAM language. `data_starship` is the tiny, server-neutral core:
it returns iodata, parses Datastar signals, and stays out of your web framework's
way.

## Table of Contents

- [Why Data Starship](#why-data-starship)
- [Install](#install)
- [First Event](#first-event)
- [Beginner Guide](#beginner-guide)
- [Common Tasks](#common-tasks)
- [Power User Notes](#power-user-notes)
- [API Map](#api-map)
- [Run the Examples](#run-the-examples)
- [Project Boundary](#project-boundary)

## Why Data Starship

Datastar lets the server update HTML, signals, and browser behavior over
Server-Sent Events. `data_starship` gives BEAM applications a portable way to
produce those events without choosing Cowboy, Phoenix, Mist, Elli, or any other
adapter for you.

- One Erlang module callable from Erlang, Elixir, Gleam, LFE, and friends.
- Runtime dependencies stay minimal: `kernel` and `stdlib`.
- All event builders return iodata, so callers can stream without flattening.
- Options work as maps or proplists, whichever is natural in your language.
- Template-engine-neutral: render HTML first, then pass it in.

## Install

Rebar3:

```erlang
{deps, [
    {data_starship, "0.1.0"}
]}.
```

Mix:

```elixir
def deps do
  [
    {:data_starship, "~> 0.1.0"}
  ]
end
```

Gleam:

```sh
gleam add data_starship
```

The current implementation uses OTP's built-in `json` module, so plan on an OTP
version that provides it.

## First Event

Erlang:

```erlang
Event = data_starship:patch_signals(#{<<"message">> => <<"Hello from Erlang">>}),
io:put_chars(iolist_to_binary(Event)).
```

Elixir:

```elixir
event =
  :data_starship.patch_signals(%{
    "message" => "Hello from Elixir"
  })

IO.puts(IO.iodata_to_binary(event))
```

Gleam:

```gleam
import gleam/dynamic.{type Dynamic}
import gleam/io

@external(erlang, "data_starship", "patch_signals")
fn patch_signals(signals: String) -> Dynamic

@external(erlang, "erlang", "iolist_to_binary")
fn iolist_to_binary(iodata: Dynamic) -> String

pub fn main() {
  patch_signals("{\"message\":\"Hello from Gleam\"}")
  |> iolist_to_binary
  |> io.println
}
```

All three produce a Datastar SSE event like:

```text
event: datastar-patch-signals
data: signals {"message":"Hello from BEAM"}
```

## Beginner Guide

Think of `data_starship` as a small encoder/decoder:

1. Your template engine, component, or function creates HTML, JSON, or a script.
2. `data_starship` wraps that value in a Datastar SSE event.
3. Your web adapter writes the returned iodata to the response stream.
4. Incoming Datastar signals can be decoded with `read_signals/3`.

The library does not open sockets, own request objects, or start a web server.
That is deliberate: beginners can learn one stable API, and power users can
drop it into whichever BEAM stack they already run.

## Common Tasks

Patch HTML into the page:

```erlang
data_starship:patch_elements(<<"<li>Dock</li>">>, #{
    selector => <<"#items">>,
    mode => append
}).
```

Patch signals:

```erlang
data_starship:patch_signals(#{<<"count">> => 42}).
```

Remove DOM elements:

```erlang
data_starship:remove_elements(<<"#toast">>).
```

Execute a script patch:

```erlang
data_starship:execute_script(<<"window.ready = true">>, #{
    attributes => #{<<"type">> => <<"module">>}
}).
```

Read signals from request data:

```erlang
data_starship:read_signals(
    get,
    <<"datastar=%7B%22count%22%3A41%7D">>,
    <<>>
).
```

Build frontend action expressions:

```erlang
data_starship:post(<<"/counter/increment">>).
```

## Power User Notes

- `event/2,3` is available when you need custom SSE event names.
- `retry_duration` and `retry` are aliases; both produce the SSE `retry` field.
- `use_view_transition` and `use_view_transitions` are aliases.
- HTML inputs may be iodata, binaries, strings, `{safe, Iodata}`, or
  `{ok, Iodata}`.
- `execute_script/2` escapes closing `</script>` sequences before wrapping the
  script in a Datastar patch.
- `remove_signals/1,2` turns dot paths like `<<"user.profile.theme">>` into a
  nested JSON null patch.
- Options may be Erlang maps or proplists, which keeps Elixir keyword lists and
  plain BEAM callers pleasant.

## API Map

Core SSE:

```erlang
sse_headers/0
event/2
event/3
```

DOM and signal patches:

```erlang
patch_elements/1,2
remove_elements/1,2
patch_signals/1,2
remove_signals/1,2
```

Script and navigation helpers:

```erlang
execute_script/1,2
redirect/1,2
console_log/1,2
```

Frontend action helpers:

```erlang
action/2,3
get/1,2
post/1,2
put/1,2
patch/1,2
delete/1,2
```

Signal parsing:

```erlang
read_signals/3
```

See [docs/data-starship-api.md](docs/data-starship-api.md) for the fuller API
notes and [docs/templating.md](docs/templating.md) for template examples.

## Run the Examples

From this repository:

```sh
rebar3 compile
elixir -pa _build/default/lib/data_starship/ebin examples/elixir_smoke.exs
```

Gleam:

```sh
cd examples/gleam_smoke
ERL_FLAGS='-pa ../../_build/default/lib/data_starship/ebin' gleam run
```

Everything together:

```sh
./test.sh
```

## Project Boundary

`data_starship` is the SDK core. It should not depend on Cowboy, Ranch, Plug,
Phoenix, Mist, Elli, or adapter-specific request types. Adapter packages can
own routing, streaming, and framework integration while passing rendered HTML,
signals, and scripts through this module.
