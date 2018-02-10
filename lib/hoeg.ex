defmodule Hoeg do
  @moduledoc """
  Documentation for Hoeg.
  """

  alias Hoeg.State
  alias Hoeg.Builtin
  alias Hoeg.Error

  @whitespace ["\t", "\n", " "]
  @digits ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  @definition_re ~r/([a-z]+[a-zA-Z0-9]*):[\s\n]+/u
  @reference_re ~r/([a-z]+[\w]*)/u

  def eval(program, state \\ %State{}) when is_binary(program) do
    {env, instructions} = next(program, state.environment, [])

    Enum.reduce(instructions, %State{state | environment: env}, fn {fn_name, args}, state ->
      apply(Builtin, fn_name, [state, args])
    end)
  end

  def next(string, env, acc)

  def next(string, env, acc) when is_binary(string) do
    next(String.graphemes(string), env, acc)
  end

  def next([], env, acc), do: {env, Enum.reverse(acc)}

  def next(["p", "r", "i", "n", "t" | rest], env, acc) do
    next(rest, env, [{:print, []} | acc])
  end

  def next(["s", "t", "a", "t", "e" | rest], env, acc) do
    next(rest, env, [{:state, []} | acc])
  end

  def next(["f", "a", "l", "s", "e" | rest], env, acc) do
    next(rest, env, [{:value, false} | acc])
  end

  def next(["t", "r", "u", "e" | rest], env, acc) do
    next(rest, env, [{:value, true} | acc])
  end

  def next(["c", "o", "n", "s" | rest], env, acc) do
    next(rest, env, [{:cons, []} | acc])
  end

  def next(["+" | rest], env, acc) do
    next(rest, env, [{:add, []} | acc])
  end

  def next(["-" | rest], env, acc) do
    next(rest, env, [{:subtract, []} | acc])
  end

  def next(["*" | rest], env, acc) do
    next(rest, env, [{:multiply, []} | acc])
  end

  def next(["/" | rest], env, acc) do
    next(rest, env, [{:divide, []} | acc])
  end

  def next(["%" | rest], env, acc) do
    next(rest, env, [{:modulo, []} | acc])
  end

  def next(["a", "n", "d" | rest], env, acc) do
    next(rest, env, [{:boolean_and, []} | acc])
  end

  def next(["n", "o", "t" | rest], env, acc) do
    next(rest, env, [{:boolean_not, []} | acc])
  end

  def next(["o", "r" | rest], env, acc) do
    next(rest, env, [{:boolean_or, []} | acc])
  end

  def next([">", "=" | rest], env, acc) do
    next(rest, env, [{:greater_eq_to, []} | acc])
  end

  def next([">" | rest], env, acc) do
    next(rest, env, [{:greater_than, []} | acc])
  end

  def next(["<", "=" | rest], env, acc) do
    next(rest, env, [{:less_eq_to, []} | acc])
  end

  def next(["<" | rest], env, acc) do
    next(rest, env, [{:less_than, []} | acc])
  end

  def next(["=", "=" | rest], env, acc) do
    next(rest, env, [{:equals_to, []} | acc])
  end

  def next(["!", "=" | rest], env, acc) do
    next(rest, env, [{:not_equal, []} | acc])
  end

  def next(["\n" | rest], env, acc) do
    next(rest, env, acc)
  end

  def next([ch | rest] = all, env, acc) do
    # IO.inspect(ch, label: "Handling")

    cond do
      whitespace?(ch) ->
        next(rest, env, acc)

      digit?(ch) ->
        with {nr, new_rest} <- until_whitespace(rest, ""),
             {:ok, val} <- Code.string_to_quoted(ch <> nr) do
          next(new_rest, env, [{:value, val} | acc])
        end

      list_start?(ch) ->
        with {elements, new_rest} <- until_list_end(rest, ""),
             {:ok, val} <- Code.string_to_quoted(ch <> elements) do
          next(new_rest, env, [{:value, val} | acc])
        end

      quote?(ch) ->
        with {val, new_rest} <- until_quote(rest, ""),
             {:ok, val} <- Code.string_to_quoted(ch <> val) do
          next(new_rest, env, [{:value, val} | acc])
        end

      definition?(all) ->
        with input <- Enum.join(all),
             [{0, char_count}] <-
               Regex.run(@definition_re, input, capture: :all_but_first, return: :index),
             name <- String.slice(input, 0, char_count),
             {body, new_rest} <- until_semicolon(Enum.drop(all, char_count + 1), "") do
          next(new_rest, env, [{:definition, [name, body]} | acc])
        end

      reference?(all) ->
        with input <- Enum.join(all),
             [{0, char_count}] <-
               Regex.run(@reference_re, input, capture: :all_but_first, return: :index),
             name <- String.slice(input, 0, char_count) do
          next(Enum.drop(all, char_count), env, [{:reference, name} | acc])
        end

      true ->
        raise(Error.Parse, message: "Parse error for: #{all}")
    end
  end

  def reference?(all) do
    Regex.match?(@reference_re, Enum.join(all))
  end

  def definition?(all) do
    Regex.match?(@definition_re, Enum.join(all))
  end

  def digit?(d) when d in @digits, do: true
  def digit?(_), do: false

  def quote?("\""), do: true
  def quote?(_), do: false

  def until_quote([], acc), do: {acc, []}
  def until_quote(["\"" | rest], acc), do: {acc <> "\"", rest}
  def until_quote([char | rest], acc), do: until_quote(rest, acc <> char)

  def list_start?("["), do: true
  def list_start?(_), do: false

  def until_list_end([], acc), do: {acc, []}
  def until_list_end(["]" | rest], acc), do: {acc <> "]", rest}
  def until_list_end([char | rest], acc), do: until_list_end(rest, acc <> char)

  def whitespace?(d) when d in @whitespace, do: true
  def whitespace?(_), do: false

  def until_whitespace([], acc), do: {acc, []}
  def until_whitespace([char | rest], acc) when char in @whitespace, do: {acc, rest}
  def until_whitespace([char | rest], acc), do: until_whitespace(rest, acc <> char)

  def until_semicolon([], acc), do: {acc, []}
  def until_semicolon([";" | rest], acc), do: {acc, rest}
  def until_semicolon([char | rest], acc), do: until_semicolon(rest, acc <> char)

  def ast(input) do
    case Code.string_to_quoted(input) do
      {:ok, val} when is_number(val) or is_binary(val) ->
        {:value, [val]}

      {:ok, {fun, _, _}} ->
        {fun, []}

      _ ->
        raise("Not implemented for: #{input}")
    end
  end
end
