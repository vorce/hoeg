defmodule HoegTest do
  use ExUnit.Case
  doctest Hoeg

  import ExUnit.CaptureIO

  # describe "hello world" do
  #   program = """
  #   "Hello world!" IO.puts
  #   """
  #
  #   Hoeg.eval(program)
  # end

  describe "values" do
    test "puts integer value on the stack" do
      program = "1"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [1]}
    end

    test "puts string value on the stack" do
      program = "\"hello\""
      assert Hoeg.eval(program) == %Hoeg.State{elements: ["hello"]}
    end

    test "puts string with spaces on the stack" do
      program = "\"hello world\""
      assert Hoeg.eval(program) == %Hoeg.State{elements: ["hello world"]}
    end
  end

  describe "built in functions" do
    test "print" do
      program = "\"hello\" print"

      eval = fn ->
        Hoeg.eval(program)
      end

      assert eval.() == %Hoeg.State{elements: ["hello"]}
      assert capture_io(eval) == "hello\n"
    end

    test "+" do
      program = "1 2 +"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [3]}
    end

    test "-" do
      program = "256 156 -"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [100]}
    end

    test "*" do
      program = "10 66 *"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [660]}
    end

    test "/" do
      program = "21 3 /"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [7]}
    end
  end

  describe "next/2" do
    test "digit" do
      assert Hoeg.next("123", []) == [value: 123]
    end

    test "single word string" do
      assert Hoeg.next("\"hoeg\"", []) == [value: "hoeg"]
    end

    test "multi word string" do
      assert Hoeg.next("\"hoeg is great\"", []) == [value: "hoeg is great"]
    end

    test "multi word string and digits" do
      assert Hoeg.next("\"hoeg is great\" 42", []) == [value: "hoeg is great", value: 42]
    end

    test "built-in function" do
      assert Hoeg.next("\"hello world\" print", []) == [value: "hello world", print: []]
    end

    test "built-in functions inside string is not evaluated" do
      assert Hoeg.next("\"hello + world\"", []) == [value: "hello + world"]
    end
  end
end
