defmodule Hoeg.ParseTest do
  use ExUnit.Case

  alias Hoeg.Parse

  describe "next/3" do
    test "digit" do
      assert Parse.next("123", %{}, []) == {%{}, [value: 123]}
    end

    test "single word string" do
      assert Parse.next("\"hoeg\"", %{}, []) == {%{}, [value: "hoeg"]}
    end

    test "multi word string" do
      assert Parse.next("\"hoeg is great\"", %{}, []) == {%{}, [value: "hoeg is great"]}
    end

    test "multi word string and digits" do
      assert Parse.next("\"hoeg is great\" 42", %{}, []) ==
               {%{}, [value: "hoeg is great", value: 42]}
    end

    test "built-in function" do
      assert Parse.next("\"hello world\" print", %{}, []) ==
               {%{}, [{:value, "hello world"}, {{:built_in, :print}, []}]}
    end

    test "built-in functions inside string is not evaluated" do
      assert Parse.next("\"hello + world\"", %{}, []) == {%{}, [value: "hello + world"]}
    end

    test "map with special key" do
      assert Parse.next("%{\"}\" => 1}", %{}, []) == {%{}, [value: %{"}" => 1}]}
    end

    test "map with special value" do
      assert Parse.next("%{1 => \"}\"}", %{}, []) == {%{}, [value: %{1 => "}"}]}
    end
  end

  test "list_value" do
    assert {:ok, [[]], _, _, _, _} = Parse.list_value("[]")
    assert {:ok, [1], _, _, _, _} = Parse.list_value("[1]")
    assert {:ok, ["foo"], _, _, _, _} = Parse.list_value("[\"foo\"]")
    assert {:ok, [1, 2, 3], _, _, _, _} = Parse.list_value("[1, 2, 3]")
    assert {:ok, [[1, 2], %{1 => 2}], _, _, _, _} = Parse.list_value("[[1, 2], %{1 => 2}]")
  end

  test "map_value" do
    assert {:ok, [%{}], _, _, _, _} = Parse.map_value("%{}")
    assert {:ok, [%{"foo" => 1}], _, _, _, _} = Parse.map_value("%{\"foo\" => 1}")

    assert {:ok, [%{"foo" => 1, "fu" => 2}], _, _, _, _} =
             Parse.map_value("%{\"foo\" => 1, \"fu\" => 2}")

    assert {:ok, [%{[1, 2] => %{3 => 4}}], _, _, _, _} = Parse.map_value("%{[1, 2] => %{3 => 4}}")
  end

  test "definition" do
    definition_name = "myname"

    body = """
      849 6716 +
      "my name is Hoeg" print
    """

    definition = "#{definition_name}:\n#{body};"

    assert {:ok,
            [
              definition: [
                {:definition_name, "myname"},
                {:value, 849},
                {:value, 6716},
                {:add, []},
                {:value, "my name is Hoeg"},
                {{:built_in, :print}, []}
              ]
            ], _, _, _, _} = Parse.definition(definition)
  end

  test "one line definition" do
    definition = "bla: 1 2 +;"

    assert {:ok, [definition: [definition_name: "bla", value: 1, value: 2, add: []]], _, _, _, _} =
             Parse.definition(definition)
  end

  test "definition with one argument" do
    definition_name = "onearg"
    definition_arg = "arg"
    definition_signature = "#{definition_name} #{definition_arg}"
    definition = "#{definition_signature}:\n#{definition_arg};"

    assert {
             :ok,
             [
               definition: [
                 {:definition_name, definition_name},
                 {:definition_arg, definition_arg},
                 {:reference, definition_arg}
               ]
             ],
             _,
             _,
             _,
             _
           } = Parse.definition(definition)
  end

  test "reference" do
    assert {:ok, [reference: "bla"], _, _, _, _} = Parse.reference("\nbla\n")
    assert {:ok, [reference: "bla"], _, _, _, _} = Parse.reference(" bla ")
    assert {:ok, [reference: "bla"], _, _, _, _} = Parse.reference("\nbla")
    assert {:ok, [reference: "bla"], _, _, _, _} = Parse.reference("bla;")
  end
end
