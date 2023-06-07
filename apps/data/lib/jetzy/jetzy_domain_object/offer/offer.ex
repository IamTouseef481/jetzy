#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Offer do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "offer"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  @persistence_layer {Data.Repo, Data.Schema.RewardOffer, [cascade?: true, sync: false, fallback?: false, cascade_block?: true]}
  @persistence_layer {JetzySchema.MSSQL.Repo,  [sync: false, fallback?: false]}
  # @index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]}
  defmodule Entity do
    @nmid_index 307
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      public_field :qty
      public_field :points

      public_field :tier
      public_field :redeem_type

      public_field :activity_type
      public_field :active_from, nil, Noizu.DomainObject.DateTime.Second.TypeHandler
      public_field :active_until, nil, Noizu.DomainObject.DateTime.Second.TypeHandler

      public_field :description, nil, Jetzy.VersionedString.TypeHandler
      public_field :details, nil, Jetzy.CMS.Article.Post.TypeHandler


      public_field :status
      public_field :location, nil, Jetzy.VersionedAddress.TypeHandler

      public_field :geo, nil, Jetzy.GeoLocation.TypeHandler

      public_field :image, nil, Jetzy.Entity.Image.TypeHandler
      public_field :pinned
      public_field :pin_date, nil, Noizu.DomainObject.DateTime.Second.TypeHandler

      public_field :link, nil, Jetzy.VersionedLink.TypeHandler

      public_field :ticket_price

      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end


    #----------------------------
    # __from_record__
    #----------------------------
    def __from_record__(layer, record, context, options \\ nil)
    def __from_record__(%{__struct__: PersistenceLayer, schema: JetzySchema.MSSQL.Repo} = _layer, %{__struct__: JetzySchema.MSSQL.Reward.Offer.Table} = record, context, options) do
      # Existing
      existing = cond do
                   options[:existing] == false -> nil
                   options[:existing] -> options[:existing]
                   existing = Jetzy.LegacyResolution.Repo.by_legacy_guid!(JetzySchema.MSSQL.Reward.Offer.Table, record.id, context, options) -> existing
                   :else -> nil
                 end

      # Basic Fields
      #now = options[:current_time] || DateTime.utc_now()
      time_stamp = JetzySchema.MSSQL.Reward.Offer.Table.time_stamp(record, context, options)
      geo = Jetzy.GeoLocation.new({record.latitude && Decimal.to_float(record.latitude), record.longitude && Decimal.to_float(record.longitude)}, 0.1)
      location = with true <- is_bitstring(record.location) && String.length(record.location) > 0,
                      {:ok, google_place} <- Jetzy.Location.Place.Repo.by_address_string!(record.location, {record.latitude && Decimal.to_float(record.latitude), record.longitude && Decimal.to_float(record.longitude)}, context, options) do
                   case Jetzy.Location.Place.Repo.by_place_key(google_place["place_id"], context, options) do
                     {:ok, place} -> place.address
                     _ ->
                       place = Jetzy.Location.Place.Entity.new({:google_place, google_place}, context, options)
                       place = place && Jetzy.Location.Place.Repo.create!(place, context, options)
                       place && place.address
                   end
                 end

      tier = Jetzy.Reward.Tier.Repo.by_legacy!(record.tier_id, context, options)
      redeem_type = record.multi_redeem_allowed && :multi_redeem || :standard
      link = record.link && %Jetzy.VersionedLink.Entity{link: record.link}

      # Description
      description = Jetzy.VersionedString.Entity.new(record.offer_name, record.offer_description)
      description = Jetzy.VersionedString.TypeHandler.sync(existing && existing.description, description, context, options)

      # Details & Media
      media = JetzySchema.MSSQL.Reward.Offer.Table.offer_images(record.id, context, options)
              |> Enum.map(fn(i) ->
                  image = cond do
                            i.image && String.ends_with?(i.image, ".png") -> i.image
                            i.image && String.ends_with?(i.image, ".jpg") -> i.image
                            i.image && String.ends_with?(i.image, ".gif") -> i.image
                            i.image -> i.image <> ".jpg"
                            :else -> nil
                          end
                  url = i.image && "https://api.jetzyapp.com/Images/OfferImage/#{i.image}"
                  url && {:image, {:import, {:offer_image, url}}}
              end) |> Enum.filter(&(&1))
      details = Jetzy.CMS.Article.Post.TypeHandler.sync(
        existing && existing.details,
        %{
          title: record.offer_name,
          body: record.offer_description,
          media: media,
          editor: nil,
          time_stamp: time_stamp
        },
        context,
        options
      )

      # Main Image
      url = record.image_name && "https://api.jetzyapp.com/Images/OfferImage/#{record.image_name}"
      url = cond do
                url && String.ends_with?(url, ".png") -> url
                url && String.ends_with?(url, ".jpg") -> url
                url && String.ends_with?(url, ".gif") -> url
                url -> url <> ".jpg"
                :else -> nil
              end
      primary_image = record.image_name && {:image, {:import, {:offer_image, url}}}

      %Jetzy.Offer.Entity{
        qty: 100_000_000,
        points: record.points_required,
        tier: tier,
        activity_type: :none,
        redeem_type: redeem_type,
        active_from: record.event_start_date,
        active_until: record.event_end_date,
        description: description,
        details: details,
        status: record.deleted && :inactive || :active,
        location: location,
        geo: geo,
        image: primary_image,
        pinned: record.pinned,
        pin_date: record.pinned_date,
        link: link,
        ticket_price: record.price_of_ticket && Decimal.to_float(record.price_of_ticket),
        time_stamp: time_stamp
      }
    end
    def __from_record__(layer, record, context, options) do
      super(layer, record, context, options)
    end


    #===-------
    # has_permission?
    #===-------
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true


  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end

    #----------------------------
    # layer_create
    #----------------------------
    def layer_create(%{__struct__: PersistenceLayer, schema: Data.Repo} = layer, entity, context, options) do
      layer_create!(layer, entity, context, options)
    end
    def layer_create(layer, entity, context, options) do
      super(layer, entity, context, options)
    end


    #----------------------------
    # layer_create
    #----------------------------
    def layer_create!(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do

      # Image
      {image_identifier, image_name,thumb_name, blur_hash} = Jetzy.Entity.Image.Entity.image_thumb_hash(entity.image, context, options)

      # Geo
      {latitude, longitude} = case entity.geo && entity.geo.coordinates do
                                v = {_, _} -> v
                                _ -> {nil, nil}
                              end

      # Link
      link = Jetzy.VersionedLink.Entity.entity!(entity.link)
      link = link && link.link

      # Location
      location = Jetzy.VersionedAddress.Entity.entity!(entity.location)
      location = location && location.address_line_one

      # Text
      {name, description} = Jetzy.VersionedString.Entity.entity!(entity.description)
                            |> case do
                                 %{title: title, body: body} -> {title && title.markdown, body && body.markdown}
                                 _ -> {nil, nil}
                               end
      # tier
      tier_id = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.RewardTier, Noizu.ERP.ref(entity.tier), context, options) |> Noizu.ERP.id

      # status
      status_id = case Data.Schema.Status.by_atom(entity.status) do
                    v = %Data.Schema.Status{} -> v.id
                    _ -> nil
                  end

      record = %Data.Schema.RewardOffer{
        event_end_date: entity.active_until && DateTime.to_date(entity.active_until),
        event_start_date: entity.active_from && DateTime.to_date(entity.active_from),
        image_identifier: image_identifier,
        image_name: image_name,
        small_image_name: thumb_name,
        blur_hash: blur_hash,

        is_deleted: entity.time_stamp.deleted_on && true || false,
        is_pinned: entity.pinned,
        pin_date: entity.pin_date && DateTime.to_date(entity.pin_date),
        latitude: latitude,
        longitude: longitude,
        link: link,
        location: location,
        multi_redeem_allowed: entity.redeem_type == :multi_redeem,

        offer_name: name,
        offer_description: description,

        point_required: entity.points,
        price_of_ticket: entity.ticket_price,
        tier_id: tier_id,
        status_id: status_id
      }
      {:ok, record} = Data.Repo.upsert(record)

      # Insert Guid for lookup.
      Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.RewardOffer, record.id, context, options)

      # RewardImages
      (with %{media: %{entities: entities}} <- Noizu.ERP.entity!(entity.details),
            true <- is_list(entities) && length(entities) > 0
         do
         Enum.map(entities, fn(h) ->
           existing_uei = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.RewardImage, Noizu.ERP.ref(h), context, options) |> Noizu.ERP.entity!()
           {image_identifier, image_name, thumb_name, blur_hash} = Jetzy.Entity.Image.Entity.image_thumb_hash(h, context, options)
           if (image_name) do
             insert = %{
               image: image_name,
               image_identifier: image_identifier,
               small_image_name: thumb_name,
               blur_hash: blur_hash,
               reward_offer_id: record.id,
             }
             cond do
               existing_uei ->
                 Data.Context.update(Data.Schema.RewardImage, existing_uei, insert)
               :else ->
                 with {:ok, uei} <- Data.Context.create(Data.Schema.RewardImage, insert) do
                   Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(h), Data.Schema.RewardImage, uei.id, context, options)
                 end
             end
           end
         end)
       else
         _ -> nil
       end)

      entity
    end
    def layer_create!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end


    def by_legacy!(identifier, context, options) do
      cond do
        existing = Jetzy.LegacyResolution.Repo.by_legacy_guid!(JetzySchema.MSSQL.Reward.Offer.Table, identifier, context, options) -> existing
        :else -> import!(identifier, context, options)
      end
    end


    def import!(identifier, context, options) when is_bitstring(identifier) do
      record = JetzySchema.MSSQL.Repo.get(JetzySchema.MSSQL.Reward.Offer.Table, identifier)
      record && import!(record, context, options)
    end
    def import!(%JetzySchema.MSSQL.Reward.Offer.Table{} = record, context, options) do
      existing = Jetzy.LegacyResolution.Repo.by_legacy_guid!(JetzySchema.MSSQL.Reward.Offer.Table, record.id, context, options)
      options_b = (options || [])
                  |> put_in([:existing], existing || false)
                  |> put_in([:auto], true)
      cond do
        existing -> {:error, {:sync, :nyi}}
        offer = Jetzy.Offer.Entity.__from_record__(Jetzy.Offer.Repo.__persistence__().schemas[JetzySchema.MSSQL.Repo], record, context, options_b) ->
          offer = Jetzy.Offer.Repo.create!(offer, context, options)
          Jetzy.LegacyResolution.Repo.insert_guid!(Noizu.ERP.ref(offer), JetzySchema.MSSQL.Reward.Offer.Table, record.id, context, options)
          offer
        :else -> nil
      end
    end


    #===-------
    # has_permission?
    #===-------
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

  end
end
