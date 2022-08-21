defmodule Magic do
  @moduledoc """
  Documentation for `Magic`.
  """

  @on_load :init

  def init do
    :ok = :erlang.load_nif('./priv/magic', 0)
  end

  def create do
    raise "create/0 not implemented"
  end

  def buffer(_magic, _binary) do
    raise "buffer/2 not implemented"
  end

  def file(_magic, _filename) do
    raise "file/2 not implemented"
  end

  defmodule Server do
    use GenServer

    @impl GenServer
    def init(_state) do
      {:ok, Magic.create}
    end

    @impl GenServer
    def handle_call({:buffer, binary}, _, state) do
      {:reply, Magic.buffer(state, binary), state}
    end

    def start do
      GenServer.start(Server, 0, name: __MODULE__)
    end

    def buffer(binary) do
      GenServer.call(__MODULE__, {:buffer, binary})
    end
  end
end
