defmodule Hoeg.State do
  @moduledoc """
  State is modelled as a stack.
  """

  defstruct elements: [], environment: %{}

  def new, do: %__MODULE__{}
  def new(env) when is_map(env), do: %__MODULE__{environment: env}

  def push(state, element) do
    %__MODULE__{state | elements: [element | state.elements]}
  end

  def pop(%__MODULE__{elements: []}), do: {:error, :empty}

  def pop(%__MODULE__{elements: [top | rest]} = state) do
    {:ok, {top, %__MODULE__{state | elements: rest}}}
  end

  def peek(%__MODULE__{elements: []}), do: {:error, :empty}

  def peek(%__MODULE__{elements: [top | _rest]}) do
    {:ok, top}
  end

  def depth(%__MODULE__{elements: elements}), do: length(elements)
end
