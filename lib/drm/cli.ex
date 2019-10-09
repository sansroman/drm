defmodule Drm.CLI do
  @moduledoc """
  handle the command line parsing and the dispatch to
  the various functions that end up generating a table
  of images in remote docker register.
  """
  def run(argv) do
    parse_args(argv)
  end

  @doc """
  `argv` can be -h or --help, which returns :help

    Otherwise it is a remote docker register username,
  password, and (optionally) the number of entries to
  format.

    Return a tuple of `{user, password, count}`, or
  `:help` if help was given.
  """

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    case parse do
      { [ help: true ], _, _ } -> :help
      { _, [ username, password, count ], _ } -> { username, password, count }
      { _, [ username, password ], _ } -> { username, password }
    end
  end


end
