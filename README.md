[![Build Status](https://travis-ci.org/vorce/hoeg.svg?branch=master)](https://travis-ci.org/vorce/hoeg)

# Hoeg

Hoeg is a concatenative style programming language implemented in Elixir.

## Whyyyy

:)

## REPL

    iex -S mix
    Hoeg.REPL.start()

## Stuff you can do

### IO

- `print`. Ex: `"hello world" print`

### Math

`+, -, *, /, %`. Ex:

    14 8 + 2 * 2 -

### Boolean logic

- `or`. Ex: `true false or`
- `and`. Ex: `true true and`

### Definitions

Defines a new "function".

    hoeg> foo: 1 2 +;
    hoeg> foo
    hoeg> 3

## Ideas

Just putting down some things I'd like to explore.

- GenServers and Supervisors. How would this work? Maybe a good idea to first introduce something around Task.async.
- Nice enough error messages. Need line numbers (and position), and explanation.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `hoeg` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hoeg, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/hoeg](https://hexdocs.pm/hoeg).
