defmodule Hoeg.ParseHelpers do
  @moduledoc """
  Nimble parsec definitions for parsing Hoeg programs
  """
  import NimbleParsec

  alias Hoeg.ParseDefinition
  alias Hoeg.ParseList
  alias Hoeg.ParseMap

  def hoeg() do
    [whitespace(), value(), built_in_function(), operator(), ParseDefinition.value(), reference()]
    |> choice()
    |> map({__MODULE__, :unwrap, []})
  end

  def whitespace(combinator \\ empty()) do
    combinator
    |> ignore(ascii_char([?\s, ?\t, ?\n]))
  end

  def value() do
    [number_value(), string_value(), boolean_value(), ParseList.value(), ParseMap.value()]
    |> choice()
    |> tag(:value)
  end

  def unwrap({:value, [val]}), do: {:value, val}
  def unwrap(val), do: val

  def number_value() do
    integer(min: 1)
  end

  def string_value() do
    marker = ascii_char([?"])

    marker
    |> ignore()
    |> repeat(
      lookahead_not(marker)
      |> choice([
        ~S(\") |> string() |> replace(?"),
        utf8_char([])
      ])
    )
    |> reduce({List, :to_string, []})
    |> ignore(marker)
  end

  def boolean_value() do
    choice([string("true"), string("false")])
    |> map({Hoeg.ParseHelpers, :string_to_bool, []})
  end

  def string_to_bool("true"), do: true
  def string_to_bool("false"), do: false

  def built_in_function() do
    choice([built_in(:print), built_in(:state), built_in(:cons)])
  end

  defp built_in(name) when is_atom(name) do
    name
    |> Atom.to_string()
    |> string()
    |> ignore()
    |> tag({:built_in, name})
  end

  def operator() do
    choice([
      op(ascii_char([?+]), :add),
      op(ascii_char([?-]), :subtract),
      op(ascii_char([?*]), :multiply),
      op(ascii_char([?/]), :divide),
      op(ascii_char([?%]), :modulo),
      op(string("or"), :boolean_or),
      op(string("and"), :boolean_and),
      op(string("not"), :boolean_not),
      op(string("=="), :equals_to),
      op(string("!="), :not_equal),
      op(string("<="), :less_eq_to),
      op(ascii_char([?<]), :less_than),
      op(string(">="), :greater_eq_to),
      op(ascii_char([?>]), :greater_than)
    ])
  end

  defp op(combinator, name) when is_atom(name) do
    combinator
    |> ignore()
    |> tag(name)
  end

  def reference() do
    end_marker = choice([whitespace(), ascii_char([?;]), eos()])

    whitespace()
    |> optional()
    |> repeat(
      lookahead_not(end_marker)
      |> utf8_char([])
    )
    |> reduce({List, :to_string, []})
    |> ignore(optional(whitespace()))
    |> unwrap_and_tag(:reference)
  end
end
