defmodule Tethys.Locks.MsgPackLockTest do
  use ExUnit.Case
  alias Tethys.{Flow, Lock, Pool, Locks.MsgPackLock, Pools.StillPool}
  doctest MsgPackLock

  test "can be constructed" do
    assert {:ok, lock} = MsgPackLock.construct()
    assert _ = Lock.entrance(lock)
    assert _ = Lock.exit(lock)
  end

  test "entrance converts to MessagePack format" do
    pool = StillPool.seed!() |> Pool.leak(self())
    lock = MsgPackLock.construct!(pool)

    lock |> Lock.entrance() |> Flow.receive("unpacked")

    assert_receive {:drip, ^pool, [168 | "unpacked"]}, 50
  end

  test "exit converts from MessagePack format" do
    pool = StillPool.seed!() |> Pool.leak(self())
    lock = MsgPackLock.construct!(nil, pool)

    lock |> Lock.exit() |> Flow.receive([168 | "unpacked"])

    assert_receive {:drip, ^pool, "unpacked"}, 50
  end

  test "can be used in a single flow" do
    pool = StillPool.seed!() |> Pool.leak(self())
    lock = MsgPackLock.construct!(nil, pool)

    Lock.entrance(lock)
    |> MsgPackLock.Entrance.dest(Lock.exit(lock))
    |> Flow.receive("flowed-through-both")

    assert_receive {:drip, ^pool, "flowed-through-both"}, 50
  end
end
