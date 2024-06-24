defmodule Tethys.Locks.MsgPackLock do
  use GenServer
  alias Tethys.Flow
  defstruct [:pid]

  @moduledoc """
  Converts all data that passes through, with Msgpack and back again
  """

  defmodule Entrance do
    use GenServer
    defstruct [:pid]

    def construct(dest) do
      {:ok, pid} = GenServer.start_link(__MODULE__, dest)
      {:ok, %__MODULE__{pid: pid}}
    end

    def init(dest), do: {:ok, %{dest: dest}}
    def dest(%{pid: pid} = entrance, dest) do
      GenServer.cast(pid, {:dest, dest})
      entrance
    end

    def handle_cast({:receive, _}, %{dest: nil} = state), do: {:noreply, state}
    def handle_cast({:receive, data}, state) do
      packed = Msgpax.pack!(data)
      state.dest |> Flow.receive(packed)
      {:noreply, state}
    end

    def handle_cast({:dest, dest}, state) do
      {:noreply, %{state | dest: dest}}
    end
  end

  defmodule Exit do
    use GenServer
    defstruct [:pid]

    def construct(dest) do
      {:ok, pid} = GenServer.start_link(__MODULE__, dest)
      {:ok, %__MODULE__{pid: pid}}
    end

    def init(dest), do: {:ok, %{dest: dest}}
    def dest(%{pid: pid} = exit, dest) do
      GenServer.cast(pid, {:dest, dest})
      exit
    end

    def handle_cast({:receive, _}, %{dest: nil} = state), do: {:noreply, state}
    def handle_cast({:receive, data}, state) do
      unpacked = Msgpax.unpack!(data)
      state.dest |> Flow.receive(unpacked)
      {:noreply, state}
    end

    def handle_cast({:dest, dest}, state) do
      {:noreply, %{state | dest: dest}}
    end
  end

  def construct(in_flow \\ nil, out_flow \\ nil) do
    {:ok, pid} = GenServer.start_link(__MODULE__, {in_flow, out_flow})
    {:ok, %__MODULE__{pid: pid}}
  end

  def construct!(in_flow \\ nil, out_flow \\ nil) do
    {:ok, lock} = construct(in_flow, out_flow)
    lock
  end

  def init({in_flow, out_flow}) do
    {:ok, entrance} = Entrance.construct(in_flow)
    {:ok, exit} = Exit.construct(out_flow)

    {:ok, %{entrance: entrance, exit: exit}}
  end

  def handle_call(:entrance, _, state), do: {:reply, state.entrance, state}
  def handle_call(:exit, _, state), do: {:reply, state.exit, state}
end

defimpl Tethys.Lock, for: Tethys.Locks.MsgPackLock do
  def entrance(%{pid: dam}), do: GenServer.call(dam, :entrance)
  def exit(%{pid: dam}), do: GenServer.call(dam, :exit)
end

defimpl Tethys.Flow, for: Tethys.Locks.MsgPackLock.Entrance do
  def receive(%{pid: flow} = entrance, data) do
    GenServer.cast(flow, {:receive, data})
    entrance
  end
end

defimpl Tethys.Flow, for: Tethys.Locks.MsgPackLock.Exit do
  def receive(%{pid: flow} = exit, data) do
    GenServer.cast(flow, {:receive, data})
    exit
  end
end