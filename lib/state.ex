defmodule Hoeg.State do
  @moduledoc """
  State is modelled as a stack.
  """
  defstruct elements: [], environment: %{}

  @type t :: %__MODULE__{
          elements: list(),
          environment: Map.t()
        }

  @doc """
  Create a new hoeg state
  """
  @spec new() :: __MODULE__.t()
  def new, do: %__MODULE__{}

  @doc """
  Create a new hoeg state
  """
  @spec new(env :: Map.t()) :: __MODULE__.t()
  def new(env) when is_map(env), do: %__MODULE__{environment: env}

  @doc """
  Push an element on to the top of the stack
  """
  @spec push(state :: __MODULE__.t(), element :: any) :: __MODULE__.t()
  def push(state, element) do
    %__MODULE__{state | elements: [element | state.elements]}
  end

  @doc """
  Take off the top item from the stack and return it
  """
  @spec pop(__MODULE__.t()) :: {:ok, {any, __MODULE__.t()}} | {:error, any}
  def pop(%__MODULE__{elements: []}), do: {:error, :empty}

  def pop(%__MODULE__{elements: [top | rest]} = state) do
    {:ok, {top, %__MODULE__{state | elements: rest}}}
  end

  @doc """
  Return the top item on the stack
  """
  @spec peek(state :: __MODULE__.t()) :: {:ok, any} | {:error, any}
  def peek(%__MODULE__{elements: []}), do: {:error, :empty}

  def peek(%__MODULE__{elements: [top | _rest]}) do
    {:ok, top}
  end

  @doc """
  Return how deep the stack is (how many elements are in it)
  """
  @spec depth(state :: __MODULE__.t()) :: integer
  def depth(%__MODULE__{elements: elements}), do: length(elements)
end
