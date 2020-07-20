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

    test "list" do
      program = "[1, 2, 3, 4]"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [[1, 2, 3, 4]]}
    end

    test "construct map" do
      program = "%{1 => true, \"hello\" => \"hoeg!\"}"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [%{1 => true, "hello" => "hoeg!"}]}
    end

    test "construct map with string key containing map end char" do
      program = """
      %{"}" => 1}
      """

      assert Hoeg.eval(program) == %Hoeg.State{elements: [%{"}" => 1}]}
    end

    test "construct map with string value containing map end char" do
      program = """
      %{"foo" => "}"}
      """

      assert Hoeg.eval(program) == %Hoeg.State{elements: [%{"foo" => "}"}]}
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

      program = "#{definition_name}:\n#{body};\n#{definition_name}"

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

      program = "2 #{definition_name}:\n#{body};\n#{definition_name}"

      assert Hoeg.eval(program) == %Hoeg.State{
               elements: [7565, 2],
               environment: %{definition_name => "\n" <> body}
             }
    end

    test "nested" do
      program = """
      foo: 1 2 +;
      bar:
        foo
        foo;
      bar +
      """

      assert Hoeg.eval(program) == %Hoeg.State{
               elements: [6],
               environment: %{"bar" => "\n  foo\n  foo", "foo" => " 1 2 +"}
             }
    end

    test "pattern match" do
      myfn = """
        myfn []: 0;
        myfn n: n;
      """

      program = "1 myfn"

      assert Hoeg.eval(program) == %Hoeg.State{
               elements: [1],
               environment: %{"myfn" => "\n#{myfn}"}
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

    test "not" do
      program = "false not"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [true]}
    end

    test "not equal" do
      program = "true false !="
      assert Hoeg.eval(program) == %Hoeg.State{elements: [true]}
    end
  end

  describe "list operations" do
    test "cons appends an item to a list" do
      program = "1 [] cons"
      assert Hoeg.eval(program) == %Hoeg.State{elements: [[1]]}
    end

    test "cons fails with non-list item at top of stack" do
      program = "1 2 cons"
      assert_raise(Hoeg.Error.Syntax, fn -> Hoeg.eval(program) end)
    end
  end

  describe "match" do
    test "pattern matching" do
    end
  end

  # describe "stack" do
  #   test "pop" do
  #     program = "1 pop"
  #     assert Hoeg.eval(Hoeg.eval(program) == %Hoeg.State{elements: [[1]]})
  #   end
  # end
end
