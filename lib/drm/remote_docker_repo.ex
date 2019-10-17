defmodule Drm.RemoteDockerRepo do
  require Logger

  @remote_host Application.get_env(:drm, :remote_host)
  @remote_port Application.get_env(:drm, :remote_port)

  @username "docker"
  @password "devmodao"
  @base_url "https://#{@username}:#{@password}@#{@remote_host}:#{@remote_port}/v2"

  def fetch_images do
    Logger.info("Fetching images")

    images_url()
    |> HTTPoison.get
    |> handle_response_body
  end

  def fetch_tags({image, limit}) do
    Logger.info("Fetching tags")

    tags_url({image, limit})
    |> HTTPoison.get
    |> handle_response_body
  end


  def images_url do
    "#{@base_url}/_catalog"
  end

  def tags_url({image, limit}) do
    "#{@base_url}/#{image}/tags/list?n=#{limit}"
  end

  def delete_image({image, tag}) do
    digest = "#{@base_url}/#{image}/manifests/#{tag}"
      |> HTTPoison.head(["Accept": "application/vnd.docker.distribution.manifest.v2+json"])
      |> handle_response_headers
      |> Enum.at(2)
      |> elem(1)
    Logger.info("image digest: #{digest}")

    "#{@base_url}/#{image}/manifests/#{digest}"
      |> HTTPoison.delete
      |> handle_response_headers
  end

  def handle_response_body({:ok, %{status_code: status_code, body: body}}) do
    Logger.info("Got response: status code:#{status_code}")
    {
      status_code |> check_for_error(),
      body        |> Poison.Parser.parse!(%{keys: :atoms}),
    }
  end

  def handle_response_headers({:ok, %{status_code: 202}}) do
    Logger.info("Delete image successful")
  end

  def handle_response_headers({:ok, %{status_code: 200, headers: headers}}) do headers end

  def handle_response_headers({:ok, %{status_code: status_code}}) do
    Logger.info("Got response: status code:#{status_code}")

    System.halt(2)
  end


  defp check_for_error(200) do :ok    end
  defp check_for_error(_)   do :error end
end
