defmodule Hoeg do
  @moduledoc """
  Documentation for Hoeg.
  """

  alias Hoeg.State
  alias Hoeg.Builtin
  alias Hoeg.Parse

  def eval(program, state \\ %State{}) when is_binary(program) do
    {env, instructions} = Parse.next(program, state.environment, [])
    run(instructions, env, state)
  end

  def run(instructions, env, state) do
    Enum.reduce(instructions, %State{state | environment: env}, fn {fn_name, args}, state ->
      case fn_name do
        {:built_in, name} when is_atom(name) ->
          apply(Builtin, name, [state, args])

        name when is_atom(name) ->
          apply(Builtin, name, [state, args])
      end
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
