defmodule Data.Context.AddressShoutoutMappings do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.AddressShoutoutMapping

  @spec preload_all(AddressShoutoutMapping.t()) :: AddressShoutoutMapping.t()
  def preload_all(data), do: Repo.preload(data, [:address_component, :shoutout, ])

  def get_by_shoutout_id(shoutout_id) do
    AddressShoutoutMapping
    |> join(:inner, [asm], ac in assoc(asm, :address_component))
    |> where([asm], asm.shoutout_id == ^shoutout_id)
    |> select([_, ac], %{
      url: ac.url,
      formatted_address: ac.formatted_address,
      place_id: ac.place_id,
      administrative_area_level_1: ac.administrative_area_level_1,
      administrative_area_level_2: ac.administrative_area_level_2,
      administrative_area_level_3: ac.administrative_area_level_3,
      administrative_area_level_4: ac.administrative_area_level_4,
      administrative_area_level_5: ac.administrative_area_level_5,
      colloquial_area: ac.colloquial_area,
      country: ac.country,
      intersection: ac.intersection,
      locality: ac.locality,
      neighborhood: ac.neighborhood,
      other: ac.other,
      premise: ac.premise,
      route: ac.route,
      street_address: ac.street_address,
      street_number: ac.street_number,
      sublocality: ac.sublocality,
      sublocality_level_1: ac.sublocality_level_1,
      sublocality_level_2: ac.sublocality_level_2,
      sublocality_level_3: ac.sublocality_level_3,
      sublocality_level_4: ac.sublocality_level_4,
      sublocality_level_5: ac.sublocality_level_5
    })
    |> Repo.one()
  end

  def delete_shoutout_address_mapings(shoutout_id) do
    AddressShoutoutMapping
    |> where([asm], asm.shoutout_id == ^shoutout_id)
    |> Repo.delete_all()
  end

end
