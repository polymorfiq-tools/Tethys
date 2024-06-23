defmodule Tethys.Pools.StillPoolTest do
  use ExUnit.Case
  alias Tethys.{Flow, Pool, Pools.StillPool}
  doctest StillPool

  test "can be seeded" do
    assert {:ok, _} = StillPool.seed()
  end

  test "can be seeded with data" do
    StillPool.seed!([123]) |> Pool.sip(self())
    assert_receive {:drip, _, 123}, 50
  end

  test "can receive data" do
    StillPool.seed!()
    |> Flow.receive("Some Data")
    |> Pool.sip(self())
    |> Flow.receive("Other Data")
    |> Pool.sip(self())

    assert_receive {:drip, _, "Some Data"}, 50
    assert_receive {:drip, _, "Other Data"}, 50
  end

  test "can be drained" do
    StillPool.seed!()
    |> Flow.receive("Some Data")
    |> Flow.receive("Other Data")
    |> Pool.drain(self())
    |> Flow.receive("Even More Data")
    |> Pool.drain(self())

    assert_receive {:drip, _, "Some Data"}, 50
    assert_receive {:drip, _, "Other Data"}, 50
    assert_receive {:drip, _, "Even More Data"}, 50
  end
end
