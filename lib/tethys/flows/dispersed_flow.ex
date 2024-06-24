defmodule Tethys.Flows.DispersedFlow do
  use GenServer
  alias Tethys.Flow
  defstruct [:pid]

  @moduledoc """
  Pushes data it receives equally via round-robin to all destination flows
  """

  def craft(destinations \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, destinations)
    {:ok, %__MODULE__{pid: pid}}
  end

  def craft!(destinations \\ []) do
    {:ok, flow} = craft(destinations)
    flow
  end

  def init(destinations) do
    {:ok, %{dests: destinations, next_dest: 0}}
  end

  def handle_call({:receive, _}, _, %{dests: []} = state), do: {:noreply, state}
  def handle_call({:receive, data}, _, state) do
    state.dests
    |> Enum.fetch!(state.next_dest)
    |> Flow.receive(data)

    next_dest = state.next_dest + 1 |> rem(Enum.count(state.dests))
    {:reply, :ok, %{state | next_dest: next_dest}}
  end
end

defimpl Tethys.Flow, for: Tethys.Flows.DispersedFlow do
  def receive(%{pid: pid} = flow, data) do
    GenServer.call(pid, {:receive, data})
    flow
  end
end