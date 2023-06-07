#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Image do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "entity-image"
  @persistence_layer {:mnesia, cascade?: true, cascade_block?: true}
  @persistence_layer {:ecto, cascade?: true, cascade_block?: true}
  defmodule Entity do
    @nmid_index 88
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      @json_ignore :mobile
      identifier :uuid

      @json_ignore :mobile
      public_field :subject

      public_field :image

      @index true
      @json_ignore :mobile
      public_field :description, nil, Jetzy.VersionedString.TypeHandler

      @index true
      @json_ignore :mobile
      internal_field :status

      @index true
      @json_ignore :mobile
      public_field :locale, nil, Jetzy.Locale.TypeHandler

      @index true
      @json_ignore :mobile
      internal_field :location

      @index true
      @json_ignore :mobile
      internal_field :interactions

      @index true
      @json_ignore [:mobile]
      internal_field :moderation, nil, Jetzy.ModerationDetails.TypeHandler

      @index true
      @json_ignore :mobile
      @json_embed {:verbose_mobile, [:created_on, :modified_on]}
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end

    def image_thumb_hash(nil, _, _), do: {nil, nil, nil, nil}
    def image_thumb_hash(ref, context, options) do
     case Noizu.ERP.entity!(ref) do
       %Jetzy.Entity.Image.Entity{identifier: identifier, image: image} ->
         case Noizu.ERP.entity!(image) do
           image = %Jetzy.Image.Entity{} ->
             cond do
               image.file_format in [:png, :jpg, :gif] ->
                  full_name = "#{image.base}" |> String.trim_leading("/mnt/images/")
                  thumb_name = "#{image.base}.thumb" |> String.trim_leading("/mnt/images/")
                  blur_hash = image.blur_hash
                  {identifier, full_name, thumb_name, blur_hash}
               :else -> {nil, nil, nil, nil}
             end
           _ -> {nil, nil, nil, nil}
         end
       _ -> {nil, nil, nil, nil}
     end
    end
    
    
    
  end

  
  
  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end

    def by_path(_path, _context, _options) do
      nil
    end
  end

end
