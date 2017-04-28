defmodule S3Analyst.Api.BucketTest do
	use ExUnit.Case, async: true
	alias S3Analyst.Api.Bucket

	@moduletag :external
	
	describe "Bucket tasks:" do
		setup :get_buckets

		# For this test to pass, you should have at least one bucket on your account, and valid credentials set up on your test environment.
		test "get bucket list", %{buckets: buckets} do
			assert is_map(buckets)
			assert Enum.count(buckets) > 0
		end

		test "generated buckets is a list and have a %Bucket{}", %{buckets: buckets} do
		  new_buckets = Bucket.fill_buckets(buckets)
			assert is_list(new_buckets)

			first_bucket = List.first(new_buckets)
			assert first_bucket.__struct__ == S3Analyst.Api.Bucket
		end
	end

	defp get_buckets(_context) do
		buckets = Bucket.get_buckets

		[buckets: buckets]
	end

end