defmodule Data.Schema.AddressComponent do
  @moduledoc """
    The schema for Address component
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        administrative_area_level_1: String.t | nil,
        administrative_area_level_2: String.t | nil,
        administrative_area_level_3: String.t | nil,
        administrative_area_level_4: String.t | nil,
        administrative_area_level_5: String.t | nil,
        api_version: String.t | nil,
        colloquial_area: String.t | nil,
        country: String.t | nil,
        formatted_address: String.t | nil,
        intersection: String.t | nil,
        is_new: boolean,
        locality: String.t | nil,
        neighborhood: String.t | nil,
        other: String.t | nil,
        place_id: String.t | nil,
        premise: String.t | nil,
        route: String.t | nil,
        street_address: String.t | nil,
        street_number: String.t | nil,
        sublocality: String.t | nil,
        sublocality_level_1: String.t | nil,
        sublocality_level_2: String.t | nil,
        sublocality_level_3: String.t | nil,
        sublocality_level_4: String.t | nil,
        sublocality_level_5: String.t | nil,
        url: String.t | nil,
        
    }

  @required_fields ~w|
    
  |a

  @optional_fields ~w|
    deleted_at
    place_id
    formatted_address
    url
    colloquial_area
    country
    intersection
    locality
    neighborhood
    premise
    route
    street_address
    street_number
    sublocality
    sublocality_level_1
    sublocality_level_2
    sublocality_level_3
    sublocality_level_4
    sublocality_level_5
    administrative_area_level_1
    administrative_area_level_2
    administrative_area_level_3
    administrative_area_level_4
    administrative_area_level_5
    other
    api_version
    is_new
    inserted_at
    updated_at
    
  |a

  @all_fields @required_fields ++ @optional_fields

  
  schema "address_components" do
    field :administrative_area_level_1, :string
    field :administrative_area_level_2, :string
    field :administrative_area_level_3, :string
    field :administrative_area_level_4, :string
    field :administrative_area_level_5, :string
    field :api_version, :string
    field :colloquial_area, :string
    field :country, :string
    field :formatted_address, :string
    field :intersection, :string
    field :is_new, :boolean
    field :locality, :string
    field :neighborhood, :string
    field :other, :string
    field :place_id, :string
    field :premise, :string
    field :route, :string
    field :street_address, :string
    field :street_number, :string
    field :sublocality, :string
    field :sublocality_level_1, :string
    field :sublocality_level_2, :string
    field :sublocality_level_3, :string
    field :sublocality_level_4, :string
    field :sublocality_level_5, :string
    field :url, :string


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 500
  use Data.Schema.TanbitsEntity, sref: "t-addr-comp"
end