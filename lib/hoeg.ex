defmodule Hoeg do
  @moduledoc """
  Documentation for Hoeg.
  """

  alias Hoeg.State
  alias Hoeg.Builtin
  alias Hoeg.Parse

  def eval(program, state \\ %State{}) when is_binary(program) do
    {env, instructions} = Parse.next(program, state.environment, [])

    Enum.reduce(instructions, %State{state | environment: env}, fn {fn_name, args}, state ->
      apply(Builtin, fn_name, [state, args])
    end)
  end

  def ast(input) do
    case Code.string_to_quoted(input) do
      {:ok, val} when is_number(val) or is_binary(val) ->
        {:value, [val]}

      {:ok, {fun, _, _}} ->
        {fun, []}

      _ ->
        raise("Not implemented for: #{input}")
    end
  end
end
