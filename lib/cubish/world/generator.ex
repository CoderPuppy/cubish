defmodule Cubish.World.Generator do
	def start_link, do: Cubish.JobQueue.start_link({__MODULE__, :process, []}, 1)
	def queue(job_queue, chunk_holder), do: Cubish.JobQueue.queue(job_queue, chunk_holder)

	def process(chunk_holder) do
		Cubish.ChunkHolder.update chunk_holder, Cubish.Chunk.generate_data(Cubish.ChunkHolder.get_chunk(chunk_holder))
	end
end