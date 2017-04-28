defmodule S3Analyst.Api do
	alias S3Analyst.Api.Bucket

	def fetch(options) do
		unless !!options[:no_cache] do
			Stash.load(:s3, "/tmp/s3_analyst")
		else
			IO.puts "Rebuilding cache, this may take a while...\r\n"
			Stash.delete(:s3, "buckets")
		end

		do_fetch(options)

	end

	defp do_fetch(options) do
		case Stash.get(:s3, "buckets") do
			nil ->
				task = Task.async(fn ->
					Bucket.get_buckets
					|> Bucket.fill_buckets
				end)

				case Task.yield(task, options[:timeout]) || Task.shutdown(task) do
					{:ok, result} ->
						Stash.set(:s3, "buckets", result)
						Stash.persist(:s3, "/tmp/s3_analyst")
						do_fetch(options)
					nil ->
						IO.puts "Error: Could not fetch buckets (Timeout: #{options[:timeout]}ms)"
						System.halt(0)
				end
			buckets ->
				if Enum.count(buckets) === 0 do
					IO.puts "No buckets found"
				else
					buckets
				end
		end
	end
end