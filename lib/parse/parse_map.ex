defmodule Hoeg.ParseMap do
  @moduledoc """
  Parse a map
  """
  import NimbleParsec

  alias Hoeg.ParseHelpers

  @map_start_marker string("%{")
  @map_end_marker ascii_char([?}])
  @map_divider string(" => ")

  def value() do
    valid_entries = map_entries()

    [
      empty_map_value(),
      single_entry_map_value(valid_entries),
      multi_entry_map_value(valid_entries)
    ]
    |> choice()
    |> reduce({Hoeg.ParseMap, :map_reducer, []})
  end

  def empty_map_value() do
    string("%{}")
  end

  def single_entry_map_value(valid_entries) do
    @map_start_marker
    |> ignore()
    |> map_key_value(valid_entries)
    |> ignore(@map_end_marker)
  end

  def multi_entry_map_value(valid_entries) do
    @map_start_marker
    |> ignore()
    |> map_key_value(valid_entries)
    |> repeat(
      lookahead_not(@map_end_marker)
      |> comma_map_entry(valid_entries)
    )
    |> ignore(@map_end_marker)
  end

  defp map_key_value(combinator \\ empty(), valid_entries) do
    combinator
    |> map_entry(valid_entries, :map_key)
    |> ignore(@map_divider)
    |> map_entry(valid_entries, :map_value)
  end

  def comma_map_entry(combinator \\ empty(), valid_entries) do
    combinator
    |> ignore(ascii_char([?,]))
    |> ParseHelpers.whitespace()
    |> map_key_value(valid_entries)
  end

  defp map_entries() do
    [ParseHelpers.number_value(), ParseHelpers.string_value(), ParseHelpers.boolean_value()]
  end

  defp map_entry(combinator \\ empty(), valid_entries, entry_component) do
    combinator
    |> choice(valid_entries)
    |> tag(entry_component)
  end

  def map_reducer(["%{}"]) do
    %{}
  end

  def map_reducer(kvs) do
    Enum.reduce(kvs, %{}, fn {:map_value, [{:map_key, [key]}, val]}, acc ->
      Map.put(acc, key, val)
    end)
  end
end
