#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Image do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "image"
  @persistence_layer {:mnesia, cascade?: true, cascade_block?: true}
  @persistence_layer {:ecto, cascade?: true, cascade_block?: true}
  @auto_generate false

  #-------------------------------------------------
  #
  #-------------------------------------------------
  defmodule Entity do
    @nmid_index 94
    @universal_identifier true
    use Amnesia
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      @index true
      @json_ignore [:mobile, :verbose_mobile]
      public_field :uploader

      @index false
      @json_ignore [:mobile, :verbose_mobile]
      public_field :hash

      @index false
      public_field :blur_hash

      @index false
      @json_ignore [:mobile, :verbose_mobile]
      public_field :base

      @index false
      @json_ignore [:mobile, :verbose_mobile]
      public_field :source

      @index true
      @json_ignore :mobile
      public_field :base_dimensions

      @index true
      @json_ignore [:mobile, :verbose_mobile]
      public_field :external

      @index true
      public_field :image_type

      @index true
      public_field :file_format

      @index true
      @json_ignore :mobile
      public_field :moderation, nil, Jetzy.ModerationDetails.TypeHandler

      @index true
      @json_ignore :mobile
      @json_embed {:verbose_mobile, [:created_on, :modified_on]}
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end

    #----------------------------------------
    # __as_record_type__
    #----------------------------------------
    def __as_record_type__(%{__struct__: PersistenceLayer, schema: JetzySchema.PG.Repo} = layer, entity, context, options) do
      case record = super(layer, entity, context, options) do
        %{__struct__: JetzySchema.PG.Image.Table} ->
          %JetzySchema.PG.Image.Table{record| identifier: entity.ecto_identifier, uuid: entity.identifier}
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
    
    def populate_thumb(%__MODULE__{} = this, context, options \\ []) do
      thumb_path = this.base <> ".thumb"
      if !File.exists?(thumb_path) do
        mogrify = Mogrify.open(this.base)
                  |> Mogrify.verbose()
                  |> Mogrify.resize_to_limit("100x100")
                  |> Mogrify.save(path: thumb_path)
        :saved
      else
        :exists
      end
    end
    
    def update_blur_hash(this, context, options \\ []) do
      if !File.exists?(this.base) do
        image_file = Mogrify.open(this.base)
                     |> Mogrify.verbose()
        if new_hash = Jetzy.Image.Repo.calculate_blur_hash(image_file, options) do
          %{this| blur_hash: new_hash}
          |> Jetzy.Image.Repo.update!(context)
          :saved
        else
          :error
        end
      else
        :missing_image
      end
    end
  end

  #-------------------------------------------------
  #
  #-------------------------------------------------
  defmodule Repo do
    @http_headers []
    @max_image_size 1024*1024*10
    @max_raw_image_size 1024*1024*25
    @http_options [ssl: [{:versions, [:'tlsv1.2', :'tlsv1.1', :tlsv1]}], recv_timeout: 45_000, max_file_size: @max_image_size]
    @default_blur_hash_settings %{width: 64, height: 64, x_components: 6, y_components: 6}
    @restricted_paths  ["/bin", "/sbin", "/usr/bin", "/lib", "/usr/lib", "/var/lib"]
    @file_formats %{"jpeg" => :jpg, "jpg" => :jpg, "png" => :png, "bmp" => :bmp}
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
    def valid_image_storage_path?(path) do
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
    def image_storage_path() do
      path = Application.get_env(:api, :cdn)[:path]
      cond do
        valid_image_storage_path?(path) -> path
        :else ->
          Logger.error(fn ->"Invalid :api[:cdn][:path] - #{inspect path}" end)
          throw "Invalid Image Folder"
      end
    end


    #-------------------------
    # image_path
    #-------------------------
    def image_path(identifier) do
      storage_path = image_storage_path()
      {sub_1, s} = String.split_at(identifier, 3)
      {sub_2, _sub_3} = String.split_at(s, 3)
      "#{storage_path}/#{sub_1}/#{sub_2}/#{identifier}"
    end

    def image_path(image_type, identifier) do
      storage_path = image_storage_path()
      {sub_1, s} = String.split_at(identifier, 3)
      {sub_2, _sub_3} = String.split_at(s, 3)
      "#{storage_path}/#{image_type}/#{sub_1}/#{sub_2}/#{identifier}"
    end



    #----------------------------------------
    #
    #----------------------------------------
    def calculate_blur_hash(image_file, options \\ %{})
    def calculate_blur_hash(nil, _options), do: nil
    def calculate_blur_hash(image_file, options) do
      # Blurhash Argument causes an uncatchable process kill
      self = self()
      {pid, monitor} = spawn_monitor(fn ->
        calculate_blur_hash_inner(self, image_file, options)
      end)
      receive do
        {:DOWN, ^monitor, :process, ^pid, :normal} ->
        receive do
          {:calculate_blur_hash, response} -> response
        end
        {:DOWN, ^monitor, :process, ^pid, _reason} -> nil
      end
    end

    def calculate_blur_hash_inner(pid, for_image_file, options) do
      width = options[:width] || @default_blur_hash_settings[:width]
      height = options[:height] || @default_blur_hash_settings[:height]
      x_components = options[:x_components] || @default_blur_hash_settings[:x_components]
      y_components = options[:y_components] || @default_blur_hash_settings[:y_components]

      image_file2 = for_image_file
                   |> Mogrify.resize_to_limit("1080x1080")
                   |> Mogrify.save()

      image_file = Mogrify.open(image_file2.path)
                   |> Mogrify.verbose()
                   |> Mogrify.format("rgb")
                   |> Mogrify.save()
      response = with {:ok, %{size: size}} <- File.stat(image_file && image_file.path),
                                       true <- (size < @max_raw_image_size) do
        pixels = File.read!(image_file.path) |> :binary.bin_to_list()

        File.rm!(image_file.path)
        File.rm!(image_file2.path)

        try do
          length(pixels) > 1024 && BlurHash.encode(pixels, width, height, y_components, x_components) || nil
        rescue _ -> nil
        catch
          _error -> nil
          kind, error -> nil
        end
      else
        _ ->
          File.rm!(image_file.path)
          File.rm!(image_file2.path)
          # blurhash of default image.
          ""
      end
      send(pid, {:calculate_blur_hash, response})
    end


    def refetch(url, image_type, entity_image, context, options) do
      cond do
        image = entity_image && Noizu.ERP.entity!(entity_image.image) ->
          with {:ok, %HTTPoison.Response{status_code: 200} = download} <- HTTPoison.get(url, @http_headers, @http_options) do
            checksum = :crypto.hash(:md5 , download.body) |> Base.encode16() |> String.upcase()
            write_attempt = File.write(image.base, download.body, [:write, :binary])
            cond do
              write_attempt ->
                File.write(image.base <> ".orig", download.body, [:write, :binary])
                try do
                  mogrify_image = %Mogrify.Image{
                    format: format,
                    height: height,
                    width: width
                  } = Mogrify.open(image.base)
                      |> Mogrify.verbose()
                      |> Mogrify.resize_to_limit("2048x2048")
                      |> Mogrify.save(in_place: true)

                  mogrify_image
                  |> Mogrify.resize_to_limit("100x100")
                  |> Mogrify.save(path: image.base <> ".thumb")

                  external = case options[:external] do
                               true -> true
                               false -> false
                               nil -> true
                             end
                  cond do
                    @file_formats[format] ->
                      %Jetzy.Image.Entity{image|
                        hash: checksum,
                        blur_hash: calculate_blur_hash(mogrify_image),
                        source: url,
                        base_dimensions: %{width: width, height: height},
                        external: external,
                        image_type: image_type,
                        file_format: @file_formats[format],
                        moderation: %Jetzy.ModerationDetails{},
                        time_stamp: Noizu.DomainObject.TimeStamp.Second.now(options)
                      } |> Jetzy.Image.Repo.update!(context, options)
                    :else ->
                      File.rm(image.base)
                      File.rm(image.base <> ".orig")
                      File.rm(image.base <> ".thumb")
                      {:error, {:format, format}}
                  end
                rescue e ->
                  File.rm(image.base)
                  {:error, {:rescue, e}}
                catch
                  :exit, e ->
                    File.rm(image.base)
                    {:error, {:exit, e}}
                  e ->
                    File.rm(image.base)
                    {:error, {:catch, e}}
                end
              :else ->
                {:error, {:write, write_attempt}}
            end
          else
            error -> {:error, {:download, error}}
          end
        :else ->
          case from_uri(url, image_type, context, options) do
            entity = %Jetzy.Image.Entity{} ->
              Jetzy.Image.Repo.create!(entity, context, options)
            error -> error
          end
      end
    end



    def prepare_image(binary, image_type, context, options) do
      uuid = UUID.uuid4(:hex)
      checksum = :crypto.hash(:md5 , binary) |> Base.encode16() |> String.upcase()
      image_path = image_path(image_type, uuid)
      image_file = "#{image_path}/base"
      attempt_mkdir = File.mkdir_p(image_path)
      cond do
        attempt_mkdir != :ok -> {:error, {:mkdir_p, attempt_mkdir}}
        File.exists?(image_file) -> {:error, {:uuid_collision, uuid}}
        attempt_write = File.write(image_file, binary, [:write, :binary]) ->
          outcome = cond do
                      attempt_write == :ok ->
                        File.write(image_file <> ".orig", binary, [:write, :binary])
                        try do
                          image = %Mogrify.Image{
                            format: format,
                            height: height,
                            width: width
                          } = Mogrify.open(image_file)
                              |> Mogrify.verbose()
                              |> Mogrify.resize_to_limit("2048x2048")
                              |> Mogrify.save(in_place: true)
                          image
                          |> Mogrify.resize_to_limit("100x100")
                          |> Mogrify.save(path: image_file <> ".thumb")
                          external = case options[:external] do
                                       true -> true
                                       false -> false
                                       nil -> true
                                     end
                          cond do
                            @file_formats[format] ->
                              %Jetzy.Image.Entity{
                                identifier: UUID.string_to_binary!(uuid),
                                uploader: options[:owner] || context.caller,
                                hash: checksum,
                                blur_hash: calculate_blur_hash(image),
                                base: image_file,
                                source: "mobile",
                                base_dimensions: %{width: width, height: height},
                                external: external,
                                image_type: image_type,
                                file_format: @file_formats[format],
                                moderation: %Jetzy.ModerationDetails{},
                                time_stamp: Noizu.DomainObject.TimeStamp.Second.now(options)
                              }
                            :else ->
                              File.rm(image_file)
                              {:error, {:format, format}}
                          end
                        rescue e ->
                          File.rm(image_file)
                          {:error, {:rescue, e}}
                        catch
                          :exit, e ->
                            File.rm(image_file)
                            {:error, {:exit, e}}
                          e ->
                            File.rm(image_file)
                            {:error, {:catch, e}}
                        end
                      :else -> {:error, {:write, attempt_write}}
                    end
          outcome
        :else -> {:error, {:write, :error}}
      end
    end

    def from_api(image_binary, image_type, context, options) do
      prepare_image(image_binary, image_type, context, options)
    end

    #-------------------------
    # from_uri
    #-------------------------
    def from_uri(url, image_type, context, options \\ %{}) do
      Logger.info "Getting Image: #{inspect url}"
      case HTTPoison.get(url, @http_headers, @http_options) do
        {:ok, %HTTPoison.Response{status_code: 200} = download} ->
          cond do
            String.length(download.body) <= @max_image_size ->
              prepare_image(download.body, image_type, context, options)
            :else -> {:error, {:file_size, String.length(download.body)}}
          end
        error -> {:error, {:download, error}}
      end
    end
  end
end
