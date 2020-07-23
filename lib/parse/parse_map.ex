defmodule Hoeg.ParseMap do
  @moduledoc """
  Parse a map
  """
  import NimbleParsec

  alias Hoeg.ParseHelpers

  @behaviour Hoeg.ParseCombinator

  @map_start_marker string("%{")
  @map_end_marker ascii_char([?}])
  @map_divider string(" => ")

  @impl true
  def combinator(_opts \\ []) do
    [
      empty_map_value(),
      single_entry_map_value(),
      multi_entry_map_value()
    ]
    |> choice()
    |> reduce({Hoeg.ParseMap, :map_reducer, []})
  end

  def empty_map_value() do
    string("%{}")
  end

  def single_entry_map_value() do
    @map_start_marker
    |> ignore()
    |> map_key_value()
    |> ignore(@map_end_marker)
  end

  def multi_entry_map_value() do
    @map_start_marker
    |> ignore()
    |> map_key_value()
    |> repeat(
      lookahead_not(@map_end_marker)
      |> comma_map_entry()
    )
    |> ignore(@map_end_marker)
  end

  defp map_key_value(combinator) do
    combinator
    |> map_entry(:map_key)
    |> ignore(@map_divider)
    |> map_entry(:map_value)
  end

  def comma_map_entry(combinator \\ empty()) do
    combinator
    |> ignore(ascii_char([?,]))
    |> ParseHelpers.whitespace()
    |> map_key_value()
  end

  defp map_entry(combinator, entry_component) do
    combinator
    |> parsec(:value)
    |> tag(entry_component)
  end

  def map_reducer(["%{}"]) do
    %{}
  end

  def map_reducer(kvs) do
    {:map_value, [map_key: [value: [1, 2]], value: [%{3 => 4}]]}

    Enum.reduce(kvs, %{}, &reduce_more/2)
  end

  defp reduce_more({:map_value, [{:map_key, [{:value, [key]}]}, {:value, [val]}]}, acc) do
    Map.put(acc, key, val)
  end

  defp reduce_more({:map_value, [map_key: [value: key], value: [val]]}, acc) do
    Map.put(acc, key, val)
  end
end
