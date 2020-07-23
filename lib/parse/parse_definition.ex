defmodule Hoeg.ParseDefinition do
  @moduledoc """
  A "definition" is basically a function or macro.
  """

  import NimbleParsec

  @behaviour Hoeg.ParseCombinator

  @impl true
  def combinator(_opts \\ []) do
    definition_name()
    |> tag(:definition_name)
    |> map({__MODULE__, :name_to_string, []})
    |> definition_body()
    |> tag(:definition)
  end

  def name_to_string({:definition_name, name}), do: {:definition_name, to_string(name)}

  defp definition_name() do
    end_of_name_marker = string(":") |> ascii_char([?\s, ?\t, ?\n]) |> ignore()

    repeat(
      lookahead_not(end_of_name_marker)
      |> choice([
        ~S(\") |> string() |> replace(?"),
        utf8_char([])
      ])
    )
    |> ignore(end_of_name_marker)
  end

  defp definition_body(combinator) do
    end_of_body_marker = ascii_char([?;])

    combinator
    |> repeat(
      lookahead_not(end_of_body_marker)
      |> parsec(:hoeg)
    )
    |> ignore(end_of_body_marker)
  end
end
