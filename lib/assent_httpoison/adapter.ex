defmodule AssentHTTPoison.Adapter do
  @moduledoc """
  HTTP adapter module for making http requests with HTTPoison.

  HTTPoison can be configured by updating the configuration:

      http_adapter: {Assent.HTTPAdapter.HTTPoison, [...]}

  See `Assent.HTTPAdapter` for more.
  """
  alias Assent.HTTPAdapter
  alias Assent.HTTPAdapter.HTTPResponse

  @behaviour HTTPAdapter

  @impl HTTPAdapter
  def request(method, url, body, headers, opts \\ []) do
    body = body || ""

    method
    |> HTTPoison.request(url, body, headers, opts)
    |> handle_response()
  end

  defp handle_response({:ok, %HTTPoison.Response{} = response}) do
    {:ok,
     %HTTPResponse{
       body: response.body,
       headers: format_headers(response.headers),
       status: response.status_code
     }}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end

  defp format_headers(headers) do
    Enum.map(headers, fn {k, v} -> {String.downcase(k), v} end)
  end
end
