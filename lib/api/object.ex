defmodule S3Analyst.Api.Object do
	alias S3Analyst.Api.Object

	@moduledoc """
	`%S3Analyst.Api.Object{}` struct.
	"""

	defstruct key: nil, last_modified: nil, size: nil, storage_class: nil
	@type t :: %Object{key: String.t, last_modified: any, size: number, storage_class: String.t}

end