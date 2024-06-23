defmodule TethysTest do
  use ExUnit.Case
  doctest Tethys

  test "greets the world" do
    assert Tethys.hello() == :world
  end
end
