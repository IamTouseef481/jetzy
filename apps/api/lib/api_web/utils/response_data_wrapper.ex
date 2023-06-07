defmodule ApiWeb.Utils.ResponseDataWrapper do

  @spec encode_to_iodata!(data :: term()) :: iodata() | no_return()
  def encode_to_iodata!(data) do
    data
    |> Casex.to_camel_case()
    |> add_response_data_wrapper()
    |> Poison.encode_to_iodata!()
  end

  defp add_response_data_wrapper(data) do
    if is_map(data) and Map.has_key?(data, "errors") do
      %{ResponseData: nil,
        error: data["errors"]
      }
      else
      %{ResponseData: data}
    end

  end
end
