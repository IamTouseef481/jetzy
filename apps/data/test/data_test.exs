defmodule DataTest do
  use ExUnit.Case
  doctest Data

  test "greets the world" do
    assert Data.hello() == :world
  end

  @tag :data
  test "ut8 handling" do
    string = "Immerse yourself in what Nature has to offer. ❤"
    {:ok, out} = Jetzy.Helper.sanitize_string(string)
    assert out == string
  end

end
