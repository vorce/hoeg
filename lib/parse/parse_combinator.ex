defmodule Hoeg.ParseCombinator do
  @moduledoc """
  Behaviour for parse combinators
  """

  @callback combinator(opts :: Keyword.t()) :: NimbleParsec.combinator()
end
