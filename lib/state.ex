defmodule Hoeg.State do
  @moduledoc """
  State is modelled as a stack.
  """

  defstruct elements: []

  def new, do: %__MODULE__{}

  def push(state, element) do
    %__MODULE__{state | elements: [element | state.elements]}
  end

  def pop(%__MODULE__{elements: []}), do: {:error, :empty}

  def pop(%__MODULE__{elements: [top | rest]}) do
    {:ok, {top, %__MODULE__{elements: rest}}}
  end

  def peek(%__MODULE__{elements: []}), do: {:error, :empty}

  def peek(%__MODULE__{elements: [top | _rest]}) do
    {:ok, top}
  end

  def depth(%__MODULE__{elements: elements}), do: length(elements)
end
