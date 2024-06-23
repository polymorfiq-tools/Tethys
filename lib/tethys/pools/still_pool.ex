defmodule Tethys.Pools.StillPool do
  use GenServer
  defstruct [:pid]

  def seed(contents \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, contents)
    {:ok, %__MODULE__{pid: pid}}
  end

  def seed!(contents \\ []) do
    {:ok, pool} = seed(contents)
    pool
  end

  def init(contents), do: {:ok, %{contents: contents, leak: nil}}

  def handle_cast({:leak, recipient}, state) do
    {:noreply, %{state | leak: recipient}}
  end

  def handle_cast({:sip, _}, %{contents: []} = state), do: {:noreply, state}
  def handle_cast({:sip, recipient}, state) do
    [data | rest] = state.contents
    send(recipient, {:drip, %__MODULE__{pid: self()}, data})

    {:noreply, %{state | contents: rest}}
  end

  def handle_cast({:drain, recipient}, state) do
    state.contents
    |> Enum.each(& send(recipient, {:drip, %__MODULE__{pid: self()}, &1}))

    {:noreply, %{state | contents: []}}
  end

  def handle_cast({:receive, data}, %{leak: nil} = state) do
    {:noreply, %{state | contents: [data | state.contents]}}
  end

  def handle_cast({:receive, data}, %{leak: recipient} = state) do
    send(recipient, {:drip, %__MODULE__{pid: self()}, data})

    {:noreply, state}
  end
end

defimpl Tethys.Flow, for: Tethys.Pools.StillPool do
  def receive(%{pid: flow} = pool, data) do
    GenServer.cast(flow, {:receive, data})
    pool
  end
end

defimpl Tethys.Pool, for: Tethys.Pools.StillPool do
  def leak(%{pid: pid} = pool, recipient) do
    GenServer.cast(pid, {:leak, recipient})
    pool
  end

  def sip(%{pid: pid} = pool, recipient) do
    GenServer.cast(pid, {:sip, recipient})
    pool
  end

  def drain(%{pid: pid} = pool, recipient) do
    GenServer.cast(pid, {:drain, recipient})
    pool
  end
end