#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 Travellers Connect, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.GeoLocation do
  use Noizu.SimpleObject
  @vsn 1.0
  @kind "Geo"

  Noizu.SimpleObject.noizu_struct() do
    @json {[:mobile, :verbose], :suppress_meta}
    public_field :radius
    public_field :zone
    public_field :coordinates
  end

  def approximate_metric_distance(a,b) do
    {a_lat, a_lng} = a.coordinates
    {b_lat, b_lng} = b.coordinates
    m = Enum.max(abs(a_lat - b_lat), abs(a_lng - b_lng))
    {:meters, (m / 0.0001) * 11.1}
  end


  @doc """
    @todo
    Break globe into evenly distanced neighborhoods.
    1. Plot a set of evenly distributed points across a sphere. Starting at the north pole and then placing evenly spaced points along the perimeter of the chord with the north pole at it's center points and a arc of pi/n radians.
       Followed by evenly spaced points along the perimeter of the chord with the north pole as it's center point and an arc of 2pi/n. ... until you reach npi/n arc. (the equator). After which proceed in reverse from the south pole starting at n-1pi/n radians.
       The first point on each expanding chord should be at the zero longitude.
    2. Enumerate the set of points and store there  x,y,z center points and points to define it's bounding box. (3 should be enough need to check the math to make sure a simple equivalency can be used to check the bounding cube collision).
    3. Given any lng/lat convert to point on sphere and use integer bounding boxes to find intersections.
       Proceed to use metric distance function  d = max(delta(center.x), delta(center.y), delta(center.z)) to find the nearest center point of the intersected points. (rather than cartesian distance function to avoid the more expensive sqrt operations).
       if equidistant use the center point with the lower index. The north pole being index zero and the south pole being the largest index.
    4. The index of the closest point of intersection is the zone.
    5. To expand search past the limit of the zone retrieve the set of zones whose perimeter interest target zone (some cane be removed due if their points are entirely covered by other zones.) then use an where zone in (set) query.
  """
  def zone(_lat, _lng), do: 1 # pending

  def new({lat, lng}, radius \\ 1.0) do
    lat = case lat do
            %Decimal{} -> Decimal.to_float(lat)
            v when is_float(v) -> v
            v when is_integer(v) -> 1.0 * v
            e -> e
          end
    lng = case lng do
            %Decimal{} -> Decimal.to_float(lng)
            v when is_float(v) -> v
            v when is_integer(v) -> 1.0 * v
            e -> e
          end
  
    cond do
      lat == nil -> nil
      lng == nil -> nil
      :else ->
        %Jetzy.GeoLocation{
          radius: radius,
          zone: zone(lat, lng),
          coordinates: {lat, lng}
        }
    end
  end

  def as_tuple(nil) do
    {nil, nil, nil, nil}
  end

  def as_tuple(entity) do
    case entity do
      %__MODULE__{coordinates: {latitude, longitude}, radius: radius, zone: zone} -> {latitude, longitude, zone, radius}
      %__MODULE__{coordinates: nil, radius: radius, zone: zone} -> {nil, nil, zone, radius}
    end
  end

end


