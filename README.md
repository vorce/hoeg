[![Build Status](https://travis-ci.org/vorce/hoeg.svg?branch=master)](https://travis-ci.org/vorce/hoeg)

# Hoeg

Hoeg is a concatenative style programming language implemented in Elixir.

## What? and why?

Concatenative Programming is a style/paradigm that uses function composition instead
of function application. ["Why Concatenative Programming Matters"](https://evincarofautumn.blogspot.de/2012/02/why-concatenative-programming-matters.html) is a good article that explains the topic quite well. ["The Joy of Concatenative Languages"](http://www.codecommit.com/blog/cat/the-joy-of-concatenative-languages-part-1) blog post series is also nice.

For me Hoeg is more of a fun learning experience.

## REPL

    iex -S mix
    Hoeg.REPL.start()

## Stuff you can do

For bigger programs, check the [examples dir](examples).

### IO

- `print`. Ex: `"hello world" print`

### Math

`+, -, *, /, %`. Ex:

    14 8 + 2 * 2 -

### Boolean logic

- `or`. Ex: `true false or`
- `and`. Ex: `true true and`
- `not`. Ex: `false not`
- `>, >=, <, <=, ==, !=`

### Definitions

Defines a new "function".

    hoeg> foo: 1 2 +;
    hoeg> foo
    hoeg> 3

### List operations

- `cons`. Ex: `1 0 [] cons cons` will create a list `[1 0]` being left on the stack.

## Ideas

Just putting down some things I'd like to explore.

- GenServers and Supervisors. How would this work? Maybe a good idea to first introduce something around Task.async.
- Nice enough error messages. Need line numbers (and position), and explanation.
- Pattern matching...?

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `hoeg` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hoeg, "~> 0.2.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/hoeg](https://hexdocs.pm/hoeg).
