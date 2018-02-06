# Hoeg

Hoeg is a concatenative style programming language implemented in Elixir.

Here's hello world:

    "hello world" print

## REPL

    Hoeg.REPL.start()

## Built-in functions

### IO

- `print`

### Math

`+, -, *, /, %`

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
