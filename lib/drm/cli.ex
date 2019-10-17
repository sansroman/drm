defmodule Drm.CLI do
  @default_tags_count "100"
  @moduledoc """
  handle the command line parsing and the dispatch to
  the various functions that end up generating a table
  of images in remote docker register.
  """
  def main(argv) do
    argv
    |> parse_args
    |> process
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
    OptionParser.parse(
      argv,
      switches: [
        help: :boolean,
        version: :boolean
      ],
      aliases: [
        h: :help,
        v: :version
      ]
    )
    |> parsed_to_internal_representation
  end

  def process(%{command: :help}) do
    IO.puts """
    usage: drm [--help] [--version] <command> [args]
    """

    System.halt(0)
  end

  def process(%{command: :version}) do
    IO.puts Application.spec(:drm, :vsn)

    System.halt(0)
  end

  def process(%{command: :images}) do
    Drm.RemoteDockerRepo.fetch_images
    |> decode_response
    |> Map.fetch!(:repositories)
    |> print_formatted_list
  end

  def process(%{command: :tags, params: [image]}) do
    process(%{command: :tags, params: [image, @default_tags_count]})
  end

  def process(%{command: :tags, params: [image, limit]}) do
    Drm.RemoteDockerRepo.fetch_tags({image, limit})
    |> decode_response
    |> Map.fetch!(:tags)
    |> sort_tags
    |> Enum.take(String.to_integer(limit))
    |> print_formatted_list
  end

  def process(%{command: :rmi, params: [image, tag]}) do
    Drm.RemoteDockerRepo.delete_image({image, tag})
  end

  def process(%{command: command}) do
    IO.puts "drm: #{command} is not a drm command or need argument. See 'drm --help'"

    System.halt(2)
  end

  def process(%{command: command, params: params}) do
    IO.puts """
      fatal: ambiguous argument #{params} with command: #{command}
      See 'drm --help'
    """

    System.halt(2)
  end

  def parsed_to_internal_representation({parsed, args, _}) do
    first_flag = Enum.find(parsed, fn x -> elem(x, 1) end)
    case {first_flag, args} do
      {nil, []} ->
        %{command: :help}
      {nil, [head | []]} ->
        %{command: String.to_atom(head)}
      {nil, [head | tail]} ->
        %{command: String.to_atom(head), params: tail}
      {{flag_command, true}, _} ->
        %{command: flag_command}
    end
  end

  def decode_response({:ok, body}) do body end
  def decode_response({:error, error}) do
    IO.puts "Error fetching from Remote Docker Repo: #{error["message"]}"
    System.halt(2)
  end

  def sort_tags(list_of_tags) do
    list_of_tags
    |> Enum.sort(fn i1, i2 -> i1 > i2 end)
  end

  def print_formatted_list(source_list) do
    source_list
    |> Enum.join("\n")
    |> IO.puts
  end
end
