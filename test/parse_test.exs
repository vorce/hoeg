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
               {%{}, [value: "hello world", print: []]}
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

  describe "until_quote" do
    test "escaped string" do
      string = "}\""
      assert Parse.until_quote(String.graphemes(string), "") == {"}\"", []}
    end

    test "escaped string 2" do
      string = "%{1 => \"}\"}"
      assert Parse.until_quote(String.graphemes(string), "") == {"%{1 => \"", ["}", "\"", "}"]}
    end
  end
end
