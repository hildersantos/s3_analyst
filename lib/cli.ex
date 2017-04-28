defmodule S3Analyst.CLI do
	alias S3Analyst.Api
	import S3Analyst.Utils

	@moduledoc """
	This module is responsible for outputing fetched results from `S3Analyst.Api.Bucket`.
	"""

	# Default options
	@defaults [
		output: "table",
		limit: -1,
		order: "asc",
		order_by: "creation_date",
		timeout: 15000, # ms
		filter: nil,
		humanize: false,
		percentage: false
	]

	# Arguments parser params
	@switches [
		help: :boolean,
		no_cache: :boolean,
		order_by: :string,
		output: :string,
		percentage: :boolean,
		limit: :integer,
		timeout: :integer,
		filter: :string,
		humanize: :boolean
	]
	@aliases [
		h: :help,
		H: :humanize,
		o: :output,
		p: :percentage,
		l: :limit,
		t: :timeout,
		f: :filter,
	]

	# Text used by help
	@help_txt """
	Usage: s3analyst [--limit | -l <number>] [--output | -o <table | json>] [--order_by <name | size | creation_date | last_updated>] [--order <asc | desc>] [--percentage | -p] [--no-cache] [--help | -h]

	--limit, -l 				Limit the total results (-1 to show all results). Default: #{@defaults[:limit]}
	--output, -o 				Output format (table, json). Default: #{@defaults[:output]} 
	--order-by				Orders by name, total_size, total_files, region, creation_date or last_modified_date. Default: #{@defaults[:order_by]}
	--order 				Outputs results in ascendent (asc) or descendent (desc) order. Default: #{@defaults[:order]}
	--percentage, -p 			Shows percentage of size used by bucket (relative to total buckets size)
	--filter, -f 				Filters the results by bucket name. You can pass regular expressions to this option. Ex: -f ^prefix
	--no-cache 				Invalidates the cache and fetches fresh results from Amazon S3
	--timeout, -t				Forces a request timeout value (in ms). Default: #{@defaults[:timeout]}
	--help, -h  				Shows help (you are seeing it right now).
	"""


	@doc """
	Main function. Comunicates with the shell script and passes all the arguments, processing them.
	"""
	@spec main([String.t]) :: any
	def main(argv) do
		argv
		|> parse_args
		|> process
	end

	@doc """
	This function takes a list of arguments and returns a tuple, with valid or invalid options.

	Ex:
		iex> S3Analyst.CLI.parse_args(["--help"])
		:help
	"""
	@spec parse_args([String.t]) :: atom | tuple
	def parse_args(argv) do
		parse = OptionParser.parse(argv, switches: @switches, aliases: @aliases)

		case parse do
			{[help: true], _, _} -> :help
			{options, [], []} -> {:do_process, normalized_keyword(options)}
			{[], _, []} -> :help
			{_, _, invalid_options} -> {:invalid, invalid_options}
		end
	end

	@doc """
	Processes the response.
	"""
	@spec process(atom | tuple) :: any
	def process(:help) do
		IO.puts @help_txt
		System.halt(0)
	end

	def process({:invalid, invalid_options}) do
		Enum.each(invalid_options, fn ({key, value}) ->
			IO.puts "Invalid option #{key} with value #{inspect value}."
		end)
		System.halt(0)
	end

	def process({:do_process, options}) do
		Api.fetch(options)
		|> transform_date
		|> order_by(options[:order_by], options[:order])
		|> humanize_size(options[:humanize])
		|> filter(options[:filter])
		|> limit(options[:limit])
		|> output_result(options[:output])
	end

	# Below, theres a lot of private helper functions,
	# used for ordering, filtering and limiting the results, and so on.

	defp transform_date(buckets) do
		for bucket <- buckets do
			%{bucket | creation_date: friendly_date(bucket.creation_date), last_modified_date: friendly_date(bucket.last_modified_date)}
		end
	end

	defp humanize_size(buckets, humanize) do
		if humanize do
			for bucket <- buckets do
				%{bucket | total_size: humanize_bytes(bucket.total_size)}
			end
		else
			buckets
		end
	end

	defp order_by(buckets, order_by, order) do
		valid_options = ["name", "creation_date", "last_modified_date", "region", "total_files", "total_size"]

		order = case order do
			"desc" -> &>=/2 
				_ -> &<=/2 
		end

		case Enum.member?(valid_options, order_by) do
			true ->
				Enum.sort_by(buckets, fn(bucket) ->
					Map.get(bucket, String.to_atom(order_by))
				end, order)
			false -> process({:invalid, [order_by: order_by]})
		end
	end

	defp limit(buckets, limit) do
		if limit !== -1 do
			Enum.take(buckets, limit)
		else
			buckets
		end
	end

	defp filter(buckets, filter) when is_nil(filter) do
		buckets
	end

	defp filter(buckets, filter) do
		filtered_buckets = buckets
		|> Enum.filter(fn bucket ->
			case Regex.compile(filter) do
				{:ok, compiled} ->
					Regex.match?(compiled, bucket.name)
				_ ->
					false
			end
		end)

		if length(filtered_buckets) === 0 do
			IO.puts "No buckets matched your criteria"
		 	System.halt(0)
		end

		filtered_buckets
	end

	defp output_result(buckets, output_format) do
		case output_format do
			"table" ->
				S3Analyst.Utils.TableFormatter.print_table(buckets)
			"json" ->
				Poison.encode!(buckets)
		end
	end

	defp normalized_keyword(options) do
		Keyword.merge(@defaults, options)
	end
end