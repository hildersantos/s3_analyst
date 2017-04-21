defmodule S3Analyst.Api do
	alias S3Analyst.Api.{Bucket, Object}

	def request!(operation, overrides \\ []) do
		ExAws.request!(operation, overrides)
	end

	def stream!(operation, overrides \\ []) do
		ExAws.stream!(operation, overrides)
	end
end