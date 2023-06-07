defmodule JetzyModule.SearchConfigurationModule do
  
  
  def is_local_radius(), do: Application.get_env(:data, :search_configuration)[:is_local_radius]
  
end