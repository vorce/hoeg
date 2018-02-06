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
  end

  def print(%Hoeg.State{} = result) do
    IO.inspect(List.first(result.elements) || [])
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
