defmodule Tethys.Flow.UdpSpringTest do
  use ExUnit.Case
  alias Tethys.{Spring, Pool, Springs.UdpSpring, Pools.StillPool}
  doctest UdpSpring

  test "can be seeded" do
    assert {:ok, _} = UdpSpring.seed(%{address: %{port: 4444}})
  end

  test "can attach a flow" do
    UdpSpring.seed!(%{address: %{port: 4444}})
    |> Spring.flow(StillPool.seed!())
  end

  test "receives UDP messages and sends them to flow" do
    UdpSpring.seed!(%{address: %{port: 4444}})
    |> Spring.flow(StillPool.seed!() |> Pool.leak(self()))

    {:ok, socket} = :gen_udp.open(8680)
    :gen_udp.send(socket, {127,0,0,1}, 4444, "Sent over UDP")

    assert_receive {:drip, _, "Sent over UDP"}, 50
  end
end
