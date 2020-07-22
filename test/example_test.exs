defmodule Hoeg.ExampleTest do
  use ExUnit.Case

  @base_path "examples"

  test "simple_program.hoeg" do
    program = load("simple_program.hoeg")

    assert Hoeg.eval(program) == %Hoeg.State{
             elements: [304.5],
             environment: %{
               "dec" => [value: 1, subtract: []],
               "inc" => [value: 1, add: []]
             }
           }
  end

  def load(file) do
    File.read!(@base_path <> "/#{file}")
  end
end
