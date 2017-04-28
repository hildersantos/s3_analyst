defmodule S3Analyst.CLITest do
	use ExUnit.Case, async: true
	doctest S3Analyst.CLI # Tests the examples on documentation
	alias S3Analyst.CLI

	@moduletag :internal

	describe "parse_args/1" do
		test ":help returned with --help or -h" do
			assert CLI.parse_args(["--help"]) === :help
			assert CLI.parse_args(["-h"]) === :help
		end

		test ":invalid tuple returned with invalid arguments" do
			assert CLI.parse_args(["-l", "invalid"]) === {:invalid, [{"-l", "invalid"}]}
		end
	end
end