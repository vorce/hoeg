defmodule Hoeg.ParseHelpers do
  @moduledoc """
  Nimble parsec definitions for parsing Hoeg programs
  """
  import NimbleParsec

  # alias Hoeg.ParseDefinition
  alias Hoeg.ParseList
  alias Hoeg.ParseMap

  def hoeg() do
    [whitespace(), value(), built_in_function(), operator()]
    |> choice()
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
    choice([built_in(:print), built_in(:state)])
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
      op([?+], :add),
      op([?-], :subtract),
      op([?*], :multiply),
      op([?/], :divide),
      op([?%], :modulo)
    ])
  end

  defp op(char, name) when is_atom(name) do
    char
    |> ascii_char()
    |> ignore()
    |> tag(name)
  end
end
