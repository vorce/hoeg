defmodule Hoeg.REPL do
  @moduledoc """
  Read Evaluate Print Loop for Hoeg.
  """

  @prompt "hoeg> "

  def read() do
    IO.write(@prompt)
    IO.read(:line)
  end

  def eval(input, %Hoeg.State{} = state) do
    Hoeg.eval(input, state)
  rescue
    e in [Hoeg.Error.Syntax, Hoeg.Error.Parse] ->
      IO.puts(IO.ANSI.format([:red, inspect(e)], true))
      state
  end

  def print(%Hoeg.State{} = result) do
    first = List.first(result.elements)

    top_of_stack =
      if first == nil,
        do: [],
        else: first

    IO.inspect(top_of_stack)
    result
  end

  def loop(%Hoeg.State{} = state) do
    repl(state)
  end

  def repl(%Hoeg.State{} = state) do
    read()
    |> eval(state)
    |> print()
    |> loop()
  end

  def start() do
    repl(Hoeg.State.new())
  end
end
