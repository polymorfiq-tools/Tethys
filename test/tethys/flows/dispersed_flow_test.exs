defmodule Tethys.Flow.DispersedFlowTest do
  use ExUnit.Case
  alias Tethys.{Flow, Pool, Flows.DispersedFlow, Pools.StillPool}
  doctest DispersedFlow

  test "can be crafted" do
    assert {:ok, _} = DispersedFlow.craft()
  end

  test "can be crafted with destinations" do
    pool = StillPool.seed!()
    DispersedFlow.craft!([pool]) |> Flow.receive("Pooled Data")
    pool |> Pool.drain(self())

    assert_receive {:drip, _, "Pooled Data"}, 50
  end

  test "round-robins data evenly across destinations" do
    pool_a = StillPool.seed!()
    pool_b = StillPool.seed!()

    DispersedFlow.craft!([pool_a, pool_b])
    |> Flow.receive("Data A")
    |> Flow.receive("Data B")
    |> Flow.receive("Data C")
    |> Flow.receive("Data D")
    |> Flow.receive("Data E")
    |> Flow.receive("Data F")

    pool_a |> Pool.drain(self())
    assert_receive {:drip, _, "Data A"}, 50
    assert_receive {:drip, _, "Data C"}, 50
    assert_receive {:drip, _, "Data E"}, 50

    pool_b |> Pool.drain(self())
    assert_receive {:drip, _, "Data B"}, 50
    assert_receive {:drip, _, "Data D"}, 50
    assert_receive {:drip, _, "Data F"}, 50
  end
end
