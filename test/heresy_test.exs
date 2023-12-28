defmodule HeresyTest do
  use ExUnit.Case

  doctest Heresy, import: true

  import Heresy

  describe "begin/1" do
    test "with no contents" do
      assert nil ==
               (begin do
                end)
    end

    test "with one expression" do
      assert 1 ==
               (begin do
                  1
                end)
    end

    test "with multiple expressions" do
      assert 3 ==
               (begin do
                  1
                  2
                  3
                end)

      assert false ==
               (begin do
                  match(true = String.valid?(<<128>>))
                  String.upcase("foo")
                end)
    end

    test "with single match" do
      assert 1 ==
               (begin do
                  match(1 = 1)
                end)

      assert :error ==
               (begin do
                  match(1 = 2, else: :error)
                end)
    end

    test "with match and multiple expressions" do
      assert 3 ==
               (begin do
                  match(1 = 1)
                  2
                  3
                end)

      assert :error ==
               (begin do
                  match(1 = 2, else: :error)
                  2
                  3
                end)
    end
  end
end
