defmodule SupervisorExampleTest do
  use ExUnit.Case
  doctest SupervisorExample

  test "greets the world" do
    assert SupervisorExample.hello() == :world
  end
end
