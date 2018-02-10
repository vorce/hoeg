defmodule Hoeg.ExampleTest do
  use ExUnit.Case

  @base_path "examples"

  test "simple_program.hoeg" do
    program = load("simple_program.hoeg")

    assert Hoeg.eval(program) == %Hoeg.State{
             elements: [304.5],
             environment: %{"dec" => "\n  1 -", "inc" => "\n  1 +"}
           }
  end

  def load(file) do
    File.read!(@base_path <> "/#{file}")
  end
end
