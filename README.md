# S3Analyst

**S3Analyst** is a shell command line interface (CLI) made in Elixir/Erlang for communicating with buckets through  Amazon S3 API.

It outputs a table (by default) containing some important info from buckets, and enables the possibility to order the results by any column (by passing the `--order_by` param), show sizes in a human-friendly format, and even filter the results using regular expressions - by bucket name, and some more.

This project was conceived as a challenge Rea.ch's interview. Hope you enjoy it! 

## Installation

In order to install and use this shell CLI, you should have at least **Erlang** installed on your system (**Elixir** is VERY recommended too). Install instructions for your OS can be found [here](http://elixir-lang.org/install.html).

To build the command line interface (after you clone/download this repo and make some personalizations), go to this repository folder on your machine and type:

```bash
$ mix escript.build
```

After that, you should have a compiled shell executable in your folder. You should do this everytime you make changes on your code.

## Using the CLI

To use the CLI, it's mandatory to pass two enviromnent variables to the script: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY. A quick way to do that (if you are using your development machine) is to create a `.env` file on the same folder of the repository containing the following:

```
export AWS_ACCESS_KEY_ID="<yourkey>"
export AWS_SECRET_ACCESS_KEY="<yoursecretkey>"
```
Then, all you should do is `$ source .env` on your terminal window.

After set your environment variables, go to this repo folder on your machine via terminal (if you are not there yet) and type, for example:

```bash
$ ./s3_analyst
```

You can pass some options to this script, as you can see below:

```
--limit, -l 			    Limit the total results (-1 to show all results). Default: -1
--output, -o 				Output format (table, json). Default: table
--order-by				Orders by name, total_size, total_files, region, creation_date or last_modified_date. Default: creation_date
--order 				Outputs results in ascendent (asc) or descendent (desc) order. Default: asc
--humanize, -H 				Converts the "Total Size" data into a most human readable format.
--filter, -f 				Filters the results by bucket name. You can pass regular expressions to this option. Ex: -f ^prefix
--no-cache 				Invalidates the cache and fetches fresh results from Amazon S3
--timeout, -t				Forces a request timeout value (in ms). Default: 15000
--help, -h  				Shows help.
```

## Testing

To run tests, do:
```bash
$ mix test
```

You can also pass `--trace` to benchmark testing iterations.