#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.VersionedAddress do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "v-address"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}

  #=======================================================================================
  # Entity
  #=======================================================================================
  defmodule Entity do
    @nmid_index 149
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      @json_ignore [:mobile, :verbose_mobile]
      public_field :editor

      @json_ignore [:mobile]
      public_field :revision, 0

      public_field :url
      public_field :icon

      public_field :name
      public_field :official_name
      public_field :description
      public_field :note

      public_field :address_type
      public_field :address_line_one
      public_field :address_line_two
      public_field :intersection
      public_field :postal_code

      public_field :address_country, nil, Jetzy.Location.Country.TypeHandler
      public_field :address_state, nil, Jetzy.Location.State.TypeHandler
      public_field :address_city, nil, Jetzy.Location.City.TypeHandler

      public_field :geo, nil, Jetzy.GeoLocation.TypeHandler

      @json_ignore [:mobile]
      internal_field :moderation, nil, type: Jetzy.ModerationDetails.TypeHandler

      @json_ignore [:mobile]
      public_field :modified_on, nil, type:  Noizu.DomainObject.DateTime.Millisecond.TypeHandler
    end

    def city_state_country(ref, context, options) do
      case Noizu.ERP.entity!(ref) do
        this = %__MODULE__{} ->
          city = Noizu.ERP.entity!(this.address_city)
          state = Noizu.ERP.entity!(this.address_state)
          country = Noizu.ERP.entity!(this.address_country)
          {city && city.name, state && state.name, country && country.name}
        _ -> {nil, nil, nil}
      end
    end


    def extract_address_component(:postal_code, google_place) do
      m = Enum.find(google_place["address_components"], fn(p) -> (p["types"] == ["postal_code"]) end)
      m && m["long_name"]
    end

    def extract_address_component(:city, google_place) do
      m = Enum.find(google_place["address_components"], fn(p) -> (p["types"] == ["locality", "political"]) end)
      m && m["long_name"]
    end
    def extract_address_component(:state, google_place) do
      m = Enum.find(google_place["address_components"], fn(p) -> (p["types"] == ["administrative_area_level_1", "political"]) end)
      m && m["long_name"]
    end
    def extract_address_component(:country, google_place) do
      m = Enum.find(google_place["address_components"], fn(p) -> (p["types"] == ["country", "political"]) end)
      m && m["long_name"]
    end

    def new({:google_place, google_place}, context, options) do
      country = extract_address_component(:country, google_place)
      country = country && Jetzy.Location.Country.Repo.by_name(country, context, options)
      state = extract_address_component(:state, google_place)
      state = country && state && Jetzy.Location.State.Repo.by_name(state, country, context, options)
      city = extract_address_component(:city, google_place)
      city = city && country && state && Jetzy.Location.City.Repo.by_name(city, state, country, context, options)

      zone = 0
      radius = 0.1
      lat = google_place["geometry"]["location"]["lat"]
      lng = google_place["geometry"]["location"]["lng"]
      geo = %Jetzy.GeoLocation{
        radius: radius,
        zone: zone,
        coordinates: (lat || lng) && {lat, lng}
      }

      %__MODULE__{
        url: google_place["url"],
        icon: google_place["icon"],
        name: google_place["formatted_address"],
        official_name: google_place["formatted_address"],
        address_type: :auto,
        address_line_one: google_place["formatted_address"],
        postal_code: extract_address_component(:postal_code, google_place),
        address_country: country,
        address_state: state,
        address_city: city,
        geo: geo,
        modified_on: DateTime.utc_now()
      }
    end
  end


  #=======================================================================================
  # Repo
  #=======================================================================================
  defmodule Repo do
    @source_field :versioned_address
    use Jetzy.VersionedStringBehavior.Repo


  end

end