defmodule Jetzy.GeoLocation.TypeHandler do
  require  Noizu.DomainObject
  Noizu.DomainObject.noizu_type_handler()
  Noizu.DomainObject.noizu_sphinx_handler()

  @default_radius 0.5

  #----------------------
  # sync
  #----------------------
  def sync(existing, update, context, options \\ nil)
  def sync(existing, nil, _context, _options), do: existing
  def sync(nil, update, _context, _options), do: update
  def sync(_existing, update, _context, _options), do: update

  #----------------------
  # sync!
  #----------------------
  def sync!(existing, update, context, options \\ nil), do: sync(existing, update, context, options)

  #----------------------
  # strip_inspect
  #----------------------
  def strip_inspect(field, nil, _opts), do: {field, nil}
  def strip_inspect(field, value = %{__struct__: Jetzy.GeoLocation}, _opts), do: {field, {:zone, value.zone, value.coordinates, value.radius}}
  def strip_inspect(field, value, opts), do: strip_inspect(field, from_partial(value, nil, nil), opts)

  #----------------------
  # from_partial
  #----------------------
  def from_partial(%{__struct__: Jetzy.GeoLocation} = v, _context, _options), do: v
  def from_partial({{lat, lng}, radius}, _context, _options), do: Jetzy.GeoLocation.new({lat, lng}, radius)
  def from_partial({lat, lng}, _context, _options), do: Jetzy.GeoLocation.new({lat, lng}, @default_radius)
  def from_partial(%{latitude: lat, longitude: lng} = value, _context, _options), do: Jetzy.GeoLocation.new({lat, lng}, value[:radius] || @default_radius)
  def from_partial(%{coordinates: {lat, lng}} = value, _context, _options), do: Jetzy.GeoLocation.new({lat, lng}, value[:radius] || @default_radius)
  def from_partial(nil, _context, _options), do: %Jetzy.GeoLocation{radius: nil, zone: 0, coordinates: nil}

  #--------------------------------------
  # pre_create_callback
  #--------------------------------------
  def pre_create_callback(field, entity, context, options), do: update_in(entity, [Access.key(field)], &(from_partial(&1, context, options)))

  #--------------------------------------
  # pre_create_callback!
  #--------------------------------------
  def pre_create_callback!(field, entity, context, options), do: update_in(entity, [Access.key(field)], &(from_partial(&1, context, options)))

  #--------------------------------------
  # pre_update_callback
  #--------------------------------------
  def pre_update_callback(field, entity, context, options), do: update_in(entity, [Access.key(field)], &(from_partial(&1, context, options)))

  #--------------------------------------
  # pre_update_callback!
  #--------------------------------------
  def pre_update_callback!(field, entity, context, options), do: update_in(entity, [Access.key(field)], &(from_partial(&1, context, options)))

  #--------------------------------------
  #
  #--------------------------------------
  def dump(field, _segment, v, _type, %{type: :ecto}, _context, _options) do
    {latitude, longitude, zone, radius} = Jetzy.GeoLocation.as_tuple(v)
    [
      {:"#{field}_zone", zone},
      {:"#{field}_radius", radius},
      {:"#{field}_latitude", latitude},
      {:"#{field}_longitude", longitude},
    ]
  end
  def dump(field, segment, v, type, layer, context, options) do
    super(field, segment, v, type, layer, context, options)
  end

  #--------------------------------------
  #
  #--------------------------------------
  def cast(field, record, _type, %{type: :ecto}, _context, _options) do
    zone_field = "#{field}_zone"
    radius_field = "#{field}_radius"
    lat_field = "#{field}_latitude"
    lng_field = "#{field}_longitude"

    zone = get_in(record, [Access.key(zone_field)])
    radius = get_in(record, [Access.key(radius_field)])
    lat = get_in(record, [Access.key(lat_field)])
    lng = get_in(record, [Access.key(lng_field)])
    geo = %Jetzy.GeoLocation{
      radius: radius,
      zone: zone,
      coordinates: (lat || lng) && {lat, lng}
    }

    [{field, geo}]
  end
  def cast(field, record, type, layer, context, options), do: super(field, record, type, layer, context, options)



  #===============================================
  # Sphinx Handler
  #===============================================

  #===------
  #
  #===------
  def __search_clauses__(_index, {field, _settings}, conn, params, _context, options) do
    search = case field do
               {p, f} -> "#{p}.#{f}"
               _ -> "#{field}"
             end

    case Noizu.AdvancedScaffolding.Helpers.extract_setting(:extract, search, conn, params, nil, options) do
      {_, nil} -> nil
      {source, v} when source in [:query_param, :body_param, :params, :default] and is_bitstring(v) ->
        v = String.trim(v)
        cond do
          Regex.match?(~r/^[0-9.]* ?(km|mi) from [0-9.]*,[0-9.]*$/, v) ->
            [_, distance, units, latitude,longitude] = Regex.run(~r/^([0-9.]*) ?(km|mi) from ([0-9.]*),([0-9.]*)$/, v)
            {lat_p,lon_p,has_c} = {String.replace("#{search}_latitude", ".", "_"), String.replace("#{search}_longitude", ".", "_"),  String.replace("#{search}_coordinates", ".", "_")}
            as_distance = String.replace("#{search}_distance", ".", "_")
            {distance,_} = Float.parse(distance)
            distance = cond do
                        units == "mi" -> distance * 0.621
                        :else -> distance
                       end
            {latitude, _} = Float.parse(latitude)
            {longitude, _} = Float.parse(longitude)
            [
              {:field, {as_distance, "SQRT(69.1*69.1*(#{lat_p} - #{latitude})*(#{lat_p} - #{latitude}) + 53*53*(#{lon_p} - #{longitude})*(#{lon_p} - #{longitude})) as #{as_distance}"}},
              {:where, {as_distance, "#{has_c} == 1 AND #{as_distance} <= #{distance}"}}
            ]
          Regex.match?(~r/^distance from [0-9.]*,[0-9.]*$/, v) ->
            [_, latitude,longitude] = Regex.run(~r/^distance from ([0-9.]*),([0-9.]*)$/, v)
            {lat_p,lon_p,has_c} = {String.replace("#{search}_latitude", ".", "_"), String.replace("#{search}_longitude", ".", "_"),  String.replace("#{search}_coordinates", ".", "_")}
            as_distance = String.replace("#{search}_distance", ".", "_")
            {latitude, _} = Float.parse(latitude)
            {longitude, _} = Float.parse(longitude)
            [
              {:field, {as_distance, "SQRT(69.1*69.1*(#{lat_p} - #{latitude})*(#{lat_p} - #{latitude}) + 53*53*(#{lon_p} - #{longitude})*(#{lon_p} - #{longitude})) as #{as_distance}"}},
              {:where, {has_c, "#{has_c} == 1"}}
            ]
          :else -> nil
        end
        :else > nil
    end
  end

  def __sphinx_field__(), do: true
  def __sphinx_expand_field__(field, indexing, _settings) do
    indexing = update_in(indexing, [:from], &(&1 || field))
    [
      {:"#{field}_zone", __MODULE__, put_in(indexing, [:sub], :zone)},
      #rather than __MODULE__ here we could use Sphinx providers like Sphinx.NullableInteger
      {:"#{field}_radius", __MODULE__, put_in(indexing, [:sub], :radius)},
      {:"#{field}_coordinates", __MODULE__, put_in(indexing, [:sub], :coordinates)},
      {:"#{field}_latitude", __MODULE__, put_in(indexing, [:sub], :latitude)},
      {:"#{field}_longitude", __MODULE__, put_in(indexing, [:sub], :longitude)},
    ]
  end
  def __sphinx_has_default__(_field, _indexing, _settings), do: true
  def __sphinx_default__(_field, indexing, _settings) do
    cond do
      indexing[:sub] == :zone -> 0
      indexing[:sub] == :radius -> 0.5
      indexing[:sub] == :coordinates -> true
      indexing[:sub] == :latitude -> 0.0
      indexing[:sub] == :longitude -> 0.0
      :else -> nil
    end
  end
  def __sphinx_bits__(_field, _indexing, _settings), do: :auto
  def __sphinx_encoding__(_field, indexing, _settings)  do
    cond do
      indexing[:sub] == :zone -> :attr_uint
      indexing[:sub] == :radius -> :attr_float
      indexing[:sub] == :coordinates -> :attr_uint
      indexing[:sub] == :latitude -> :attr_float
      indexing[:sub] == :longitude -> :attr_float
      :else -> nil
    end
  end
  def __sphinx_encoded__(_field, entity, indexing, _settings) do
    value = get_in(entity, [Access.key(indexing[:from])])

    cond do
      indexing[:sub] == :zone -> value && value.zone || 9999999
      indexing[:sub] == :radius -> value && value.radius || 0
      indexing[:sub] == :coordinates ->
        case value && value.coordinates do
          nil -> false
          {nil, _} -> false
          {_, nil} -> false
          {_lat, _lng} -> true
          _ -> false
        end

      indexing[:sub] == :latitude ->
        case value && value.coordinates do
          {v, _} -> v || 0.0
          _ -> 0.0
        end

      indexing[:sub] == :longitude ->
        case value && value.coordinates do
          {_, v} -> v || 0.0
          _ -> 0.0
        end
      :else -> nil
    end
  end
end
