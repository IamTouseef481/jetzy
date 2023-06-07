defmodule JetzyApi.V2_0.Media.Image.Upload.View do
  use JetzyApi, :view
  def render(_view, %{response: response} = _conn), do: response
end
