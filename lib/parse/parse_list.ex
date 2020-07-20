defmodule Hoeg.ParseList do
  @moduledoc """
  Parsing a list
  """
  import NimbleParsec

  alias Hoeg.ParseHelpers

  def value() do
    valid_elements = list_element_values()

    [
      empty_list_value(),
      single_element_list_value(valid_elements),
      multi_element_list_value(valid_elements)
    ]
    |> choice()
    |> map({Hoeg.ParseList, :to_list, []})
  end

  def to_list("[]"), do: []
  def to_list(val) when is_list(val), do: val
  def to_list(val), do: val

  @list_start_marker ascii_char([?[])
  @list_end_marker ascii_char([?]])

  defp list_element_values() do
    [ParseHelpers.number_value(), ParseHelpers.string_value(), ParseHelpers.boolean_value()]
  end

  def empty_list_value() do
    string("[]")
  end

  def single_element_list_value(valid_elements) do
    @list_start_marker
    |> ignore()
    |> choice(valid_elements)
    |> ignore(@list_end_marker)
  end

  def multi_element_list_value(valid_elements) do
    @list_start_marker
    |> ignore()
    |> choice(valid_elements)
    |> repeat(
      lookahead_not(@list_end_marker)
      |> comma_list_value(valid_elements)
    )
    |> ignore(@list_end_marker)
  end

  def comma_list_value(combinator \\ empty(), valid_elements) do
    combinator
    |> ignore(ascii_char([?,]))
    |> ParseHelpers.whitespace()
    |> choice(valid_elements)
  end
end
