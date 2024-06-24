defmodule Tethys.Locks.MsgPackLock do
  use Tethys.Locks.LockMaker, [
    on_enter: fn data -> Msgpax.pack!(data) end,
    on_exit: fn data -> Msgpax.unpack!(data) end
  ]

  @moduledoc """
  Converts all data that passes through, with Msgpack and back again
  """
end