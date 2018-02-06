defmodule Hoeg do
  @moduledoc """
  Documentation for Hoeg.
  """

  alias Hoeg.State
  alias Hoeg.Builtin

  @whitespace ["\t", "\n", " "]
  @digits ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

  def eval(program) when is_binary(program) do
    program
    |> next([])
    |> Enum.reduce(State.new(), fn {fn_name, arg}, state ->
      apply(Builtin, fn_name, [state, arg])
    end)
  end

  def next(string, acc) when is_binary(string) do
    next(String.graphemes(string), acc)
  end

  def next([], acc), do: Enum.reverse(acc)

  def next(["p", "r", "i", "n", "t" | rest], acc) do
    next(rest, [{:print, []} | acc])
  end

  def next(["+" | rest], acc) do
    next(rest, [{:add, []} | acc])
  end

  def next(["-" | rest], acc) do
    next(rest, [{:subtract, []} | acc])
  end

  def next(["*" | rest], acc) do
    next(rest, [{:multiply, []} | acc])
  end

  def next(["/" | rest], acc) do
    next(rest, [{:divide, []} | acc])
  end

  def next([ch | rest] = all, acc) do
    # IO.inspect(ch, label: "Handling")

    cond do
      whitespace?(ch) ->
        next(rest, acc)

      digit?(ch) ->
        with {nr, new_rest} <- until_whitespace(rest, ""),
             {:ok, val} <- Code.string_to_quoted(ch <> nr) do
          next(new_rest, [{:value, val} | acc])
        end

      quote?(ch) ->
        with {val, new_rest} <- until_quote(rest, ""),
             {:ok, val} <- Code.string_to_quoted(ch <> val) do
          next(new_rest, [{:value, val} | acc])
        end

      true ->
        raise("Parse error for: #{all}")
    end
  end

  def digit?(d) when d in @digits, do: true
  def digit?(_), do: false

  def quote?("\""), do: true
  def quote?(_), do: false

  def until_quote([], acc), do: {acc, []}
  def until_quote(["\"" | rest], acc), do: {acc <> "\"", rest}
  def until_quote([char | rest], acc), do: until_quote(rest, acc <> char)

  def whitespace?(d) when d in @whitespace, do: true
  def whitespace?(_), do: false

  def until_whitespace([], acc), do: {acc, []}
  def until_whitespace([char | rest], acc) when char in @whitespace, do: {acc, rest}
  def until_whitespace([char | rest], acc), do: until_whitespace(rest, acc <> char)

  def ast(input) do
    case Code.string_to_quoted(input) do
      {:ok, val} when is_number(val) or is_binary(val) ->
        {:value, [val]}

      {:ok, {fun, _, _}} ->
        {fun, []}

      # apply(Hoeg.Builtin, fun, )

      _ ->
        raise("Not implemented for: #{input}")
    end
  end
end
