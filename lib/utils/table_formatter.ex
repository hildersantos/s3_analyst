defmodule S3Analyst.Utils.TableFormatter do
	@headers [name: "Name", creation_date: "Creation Date", total_files: "Total Files", total_size: "Total Size", last_modified_date: "Last Modified Date", region: "Region"]

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
		# Pego os itens das rows com as headers (keys)
		# Gero uma nova lista contendo uma lista com várias listas (cada uma, uma row)
		# Faço os cálculos necessários pra printar o resultado (normalizado)
	end

	defp columns_data(buckets, headers) do
		buckets =  [Enum.into(headers, %{}) | buckets]
		for {header_key, _header_value} <- headers do
			for bucket <- buckets do
				Map.get(bucket, header_key)
				|> normalize_data
			end
		end
	end

	defp calc_width(columns) do
		for column <- columns, do: column |> Enum.map(&String.length/1) |> Enum.max
	end

	defp format_column(columns_width) do
		"| " <> Enum.map_join(columns_width, " | ", fn width ->
			"~-#{width}s"
		end) <> " | " <> "~n"
	end

	defp separator(columns_width) do
		"--" <> Enum.map_join(columns_width, "-+-", fn width ->
			List.duplicate("-", width)
		end) <> "--"
	end

	defp print_one_row(data, format) do
		:io.format(format, data)
	end

	defp print_rows(data, format) do
		data
		|> List.zip
		|> Enum.map(&Tuple.to_list/1)
		|> Enum.drop(1) # Removes header
		|> Enum.each(&print_one_row(&1, format))
	end

	defp normalize_data(data) when is_binary(data) do
		data
	end

	defp normalize_data(data) do
		to_string(data)
	end
end