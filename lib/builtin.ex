defmodule Hoeg.Builtin do
  def value(%Hoeg.State{} = state, val) do
    Hoeg.State.push(state, val)
  end

  def print(%Hoeg.State{} = state, _) do
    {:ok, val} = Hoeg.State.peek(state)
    IO.puts("#{val}")
    state
  end

  def add(%Hoeg.State{} = state, _) do
    case Hoeg.State.pop(state) do
      {:ok, {v1, s1}} ->
        case Hoeg.State.pop(s1) do
          {:ok, {v2, s2}} ->
            Hoeg.State.push(s2, v1 + v2)

          _ ->
            s1
        end

      _ ->
        state
    end

    #
    # {v1, state2} = Hoeg.State.pop(state)
    # {v2, state3} = Hoeg.State.pop(state2)
    # Hoeg.State.push(state3, v1 + v2)
  end

  def subtract(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)
    {:ok, {v2, state3}} = Hoeg.State.pop(state2)
    Hoeg.State.push(state3, v2 - v1)
  end

  def multiply(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)
    {:ok, {v2, state3}} = Hoeg.State.pop(state2)
    Hoeg.State.push(state3, v1 * v2)
  end

  def divide(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)
    {:ok, {v2, state3}} = Hoeg.State.pop(state2)
    Hoeg.State.push(state3, v2 / v1)
  end
end
