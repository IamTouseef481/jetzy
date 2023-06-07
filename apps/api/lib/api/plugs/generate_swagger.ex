defmodule Api.Plugs.GenerateSwagger do
  @moduledoc """
  Generate Swagger Plug
  """
  @behaviour Plug

  def init(default), do: default

  def call(conn, _) do
    if "docs/rebuild" in conn.path_info, do: Mix.Task.run("phx.swagger.generate")
    conn
  end
end
