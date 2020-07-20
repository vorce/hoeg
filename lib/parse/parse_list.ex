defmodule Hoeg.ParseList do
  @moduledoc """
  Parsing a list
  """
  import NimbleParsec

  alias Hoeg.ParseHelpers

  def value() do
    [
      empty_list_value(),
      single_element_list_value(),
      multi_element_list_value()
    ]
    |> choice()
    |> map({Hoeg.ParseList, :to_list, []})
  end

  def to_list("[]"), do: []
  def to_list({:value, [val]}), do: val
  def to_list({:value, val}), do: val

  @list_start_marker ascii_char([?[])
  @list_end_marker ascii_char([?]])

  def empty_list_value() do
    string("[]")
  end

  def single_element_list_value() do
    @list_start_marker
    |> ignore()
    |> parsec(:value)
    |> ignore(@list_end_marker)
  end

  def multi_element_list_value() do
    @list_start_marker
    |> ignore()
    |> parsec(:value)
    |> repeat(
      lookahead_not(@list_end_marker)
      |> comma_list_value()
    )
    |> ignore(@list_end_marker)
  end

  def comma_list_value(combinator \\ empty()) do
    combinator
    |> ignore(ascii_char([?,]))
    |> ParseHelpers.whitespace()
    |> parsec(:value)
  end
end
