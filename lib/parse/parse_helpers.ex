defmodule Hoeg.ParseHelpers do
  @moduledoc """
  Nimble parsec definitions for parsing Hoeg programs
  """
  import NimbleParsec

  alias Hoeg.ParseDefinition
  alias Hoeg.ParseList
  alias Hoeg.ParseMap

  @behaviour Hoeg.ParseCombinator

  @impl true
  def combinator(_opts \\ []) do
    [
      whitespace(),
      value(),
      built_in_function(),
      operator(),
      ParseDefinition.combinator(),
      reference()
    ]
    |> choice()
    |> map({__MODULE__, :unwrap, []})
  end

  def whitespace(combinator \\ empty()) do
    combinator
    |> ignore(ascii_char([?\s, ?\t, ?\n]))
  end

  def value() do
    [
      number_value(),
      string_value(),
      boolean_value(),
      ParseList.combinator(),
      ParseMap.combinator()
    ]
    |> choice()
    |> tag(:value)
  end

  def unwrap({:value, [val]}), do: {:value, val}
  def unwrap(val), do: val

  def number_value() do
    integer(min: 1)
  end

  def string_value() do
    marker = [?"]

    marker
    |> ascii_char()
    |> ignore()
    |> utf8_string([{:not, hd(marker)}], min: 1)
    |> ignore(ascii_char(marker))
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

  @reference_range [?a..?z, ?A..?Z, ?0..?9, ?-, ?_]
  def reference() do
    whitespace()
    |> optional()
    |> utf8_string(@reference_range, min: 1)
    |> ignore(optional(whitespace()))
    |> unwrap_and_tag(:reference)
  end
end
