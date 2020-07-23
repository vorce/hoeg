defmodule Hoeg.ParseDefinition do
  @moduledoc """
  A "definition" is basically a function or macro.
  """

  import NimbleParsec

  @behaviour Hoeg.ParseCombinator

  @impl true
  def combinator(_opts \\ []) do
    [one_arg_definition_name(), no_args_definition_name()]
    |> choice()
    |> map({__MODULE__, :name_to_string, []})
    |> definition_body()
    |> tag(:definition)
  end

  # def name_to_string(wot), do: inspect(wot, label: "name to string")
  def name_to_string({:definition_name, name}), do: {:definition_name, to_string(name)}
  def name_to_string(other), do: other

  defp no_args_definition_name() do
    end_of_name_marker = string(":") |> ascii_char([?\s, ?\t, ?\n]) |> ignore()

    repeat(
      lookahead_not(end_of_name_marker)
      |> choice([
        ~S(\") |> string() |> replace(?"),
        utf8_char([])
      ])
    )
    |> ignore(end_of_name_marker)
    |> tag(:definition_name)
  end

  defp one_arg_definition_name() do
    end_of_name_marker = ascii_char([?\s, ?\t, ?\n]) |> ignore()

    repeat(
      lookahead_not(end_of_name_marker)
      |> choice([
        ~S(\") |> string() |> replace(?"),
        utf8_char([])
      ])
    )
    |> ignore(end_of_name_marker)
    |> tag(:definition_name)
    |> definition_args()
    |> ignore(string(":"))
  end

  defp definition_args(combinator) do
    combinator
    |> times(
      utf8_string([?a..?z], min: 1)
      |> optional(ignore(ascii_char([?\s])))
      |> unwrap_and_tag(:definition_arg),
      min: 1
    )
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
