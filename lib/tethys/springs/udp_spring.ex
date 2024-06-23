defmodule Tethys.Springs.UdpSpring do
  use GenServer
  defstruct [:pid]
  alias Tethys.Flow

  def seed(%{address: %{port: port}}) do
    {:ok, pid} = GenServer.start_link(__MODULE__, port)
    {:ok, %__MODULE__{pid: pid}}
  end

  def seed!(config) do
    {:ok, spring} = seed(config)
    spring
  end

  def init(port) do
    {:ok, socket} = :gen_udp.open(port, [:binary, active: true])
    {:ok, %{socket: socket, flow: nil, pumps: []}}
  end

  def handle_cast({:flow, flow}, state) do
    {:noreply, %{state | flow: flow}}
  end

  def handle_cast({:pumps, pumps}, state) do
    {:noreply, %{state | pumps: pumps}}
  end

  def handle_cast({:pump, data}, state) do
    state.pumps
    |> Enum.each(& Flow.receive(&1, data))

    {:noreply, state}
  end

  def handle_info({:udp, _socket, _address, _port, _data}, %{flow: nil} = state) do
    {:noreply, state}
  end

  def handle_info({:udp, _socket, _address, _port, data}, %{flow: flow} = state) do
    flow |> Flow.receive(data)

    {:noreply, state}
  end
end

defimpl Tethys.Flow, for: Tethys.Springs.UdpSpring do
  def receive(%{pid: flow} = spring, data) do
    GenServer.cast(flow, {:pump, data})

    spring
  end
end

defimpl Tethys.Spring, for: Tethys.Springs.UdpSpring do
  def flow(%{pid: pid} = spring, flow) do
    GenServer.cast(pid, {:flow, flow})
    spring
  end
end