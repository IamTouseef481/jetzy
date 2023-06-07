defmodule Data.SQL.Repo do
  use Ecto.Repo,
    otp_app: :data,
    adapter: Ecto.Adapters.Tds

    
    
    
    
    
  defp build_opts(opts) do
    system_opts = [
      username: Application.get_env(:data, JetzySchema.MSSQL.Repo)[:username],
      password: Application.get_env(:data, JetzySchema.MSSQL.Repo)[:password],
      database: Application.get_env(:data, JetzySchema.MSSQL.Repo)[:database],
      hostname: Application.get_env(:data, JetzySchema.MSSQL.Repo)[:hostname],
      port: 1433,
      timeout: 1000000,
      show_sensitive_data_on_connection_error: false
    ]

    Keyword.merge(opts, system_opts)
  end

  #----------------------------
  #
  #----------------------------
  def init(_, opts) do
    {:ok, build_opts(opts)}
  end
end
