defmodule Hoeg.ParseDefinition do
  @moduledoc false

  import NimbleParsec

  alias Hoeg.ParseHelpers

  def value() do
    definition_name()
    |> definition_body()
  end

  defp definition_name() do
    end_of_name_marker = string(":\n")

    repeat(
      lookahead_not(end_of_name_marker)
      |> choice([
        ~S(\") |> string() |> replace(?"),
        utf8_char([])
      ])
    )
    |> ignore(end_of_name_marker)
  end

  defp definition_body(combinator \\ empty()) do
    combinator
  end
end
