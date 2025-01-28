defmodule TaskExampleTest do
  use ExUnit.Case
  doctest TaskExample

  test "greets the world" do
    assert TaskExample.hello() == :world
  end
end
