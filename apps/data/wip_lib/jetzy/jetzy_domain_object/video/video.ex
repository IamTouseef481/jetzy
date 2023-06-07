#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Video do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "video"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  @auto_generate false

  #-------------------------------------------------
  #
  #-------------------------------------------------
  defmodule Entity do
    @nmid_index 165
    @universal_identifier true
    use Amnesia
    Noizu.DomainObject.noizu_entity do
      identifier :string
      ecto_identifier :intger

      @index true
      public_field :uploader

      @index false
      public_field :hash

      @index false
      public_field :blur_hash  # Static Screen shot

      @index false
      public_field :thumbnail  # Video.Entity

      @index false
      public_field :base

      @index false
      public_field :source

      @index true
      public_field :base_dimensions

      @index true
      public_field :external

      @index true
      public_field :video_type

      @index true
      public_field :file_format

      @index true
      public_field :moderation, nil, Jetzy.ModerationDetails.TypeHandler
      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end

    #----------------------------------------
    # __as_record_type__
    #----------------------------------------
    def __as_record_type__(%{__struct__: PersistenceLayer, schema: JetzySchema.PG.Repo} = layer, entity, context, options) do
      case record = super(layer, entity, context, options) do
        %{__struct__: JetzySchema.PG.Video.Table} ->
          %JetzySchema.PG.Video.Table{record| identifier: entity.ecto_identifier, uuid: entity.identifier}
        v -> v
      end
    end
    def __as_record_type__(layer, entity, context, options), do: super(layer, entity, context, options)

    #----------------------------------------
    # __as_record_type__!
    #----------------------------------------
    def __as_record_type__!(layer, entity, context, options \\ nil)
    def __as_record_type__!(layer, entity, context, options) do
      Amnesia.async fn ->
        __as_record_type__(layer, entity, context, options)
      end
    end


  end

  #-------------------------------------------------
  #
  #-------------------------------------------------
  defmodule Repo do
    @http_headers []
    @http_options [ssl: [{:versions, [:'tlsv1.2', :'tlsv1.1', :tlsv1]}], recv_timeout: 45_000]
    @default_blur_hash_settings %{width: 30, height: 30, x_components: 4, y_components: 3}
    @restricted_paths  ["/bin", "/sbin", "/usr/bin", "/lib", "/usr/lib", "/var/lib"]
    #@file_formats %{"jpeg" => :jpg, "jpg" => :jpg, "png" => :png, "bmp" => :bmp}
    use Amnesia
    Noizu.DomainObject.noizu_repo do

    end


    #----------------------------------------
    #
    #----------------------------------------
    def pre_create_callback(nil, _context, _options), do: nil
    def pre_create_callback(entity, context, options) do
      entity = update_in(entity, [Access.key(:ecto_identifier)], &(&1 || generate_identifier()))
      super(entity, context, options)
    end

    #----------------------------------------
    #
    #----------------------------------------
    def pre_create_callback!(nil, _context, _options), do: nil
    def pre_create_callback!(entity, context, options) do
      entity = update_in(entity, [Access.key(:ecto_identifier)], &(&1 || generate_identifier!()))
      super(entity, context, options)
    end

    #----------------------------------------
    #
    #----------------------------------------
    def valid_video_storage_path?(path) do
      cond do
        !is_bitstring(path) -> false
        String.contains?(path, "..") -> false
        String.contains?(path, "*") -> false
        true -> Enum.reduce(@restricted_paths, true, fn(f,acc) -> acc && !String.starts_with?(path, f) end)
      end
    end

    #----------------------------------------
    #
    #----------------------------------------
    def video_storage_path() do
      path = Application.get_env(:api, :cdn)[:path]
      cond do
        valid_video_storage_path?(path) -> path
        :else ->
          Logger.error(fn ->"Invalid :api[:cdn][:path] - #{inspect path}" end)
          throw "Invalid Video Folder"
      end
    end


    #-------------------------
    # video_path
    #-------------------------
    def video_path(identifier) do
      storage_path = video_storage_path()
      {sub_1, s} = String.split_at(identifier, 3)
      {sub_2, _sub_3} = String.split_at(s, 3)
      "#{storage_path}/#{sub_1}/#{sub_2}/#{identifier}"
    end

    #----------------------------------------
    #
    #----------------------------------------
    def calculate_blur_hash(video_file, options \\ %{})
    def calculate_blur_hash(nil, _options), do: nil
    def calculate_blur_hash(video_file, options) do
      width = options[:width] || @default_blur_hash_settings[:width]
      height = options[:height] || @default_blur_hash_settings[:height]
      x_components = options[:x_components] || @default_blur_hash_settings[:x_components]
      y_components = options[:y_components] || @default_blur_hash_settings[:y_components]

      Logger.info """
          video_file: #{inspect video_file}
      """
      video_file = video_file
                   |> Mogrify.format("rgb")
                   |> Mogrify.save()
      Logger.info """
          video_file.rgb: #{inspect video_file}
      """
      pixels = File.read!(video_file.path)
               |> :binary.bin_to_list()
      Logger.info """
             rgb: #{inspect pixels}
      """
      File.rm!(video_file.path)

      BlurHash.encode(pixels, width, height, x_components, y_components)
    end


    #-------------------------
    # from_uri
    #-------------------------
    def from_uri(url, _video_type, _context, _options \\ nil) do
      case HTTPoison.get(url, @http_headers, @http_options) do
        {:ok, %HTTPoison.Response{status_code: 200} = download} ->
          uuid = UUID.uuid4(:hex)
          #checksum = :crypto.hash(:md5 , download.body) |> Base.encode16() |> String.upcase()
          video_path = video_path(uuid)
          video_file = "#{video_path}/base"
          attempt_mkdir = File.mkdir_p(video_path)
          cond do
            attempt_mkdir != :ok -> {:error, {:mkdir_p, attempt_mkdir}}
            File.exists?(video_file) -> {:error, {:uuid_collision, uuid}}
            attempt_write = File.write(video_file, download.body, [:write, :binary]) ->
              outcome = cond do
                          attempt_write == :ok ->
                            throw :NYI
                          :else -> {:error, {:write, attempt_write}}
                        end
              outcome
            :else -> {:error, {:write, :error}}
          end
        error -> {:error, {:download, error}}
      end
    end
  end
end
