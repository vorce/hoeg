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

    test "puts boolean on the stack" do
      program = "true false"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [false, true]}
    end
  end

  describe "IO" do
    test "print" do
      program = "\"hello world\" print"

      eval = fn ->
        Hoeg.eval(program)
      end

      assert eval.() == %Hoeg.State{elements: ["hello world"]}
      assert capture_io(eval) == "hello world\n"
    end

    test "state" do
      program = "1 2 3 \"hello world\" 4 \"five\" state"

      eval = fn ->
        Hoeg.eval(program)
      end

      assert capture_io(eval) == "[\"five\", 4, \"hello world\", 3, 2, 1]\n"
    end
  end

  describe "math" do
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

    test "%" do
      program = "12 4 %"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [0]}
    end
  end

  describe "definitions" do
    test "adds to the environment" do
      definition_name = "myname"

      body = """
        849 6716 +
        "my name is Hoeg" print
      """

      program = "#{definition_name}:\n#{body};"

      assert Hoeg.eval(program) == %Hoeg.State{
               environment: %{definition_name => "\n" <> body}
             }
    end

    test "can be evaluated by reference" do
      definition_name = "myname"

      body = """
        849 6716 +
      """

      program = "#{definition_name}:\n#{body};\nmyname"

      assert Hoeg.eval(program) == %Hoeg.State{
               elements: [7565],
               environment: %{definition_name => "\n" <> body}
             }
    end

    test "preserves existing elements" do
      definition_name = "myname"

      body = """
        849 6716 +
      """

      program = "2 #{definition_name}:\n#{body};\nmyname"

      assert Hoeg.eval(program) == %Hoeg.State{
               elements: [7565, 2],
               environment: %{definition_name => "\n" <> body}
             }
    end
  end

  describe "boolean" do
    test "greater than" do
      program = "1 3 >"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [false]}
    end

    test "greater than or equal to" do
      program = "3 3 >="
      assert Hoeg.eval(program) == %Hoeg.State{elements: [true]}
    end

    test "less than" do
      program = "1 3 <"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [true]}
    end

    test "less than or equal to" do
      program = "4 3 <="
      assert Hoeg.eval(program) == %Hoeg.State{elements: [false]}
    end

    test "equals to" do
      program = "42 42 =="
      assert Hoeg.eval(program) == %Hoeg.State{elements: [true]}
    end

    test "or" do
      program = "true false or"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [true]}
    end

    test "and" do
      program = "true false and"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [false]}
    end
  end

  describe "stack" do
    # test "pop" do
    #   program = "1 pop"
    #   assert Hoeg.eval()
    # end
  end

  # describe "exec" do
  #   program = "[1 1 +] exec"
  #   assert Hoeg.eval(program) == %Hoeg.State{elements: [2]}
  # end

  describe "next/3" do
    test "digit" do
      assert Hoeg.next("123", %{}, []) == {%{}, [value: 123]}
    end

    test "single word string" do
      assert Hoeg.next("\"hoeg\"", %{}, []) == {%{}, [value: "hoeg"]}
    end

    test "multi word string" do
      assert Hoeg.next("\"hoeg is great\"", %{}, []) == {%{}, [value: "hoeg is great"]}
    end

    test "multi word string and digits" do
      assert Hoeg.next("\"hoeg is great\" 42", %{}, []) ==
               {%{}, [value: "hoeg is great", value: 42]}
    end

    test "built-in function" do
      assert Hoeg.next("\"hello world\" print", %{}, []) ==
               {%{}, [value: "hello world", print: []]}
    end

    test "built-in functions inside string is not evaluated" do
      assert Hoeg.next("\"hello + world\"", %{}, []) == {%{}, [value: "hello + world"]}
    end
  end
end
