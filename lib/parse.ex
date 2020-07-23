defmodule Hoeg.Parse do
  import NimbleParsec

  alias Hoeg.Error
  alias Hoeg.ParseDefinition
  alias Hoeg.ParseHelpers
  alias Hoeg.ParseList
  alias Hoeg.ParseMap

  def next(string, env, acc)

  def next("", env, acc), do: {env, Enum.reverse(acc)}

  def next(string, env, acc) when is_binary(string) do
    case hoeg(string) do
      {:ok, [value: val], rest, _context, _line, _column} ->
        next(rest, env, [{:value, val} | acc])

      {:ok, [definition: [{:definition_name, name} | body]], rest, _context, _line, _column} ->
        next(rest, env, [{:definition, [name, body]} | acc])

      {:ok, [reference: ref], rest, _context, _line, _column} ->
        next(rest, env, [{:reference, ref} | acc])

      {:ok, [{name, []} = op], rest, env, _line, _column} when is_atom(name) ->
        next(rest, env, [op | acc])

      {:ok, [], rest, _, _, _} ->
        next(rest, env, acc)

      {:ok, [{{:built_in, _name}, []} = bi], rest, _, _, _} ->
        next(rest, env, [bi | acc])

      {:error, message, _rest, _context, line, column} ->
        details = [message: message, line: line, column: column]
        raise(Error.Parse, message: "Parse error: #{inspect(details)}")
    end
  end

  def next([], env, acc), do: {env, Enum.reverse(acc)}

  defparsec(:hoeg, ParseHelpers.combinator())
  defparsec(:value, ParseHelpers.value())
  defparsec(:list_value, ParseList.combinator())
  defparsec(:map_value, ParseMap.combinator())
  defparsec(:definition, ParseDefinition.combinator())
  defparsec(:reference, ParseHelpers.reference())
end
