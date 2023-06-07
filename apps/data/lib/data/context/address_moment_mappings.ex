defmodule Data.Context.AddressMomentMappings do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.AddressMomentMapping

  @spec preload_all(AddressMomentMapping.t()) :: AddressMomentMapping.t()
  def preload_all(data), do: Repo.preload(data, [:address_component, :moment, ])

end
