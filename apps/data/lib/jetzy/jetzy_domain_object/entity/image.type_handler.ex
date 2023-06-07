#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Image.TypeHandler do
  require  Noizu.DomainObject
  require Logger
  use Amnesia
  Noizu.DomainObject.noizu_type_handler()


  def refetch(image_type = :profile_image, user, record, context, options) do
    uri = JetzySchema.MSSQL.User.Table.profile_image(record, context, options)
    with profile_image <- user.profile_image |> Noizu.ERP.entity!(),
         image = %Jetzy.Image.Entity{} <- uri && Jetzy.Image.Repo.refetch(uri, image_type, profile_image, context, options) do
      cond do
        profile_image ->
          %Jetzy.Entity.Image.Entity{profile_image| image: image}
          |> Jetzy.Entity.Image.Repo.update!(context)
        :else ->
          %Jetzy.Entity.Image.Entity{
            subject: Noizu.ERP.ref(user),
            image: image,
            description: %{title: options[:title] || "System Generated"},
            status: :none,
            locale: %Jetzy.Locale{},
            location: nil,
            moderation: %Jetzy.ModerationDetails{},
            time_stamp: Noizu.DomainObject.TimeStamp.Second.now(options)
          } |> Jetzy.Entity.Image.Repo.create!(context)
      end
    else
      error -> :user_missing_profile_image
    end
  end

  def fetch_image(image_type, uri, context, options) do
    case Jetzy.Image.Repo.from_uri(uri, image_type, context, options) do
      image = %{__struct__: Jetzy.Image.Entity} -> {:ok, image}
      error ->
        Logger.error("Unable to download image: #{inspect error}")
        error
    end
  end

  def import_legacy_image(image, entity, _context, options) do
    %Jetzy.Entity.Image.Entity{
      subject: Noizu.ERP.ref(entity),
      image: image,
      description: %{title: options[:title] || "System Generated"},
      status: :none,
      locale: %Jetzy.Locale{},
      location: nil,
      moderation: %Jetzy.ModerationDetails{},
      time_stamp: Noizu.DomainObject.TimeStamp.Second.now(options)
    }
  end

  def from_partial!(partial, context, options) do
    Amnesia.async fn ->
      from_partial(partial, context, options)
    end
  end

  def from_partial(%{__struct__: Jetzy.Entity.Image.Entity} = v, _context, _options), do: v
  def from_partial({:ref, Jetzy.Entity.Image.Entity, _} = v, _context, _options), do: v
  def from_partial(%{__struct__: Jetzy.Image.Entity} = v, context, options) do
    entity = options[:subject]
    import_legacy_image(v, entity, context, options[:import_image])
  end
  def from_partial({:ref, Jetzy.Image.Entity, _} = v, context, options) do
    entity = options[:subject]
    cond do
      image = Jetzy.Image.Entity.entity(v)->
        import_legacy_image(image, entity, context, options[:import_image])
      :else -> nil
    end
  end
  def from_partial({:import, {image_type, uri}}, context, options) when is_bitstring(uri) do
    entity = options[:subject]
    case fetch_image(image_type, uri, context, options) do
      {:ok, image} ->
        cond do
          new_image = Jetzy.Image.Repo.create(image, Noizu.ElixirCore.CallingContext.system(context), cascade_block?: true) ->
            import_legacy_image(new_image, entity, context, options[:import_image])
          :else -> {:error, :create}
        end
      error -> nil
    end
  end
  def from_partial({:image, {:import, {image_type, uri}}}, context, options) when is_bitstring(uri) do
    entity = options[:subject]
    case fetch_image(image_type, uri, context, options) do
      {:ok, image} ->
        cond do
          new_image = Jetzy.Image.Repo.create(image, Noizu.ElixirCore.CallingContext.system(context), cascade_block?: true) ->
            import_legacy_image(new_image, entity, context, options[:import_image])
          :else -> {:error, :create}
        end
      error -> nil
    end
  end
  def from_partial({:existing, {image_type, ref}}, context, options) do
    entity = options[:subject]
    ref && import_legacy_image(ref, entity, context, options[:import_image])
  end
  def from_partial(_, _context, _options), do: nil


  def pre_create_callback(field, entity, context, options) do
    update_in(
      entity,
      [Access.key(field)],
      fn (v) ->
        options_b = put_in(options || [], [:subject], entity)
        case from_partial(v, context, options_b) do
          e = %{__struct__: Jetzy.Entity.Image.Entity, identifier: nil} ->
            Jetzy.Entity.Image.Repo.create(e, Noizu.ElixirCore.CallingContext.system(context), cascade_block?: true)
            error = {:error, _} ->
              sid = Noizu.EctoEntity.Protocol.ecto_identifier(entity)
              so = Noizu.EctoEntity.Protocol.source(entity)
              error_template = %Jetzy.Import.Error.Entity{
                status: :active,
                import_error_type: :image_upload,
                error_message: %{title: "Import Error", body: "#{inspect v}: #{inspect error}"},
                source: so,
                source_identifier: sid,
                import_error_section: field,
                time_stamp: Noizu.DomainObject.TimeStamp.Second.new(DateTime.utc_now()),
              }
              nil
          v -> v
        end
      end
    )
  end

  def pre_create_callback!(field, entity, context, options) do
    Amnesia.async fn ->
      pre_create_callback(field, entity, context, options)
    end
  end

  def dump(field, _segment, nil, _type, %{schema: JetzySchema.PG.Repo}, _context, _options), do: {field, nil}
  def dump(field, _segment, nil, _type, %{schema: JetzySchema.Database}, _context, _options), do: {field, nil}
  def dump(field, _segment, v, _type, %{schema: JetzySchema.PG.Repo}, _context, _options), do: {field, Noizu.ERP.ref(v)}
  def dump(field, _segment, v, _type, %{schema: JetzySchema.Database}, _context, _options), do: {field, Noizu.ERP.ref(v)}
  def dump(field, segment, value, type, layer, context, options), do: super(field, segment, value, type, layer, context, options)



  #--------------------------------------
  #
  #--------------------------------------
  def from_json(_format, _field, _json, _context, _options) do
    # pending
    nil
  end

  def to_json(:mobile, as, value, _settings, _context, _options) do
    cond do
      image = value && value.image && Jetzy.Image.Entity.entity!(value.image) ->
        {as, %{image: Jetzy.Image.Entity.sref(value.image), blur_hash: image.blur_hash}}
      :else -> {as, value}
    end
  end

  def to_json(format, as, value, settings, context, options) do
    super(format, as, value, settings, context, options)
  end

end
