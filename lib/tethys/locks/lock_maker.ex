defmodule Tethys.Locks.LockMaker do
  defmacro __using__(opts) do
    quote do
      use GenServer
      alias Tethys.Flow
      defstruct [:pid]

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
          enter_data = data |> then(unquote(opts[:on_enter]))
          state.dest |> Flow.receive(enter_data)
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
          exit_data = data |> then(unquote(opts[:on_exit]))
          state.dest |> Flow.receive(exit_data)
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


      defimpl Tethys.Lock, for: __MODULE__ do
        def entrance(%{pid: dam}), do: GenServer.call(dam, :entrance)
        def exit(%{pid: dam}), do: GenServer.call(dam, :exit)
      end

      defimpl Tethys.Flow, for: __MODULE__.Entrance do
        def receive(%{pid: flow} = entrance, data) do
          GenServer.cast(flow, {:receive, data})
          entrance
        end
      end

      defimpl Tethys.Flow, for: __MODULE__.Exit do
        def receive(%{pid: flow} = exit, data) do
          GenServer.cast(flow, {:receive, data})
          exit
        end
      end
    end
  end
end