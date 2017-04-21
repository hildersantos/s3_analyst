defmodule S3Analyst.Api.BucketTest do
	use ExUnit.Case, async: true
	alias S3Analyst.Api.Bucket

	describe "Bucket tasks:" do
		setup :get_buckets

		# For this test to pass, you should have at least one bucket on your account, and valid credentials setted up on your test environment.
		test "get bucket list", %{buckets: buckets} do
			assert is_list(buckets)
			assert Enum.count(buckets) > 0
		end
	end

	defp get_buckets(_context) do
		response = Bucket.get_buckets

		[buckets: response.body.buckets]
	end

end