defmodule Hubspot.HTTP.Client do
  use HTTPoison.Base

  import Application, only: [get_env: 2]

  @doc """
  Issues an HTTP request with the given method to the given url.

  Args:
    * `method` - HTTP method as an atom (`:get`, `:head`, `:post`, `:put`,
      `:delete`, etc.)
    * `url` - target url as a binary string or char list
    * `body` - request body. See more below
    * `headers` - HTTP headers as an orddict (e.g., `[{"Accept", "application/json"}]`)
    * `options` - Keyword list of options

  Body:
    * binary, char list or an iolist
    * `{:form, [{K, V}, ...]}` - send a form url encoded
    * `{:file, "/path/to/file"}` - send a file

  ## Examples
          request(:post, "https://my.website.com", "{\"foo\": 3}", [{"Accept", "application/json"}])
  """
  def request(method, url, body \\ "", headers \\ [], params \\ []) do
    options = params |> add_auth |> process_request_options
    super(method, url, body, headers, options)
  end

  defp add_auth(query) do
    [{get_env(:hubspotex, :auth_method), get_env(:hubspotex, :auth_key)} | query]
  end

  defp process_url(url = "http" <> _), do: url
  defp process_url(endpoint) do
    get_env(:hubspotex, :base_url) <> endpoint
  end

  defp process_request_options([]), do: []
  defp process_request_options([params: _]=options), do: options
  defp process_request_options(params) do
    [params: params]
  end

  defp process_request_body(""), do: ""
  defp process_request_body(body) do
    body |> Jason.encode!
  end

  defp process_response_body(""), do: nil
  defp process_response_body(body) do
    body |> Jason.decode!
  end
end
