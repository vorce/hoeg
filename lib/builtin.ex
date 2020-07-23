defmodule Hoeg.Builtin do
  alias Hoeg.Error

  def value(%Hoeg.State{} = state, val) do
    Hoeg.State.push(state, val)
  end

  def definition(%Hoeg.State{environment: env} = state, [name, body]) do
    %Hoeg.State{state | environment: Map.put(env, name, body)}
  end

  # How should function/definition arguments work? :D
  #
  # Examples:
  # myfn 1: "foo";
  # Running myfn with anything besides a 1 on top of the stack will raise a match error.
  # If a 1 is on the top of the stack "foo" will be placed on top of the stack.
  #
  # myfn 0: 1;
  # myfn n: n;
  #
  # Implementation:
  # One idea is to change how definitions are handled. Instead of having "defintion_name" => definition_body
  # in the env. We instead put "definition_name" => %{state: %Hoeg.State{}, body: definition_body}
  # That would enable definition_arg to manipulate the env of the state of the definition instead of the global
  # namespace.
  # We would also need to change how definition name+args are parsed, because we need the name of the definition
  # together with the argument name. Maybe something like: `{:definition_sig, [name, arg1, arg2]}`
  # def definition_arg(%Hoeg.State{environment: env} = state, arg) do
  #   %Hoeg.State{state | environment: Map.put(env, arg, body)}
  # end

  def reference(%Hoeg.State{environment: env} = state, name) do
    unless Map.has_key?(env, name), do: raise("Undefined reference: #{name}")
    body = Map.get(env, name)
    new_state = Hoeg.run(body, env, state)

    %Hoeg.State{
      state
      | elements: new_state.elements,
        environment: new_state.environment
    }
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

  def modulo(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)
    {:ok, {v2, state3}} = Hoeg.State.pop(state2)
    Hoeg.State.push(state3, rem(v2, v1))
  end

  def state(%Hoeg.State{} = state, _) do
    IO.inspect(state.elements)
    state
  end

  def exec(%Hoeg.State{} = state, _) do
    {:ok, {_quotation, _state2}} = Hoeg.State.pop(state)
  end

  def greater_than(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)
    {:ok, {v2, state3}} = Hoeg.State.pop(state2)
    Hoeg.State.push(state3, v2 > v1)
  end

  def greater_eq_to(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)
    {:ok, {v2, state3}} = Hoeg.State.pop(state2)
    Hoeg.State.push(state3, v2 >= v1)
  end

  def less_than(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)
    {:ok, {v2, state3}} = Hoeg.State.pop(state2)
    Hoeg.State.push(state3, v2 < v1)
  end

  def less_eq_to(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)
    {:ok, {v2, state3}} = Hoeg.State.pop(state2)
    Hoeg.State.push(state3, v2 <= v1)
  end

  def equals_to(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)
    {:ok, {v2, state3}} = Hoeg.State.pop(state2)
    Hoeg.State.push(state3, v2 == v1)
  end

  def not_equal(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)
    {:ok, {v2, state3}} = Hoeg.State.pop(state2)
    Hoeg.State.push(state3, v2 != v1)
  end

  def boolean_or(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)
    {:ok, {v2, state3}} = Hoeg.State.pop(state2)
    Hoeg.State.push(state3, v2 || v1)
  end

  def boolean_and(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)
    {:ok, {v2, state3}} = Hoeg.State.pop(state2)
    Hoeg.State.push(state3, v2 && v1)
  end

  def boolean_not(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)
    Hoeg.State.push(state2, !v1)
  end

  def cons(%Hoeg.State{} = state, _) do
    {:ok, {v1, state2}} = Hoeg.State.pop(state)

    case v1 do
      val when is_list(val) ->
        {:ok, {v2, state3}} = Hoeg.State.pop(state2)
        Hoeg.State.push(state3, [v2 | v1])

      other ->
        raise(
          Error.Syntax,
          message: "The top item on the stack needs to be a list for cons. Got #{other}"
        )
    end
  end
end
