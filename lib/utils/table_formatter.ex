defmodule S3Analyst.Utils.TableFormatter do
	alias S3Analyst.Api.Bucket

	@headers [name: "Name", creation_date: "Creation Date", total_files: "Total Files", total_size: "Total Size", last_modified_date: "Last Modified Date", region: "Region"]

	@moduledoc """
	Module responsible for table output.
	"""

	@doc """
	Prints a formatted table. Keep in mind that it requires valid headers and a `%Bucket{}` list
	to work.
	"""
	@spec print_table([%Bucket{}], Keyword.t) :: String.t
	def print_table(buckets, headers \\ @headers) do
		with columns <- columns_data(buckets, headers),
			columns_width <- calc_width(columns),
			format <- format_column(columns_width) do

			IO.puts(separator(columns_width))

				headers
				|> Keyword.values
				|> print_one_row(format)

			IO.puts(separator(columns_width))

			print_rows(columns, format)

			IO.puts(separator(columns_width))
		end
	end

	# Below, there's some private methods to organize the table info.

	# This one extracts and sorts table data in columns
	defp columns_data(buckets, headers) do
		buckets = [Enum.into(headers, %{}) | buckets]
		for {header_key, _header_value} <- headers do
			for bucket <- buckets do
				Map.get(bucket, header_key)
				|> normalize_data
			end
		end
	end

	# Calculates each column width based on text length
	defp calc_width(columns) do
		for column <- columns, do: column |> Enum.map(&String.length/1) |> Enum.max
	end

	# Formats a column based on its width
	defp format_column(columns_width) do
		"| " <> Enum.map_join(columns_width, " | ", fn width ->
			"~-#{width}s"
		end) <> " | " <> "~n"
	end

	# Returns a row separator
	defp separator(columns_width) do
		"--" <> Enum.map_join(columns_width, "-+-", fn width ->
			List.duplicate("-", width)
		end) <> "--"
	end

	# Prints one row based on data and format
	defp print_one_row(data, format) do
		:io.format(format, data)
	end

	# Prints all rows
	defp print_rows(data, format) do
		data
		|> List.zip
		|> Enum.map(&Tuple.to_list/1)
		|> Enum.drop(1) # Removes header
		|> Enum.each(&print_one_row(&1, format))
	end

	# Normalizes data (converts into binary data)
	defp normalize_data(data) when is_binary(data) do
		data
	end

	defp normalize_data(data) do
		to_string(data)
	end
end