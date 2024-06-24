# Tethys
[![Hex.pm](https://img.shields.io/hexpm/v/tethys.svg)](https://hex.pm/packages/tethys)
[![Hex.pm](https://img.shields.io/hexpm/dt/tethys.svg)](https://hex.pm/packages/tethys)
[![Hex.pm](https://img.shields.io/hexpm/dw/tethys.svg)](https://hex.pm/packages/tethys)
[![Hex.pm](https://img.shields.io/hexpm/dd/tethys.svg)](https://hex.pm/packages/tethys)

> Tethys was the Titan goddess of the primal font of fresh water which nourishes the earth... feeding her children's springs with the waters of Okeanos drawn through subterranean acquifers.

A networking library that guides and crafts the streams of information flowing through the modern world. Aiding the technological waters drawn from lakes, rivers, and rains as they move towards the world's oceans.

## Concepts

### Pools

[Pools](lib/tethys/pool.ex) are places where data is stored. For example, a [StillPool](lib/tethys/pools/still_pool.ex) is a Pool which just appends any data it receives into an in-memory list.

- You may **sip** from a Pool, which is to receive one piece of data from it.

- You may **drain** a Pool, which is to retrieve all data the data it currently contains.

- You may create a **leak** in a Pool, which causes data to - as it enters the Pool - immediately be sent to the location of the leak (and not be stored).

### Flows

[Flows](lib/tethys/flow.ex) are entities through which data may move. For example, a [DispersedFlow](lib/tethys/flows/dispersed_flow.ex) can act as a round-robin load balancer between multiple flows.

- A Flow may **receive** data

### Springs

[Springs](lib/tethys/spring.ex) are entities that may produce data. For example, a [UdpSpring](lib/tethys/springs/udp_spring.ex) can connect to a port and any data sent to that port will be pushed to a connected flow.

- A Spring may send data through its **flow**

### Locks

[Locks](lib/tethys/lock.ex) are bi-directional Flows, where the direction you are moving applies different transforms to the data. For example, a [MsgPackLock](https://github.com/polymorfiq-tools/tethys_msgpack), when moving one way will pack data moving through it via MessagePack. The other direction will unpack the data.

- A Lock has an **entrance** through which a transform may be made
- A Lock has an **exit** through which a different (likely inverse) transform may be made

## Usage Examples

More examples can be found in the [unit tests](test).

```elixir
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
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `tethys` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tethys, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/tethys>.

