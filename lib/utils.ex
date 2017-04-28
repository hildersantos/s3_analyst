defmodule S3Analyst.Utils do
	@moduledoc """
	This modules holds all helper methods for kinds like calculation, and so on.
	"""

	@doc """
	Calculates a number and returns its size in a human-friendly format.
	Ex:
		iex> S3Analyst.Utils.humanize_bytes(1024)
		"1.0 KB"

		iex> S3Analyst.Utils.humanize_bytes(1234567)
		"1.17 MB"
	"""
	@spec humanize_bytes(String.t | number) :: String.t
	def humanize_bytes(bytes) when is_binary(bytes) do
		String.to_integer(bytes)
		|> humanize_bytes
	end

	def humanize_bytes(bytes) do
		sizes = ["Bytes", "KB", "MB", "GB", "TB"]

		index = :math.log(bytes) / :math.log(1024)
		|> Float.floor
		|> round

		number = bytes / :math.pow(1024, index)
		|> Float.floor(2)
		
		to_string(number) <> " " <> Enum.at(sizes, index)
	end

	@doc """
	Transforms an `iso8601` into a more friendly format.

	Ex.
		iex> S3Analyst.Utils.friendly_date("2017-04-21T04:57:13.000Z")
		"2017-04-21 04:57:13"
	"""
	@spec friendly_date(String.t) :: String.t
	def friendly_date(date) do
		with {:ok, datetime, _} <- DateTime.from_iso8601(date) do
			new_datetime = Map.update!(datetime, :microsecond, fn (_key) ->
				{0,0}
			end)
			NaiveDateTime.to_string(new_datetime)
		end
	end
	
end