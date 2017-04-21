defmodule S3Analyst.Api.Object do
	alias S3Analyst.Api.{Bucket, Object}

	defstruct key: nil, last_modified: nil, size: nil, storage_class: nil
	@type t :: %Object{key: String.t, last_modified: any, size: number, storage_class: String.t}

	def get_and_associate_with_bucket(%Bucket{} = bucket) do
		objects = ExAws.S3.list_objects(bucket.name)
		|> ExAws.stream!
		|> Enum.to_list
		|> Enum.map(fn object ->
			struct(Object, object)
		end)

		%{bucket | objects: objects}

	end

end