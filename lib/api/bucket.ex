defmodule S3Analyst.Api.Bucket do
	alias S3Analyst.Api.{Bucket, Object}
	import SweetXml, only: [xpath: 2, sigil_x: 2]

	@moduledoc """
	This is the module responsible for all the communication with the AWS S3 API. It makes requests and normalizes data, transforming it in a `%Bucket{}` struct.

	## The `%Bucket{}` struct

	The `%Bucket{}` holds all the data necessary to make calculations, filtering and output. It works as a local copy from a S3 bucket.
	"""
	defstruct name: nil, creation_date: nil, total_files: nil, total_size: nil, last_modified_date: nil, region: nil, objects: nil 
	@type t :: %Bucket{name: String.t, creation_date: any, total_files: number, total_size: number, last_modified_date: any, region: String.t, objects: [Object.t]}

	@doc """
	This function fetches the buckets from an AWS account. Note that you should have valid credentials set in your environment to use this - and all following - functions.
	"""
	@spec get_buckets :: term
	def get_buckets do
		ExAws.S3.list_buckets
		|> ExAws.request!
	end

	@doc """
	Fills bucket with info. Should have a valid ExAws.Request parameter.
	"""
	@spec fill_buckets(term) :: [Bucket.t]
	def fill_buckets(%{body: %{buckets: buckets}} = _request) do
		# Anonymous function to async stream
		build_buckets = fn bucket ->
			bucket
			|> generate_struct
			|> add_region_to_bucket
			|> attach_objects_to_bucket
		end

		# Making async requests between buckets, improving concurrency
		buckets
		|> Task.async_stream(build_buckets)
		|> Enum.reduce([], fn ({:ok, item}, rest) ->
			[item | rest]
		end)
	end

	@doc """
	Generates the struct from an `ExAws` valid request.
	"""
	@spec generate_struct(term) :: Bucket.t
	def generate_struct(bucket) do
		struct(Bucket, bucket)
	end

	@doc """
	Fetches and fills the bucket location into `%Bucket{}`.
	"""
	@spec add_region_to_bucket(Bucket.t) :: Bucket.t
	def add_region_to_bucket(%Bucket{name: name} = bucket) do
		region = ExAws.S3.get_bucket_location(name)
		|> ExAws.request!

		# This is necessary because us-east-1 returns an empty string
		region = case region.body |> xpath(~x"/LocationConstraint/text()") |> to_string do
			"" -> "us-east-1"
			region -> region
		end

		%Bucket{bucket | region: region}
	end

	@doc """
	This function does some interesting things:

	1. Fetches the objects from one given `%Bucket{}` *(please note this `%Bucket{}` should have valid `:name` and `:region` keys)`*
	2. Sorts the objects by creation date (newest to oldest)
	3. Fills the remaining keys from `%Bucket{}`, based on objects info
	"""
	@spec attach_objects_to_bucket(Bucket.t) :: Bucket.t
	def attach_objects_to_bucket(%Bucket{name: name, region: region} = bucket) when not is_nil(name) and not is_nil(region) do
		objects = ExAws.S3.list_objects(name)
		|> ExAws.stream!(region: region) # We need to pass the region to the request
		|> Enum.sort_by(&Map.get(&1, :last_modified), &>=/2)
		
		# Filling objects and calculating total size...
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