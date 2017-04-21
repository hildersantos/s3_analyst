defmodule S3Analyst.Api.Bucket do
	alias S3Analyst.Api.{Bucket, Object}
	import SweetXml, only: [xpath: 2, sigil_x: 2]

	defstruct name: nil, creation_date: nil, total_files: nil, total_size: nil, last_modified_date: nil, region: nil, objects: nil 
	@type t :: %Bucket{name: String.t, creation_date: any, total_files: number, total_size: number, last_modified_date: any, region: String.t, objects: [Object.t]}

	def get_buckets do
		response = ExAws.S3.list_buckets
		|> ExAws.request!

		Enum.map(response.body.buckets, fn bucket ->
			struct(Bucket, bucket)
			|> populate_bucket
		end)
	end

	def populate_bucket(%Bucket{} = bucket) do
		bucket
		|> add_region_to_bucket
		|> attach_objects_and_info
	end

	def add_region_to_bucket(%Bucket{} = bucket) do
		region = ExAws.S3.get_bucket_location(bucket.name)
		|> ExAws.request!

		# This is necessary because us-east-1 returns an empty string
		region = case region.body |> xpath(~x"/LocationConstraint/text()") |> to_string do
			"" -> "us-east-1"
			region -> region
		end

		%Bucket{bucket | region: region}
	end

	def attach_objects_and_info(%Bucket{} = bucket) do
		objects = ExAws.S3.list_objects(bucket.name)
		|> ExAws.stream!(region: bucket.region) # We need to pass the region to the request
		|> Enum.sort_by(&Map.get(&1, :last_modified), &>=/2)
		
		# Filling objects and getting total size...
		{objects, total_size} = Enum.map_reduce(objects, 0, fn object, total_size ->
			{struct(Object, object), String.to_integer(object.size) + total_size}
		end)

		# Filling the %Bucket{} struct...
		%Bucket{
			bucket |
			objects: objects,
			total_files: Enum.count(objects),
			total_size: total_size,
			last_modified_date: List.first(objects) |> Map.get(:last_modified)
		}
	end


end