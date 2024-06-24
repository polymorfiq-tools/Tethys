# Tethys

> Tethys was the Titan goddess of the primal font of fresh water which nourishes the earth... feeding her children's springs with the waters of Okeanos drawn through subterranean acquifers.

A networking library that guides and crafts the streams of information flowing through the modern world. Aiding the technological waters drawn from lakes, rivers, and rains as they move towards the world's oceans.

## Concepts

### Pools

[Pools](lib/tethys/pool.ex) are places where data is stored. For example, a [StillPool](lib/tethys/pools/still_pool.ex) is a Pool which just appends any data it receives into an in-memory list.

- You may **sip** from a Pool, which is to receive one piece of data from it.

- You may **drain** a Pool, which is to retrieve all data the data it currently contains.

- You may create a **leak** in a Pool, which causes data to - as it enters the Pool - immediately be sent to the location of the leak (and not be stored).

### Flows

[Flows](lib/tethys/flow.ex) are entities through which data may move. For example, a [Dispersed Flow](lib/tethys/flows/dispersed_flow.ex) can act as a round-robin load balancer between multiple flows.

- A Flow may **receive** data

### Springs

[Springs](lib/tethys/spring.ex) are entities that may produce data. For example, a [UdpSpring](lib/tethys/springs/udp_spring.ex) can connect to a port and any data sent to that port will be pushed to a connected flow.

- A Spring may send data through its **flow**

### Locks

[Locks](lib/tethys/lock.ex) are bi-directional Flows, where the direction you are moving applies different transforms to the data. For example, a [MsgPackLock](lib/tethys/locks/msg_pack_lock.ex), when moving one way will pack data moving through it via MessagePack. The other direction will unpack the data.

- A Lock has an **entrance** through which a transform may be made
- A Lock has an **exit** through which a different (likely inverse) transform may be made

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

