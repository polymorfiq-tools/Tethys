defmodule Tethys.Flow.UdpSpringTest do
  use ExUnit.Case
  alias Tethys.{Flow, Pool, Spring, Springs.UdpSpring, Pools.StillPool}
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
    :gen_udp.send(socket, {127, 0, 0, 1}, 4444, "Sent over UDP")

    assert_receive {:drip, _, "Sent over UDP"}, 50
  end

  test "sends (pumps) UDP messages that flow into it" do
    pool_a = StillPool.seed!() |> Pool.leak(self())
    pool_b = StillPool.seed!() |> Pool.leak(self())

    UdpSpring.seed!(%{address: %{port: 5555}})
    |> Spring.flow(pool_a)

    UdpSpring.seed!(%{address: %{port: 6666}})
    |> Spring.flow(pool_b)

    UdpSpring.seed!(%{address: %{port: 4444}})
    |> UdpSpring.pumps([
      {{127, 0, 0, 1}, 5555},
      {{127, 0, 0, 1}, 6666}
    ])
    |> Flow.receive("Broadcast to both")

    assert_receive {:drip, ^pool_a, "Broadcast to both"}, 50
    assert_receive {:drip, ^pool_b, "Broadcast to both"}, 50
  end
end
