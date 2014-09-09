defmodule Cubish.ChunkHolder do
	use GenServer

	defstruct [:save, :world, :pos, :pid]

	def start_link(chunk = %Cubish.Chunk{}, opts \\ []), do: GenServer.start_link(__MODULE__, chunk, opts)
	def spec(chunk, opts \\ []), do: Supervisor.Spec.worker(__MODULE__, [chunk], opts)
	def init(chunk), do: {:ok, chunk}

	def get(pid) when is_pid(pid), do: GenServer.call(pid, :get)
	def handle_call(:get, _from, chunk), do: {:reply, %Cubish.ChunkHolder{
		save: chunk.save,
		world: chunk.world,
		pos: chunk.pos,
		pid: self
	}, chunk}

	def get_chunk(%Cubish.ChunkHolder{pid: pid}), do: GenServer.call(pid, :get_chunk)
	def handle_call(:get_chunk, _from, chunk), do: {:reply, chunk, chunk}
	
	def generate(%Cubish.ChunkHolder{pid: pid}, generator), do: GenServer.cast(pid, {:generate, generator})
	def handle_cast({:generate, generator}, chunk), do: {:noreply, chunk |> Cubish.Chunk.generate(generator)}
end

defimpl String.Chars, for: Cubish.ChunkHolder do
	def to_string(holder) do
		{cx, cy, cz} = holder.pos
		"#{holder.save} - #{holder.world} - (#{cx}, #{cy}, #{cz})"
	end
end