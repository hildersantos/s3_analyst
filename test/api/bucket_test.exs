defmodule S3Analyst.Api.BucketTest do
	use ExUnit.Case, async: true
	alias S3Analyst.Api.Bucket

	describe "Bucket tasks:" do

		test "get bucket list" do
			buckets = Bucket.get_buckets
			assert is_list(buckets)
			assert Enum.count(buckets) >= 0
		end

	end

end