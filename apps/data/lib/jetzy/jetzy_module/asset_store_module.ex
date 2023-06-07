defmodule JetzyModule.AssetStoreModule do
  @moduledoc """
  Responsible for accepting files and uploading them to an asset store.
  """

  alias ExAws.S3
  import Mogrify
  require Logger

  @storage_bucket Application.get_env(:data, :aws)[:storage_bucket]
  @image_base_url Application.get_env(:data, :aws)[:base_url]
  @root_dir Application.get_env(:data, :root_dir)
  
  def image_bucket(), do: @storage_bucket
  def image_base_url(), do: @image_base_url
  def image_mount_dir(), do: @root_dir <> "/images/"

  #-----------------------------------
  # save_image
  #-----------------------------------
  @doc """
    Save image to S3, and generate thumb and blur_hash values.
  """
  def save_image(image_type, image_binary, context, options \\ []) do
    case Jetzy.Image.Repo.from_api(image_binary, image_type, context, options) do
      image = %{__struct__: Jetzy.Image.Entity} ->
        image = Jetzy.Image.Repo.create!(image, Noizu.ElixirCore.CallingContext.admin())
        full = "#{image.base}" |> String.trim_leading(image_mount_dir())
        thumb = "#{image.base}.thumb" |> String.trim_leading(image_mount_dir())

        {:ok, %{
          image: full,
          thumb: thumb,
          blur_hash: image.blur_hash,
          identifier: image.identifier
        }}

      error = {:error, _} ->
        Logger.error("Unable to save image: #{inspect error}")
        error
      error ->
        Logger.error("Unable to save image: #{inspect error}")
        {:error, error}
    end
  end

  #-----------------------------------
  # extract_image_set
  #-----------------------------------
  @doc """
  save image(s) from user request.
  """
  def extract_image_set(image_type, image_set, context, options \\ [])
  def extract_image_set(image_type, "", context, options), do: nil
  def extract_image_set(image_type, [], context, options), do: nil
  def extract_image_set(image_type, image_base64, context, options) when is_binary(image_base64) do
    with {:ok, image_binary} <- Base.decode64(Enum.at(String.split(image_base64, ","), 1)) do
      save_image(image_type, image_binary, context, options)
    else
      error = {:error,_} -> error
      error -> {:error, error}
    end
  rescue e ->
    Logger.warn(Exception.format(:error, e, __STACKTRACE__))
    {:error, {:rescue, e}}
  catch
    :exit, e ->
      Logger.warn(Exception.format(:error, e, __STACKTRACE__))
      {:error, {:exit, e}}
    e ->
      Logger.warn(Exception.format(:error, e, __STACKTRACE__))
      {:error, {:catch, e}}
  end
  def save_image_set(image_type, image_set, context, options) when is_list(image_set) do
    set = Enum.map(image_set, &(extract_image_set(image_type, &1, context, options)))
          |> Enum.filter(&(&1))
    length(set) > 0 && {:ok, set} || nil
  end

  #-----------------------------------
  # select_random_profile_image
  #-----------------------------------
  def select_random_profile_image(_, _ \\ []) do
    case Jetzy.Helper.get_cached_setting(:default_profile_images, []) |> Enum.take_random(1) do
      [image] ->
        full = "#{image.base}" |> String.trim_leading(image_mount_dir())
        thumb = "#{image.base}.thumb" |> String.trim_leading(image_mount_dir())
  
        {:ok, %{
          image: full,
          thumb: thumb,
          blur_hash: image.blur_hash,
          identifier: image.identifier
        }}
      _ -> nil
    end
  end
  
  
  
  @doc """
  Accepts a base64 encoded image and uploads it to S3.

  ## Examples

      iex> upload_image(...)
      "https://image_bucket.s3.amazonaws.com/dbaaee81609747ba82bea2453cc33b83.png"

    @deprecated
  """
  def upload_if_image(params, image_key, id, previous_object \\ %{}) do
    case Map.has_key?(params, image_key) and !is_nil(Map.get(params, image_key)) and
             Map.get(params, image_key) != "" do
      true ->
        case Map.get(params, image_key)  do
          [] -> []
          img_base64 when is_list(img_base64) ->
            Enum.map(img_base64, fn
              "" -> nil
              img_base64 ->
              {:ok, img_name} = upload_image(img_base64, id)
              img_name
            end)
          img_base64 when is_binary(img_base64) ->
            {:ok, img_name} = upload_image(img_base64, id)
            img_name
          _ -> nil
        end
      false ->
        Map.get(previous_object, String.to_existing_atom(image_key))
    end
  end

  @doc """
  @deprecated
"""
  def upload_if_image_extended(params, image_key, id, previous_object \\ %{}) do
    case Map.has_key?(params, image_key) and !is_nil(Map.get(params, image_key)) and
         Map.get(params, image_key) != "" do
      true ->
        case Map.get(params, image_key)  do
          [] -> []
          img_base64 when is_list(img_base64) ->
            Enum.map(img_base64, fn
              "" -> {nil, nil, nil}
              img_base64 ->
                {:ok, extended} = upload_image_extended(img_base64, id)
                extended
            end)
          img_base64 when is_binary(img_base64) ->
            {:ok, extended} = upload_image_extended(img_base64, id)
            extended
          _ -> {nil, nil, nil}
        end
      false ->
        Map.get(previous_object, String.to_existing_atom(image_key))
    end
  end

  @doc """
    @deprecated
  """
  def upload_raw_image("/" <> image_name, image_binary) do
    # Decode the image
    image_bucket = @storage_bucket
    # Uploading to S3 Asynchronously
    params = %{image_bucket: image_bucket, full_image_name: image_name, image_binary: image_binary}
    Task.start(
      __MODULE__,
      :upload_image_helper,
      params: params
    )  # Note no confirmation of completion
    {:ok, image_name}
  end
  def upload_raw_image(image_name, image_binary) do
    # Decode the image
    image_bucket = @storage_bucket
    # Uploading to S3 Asynchronously
    #params = %{image_bucket: image_bucket, full_image_name: image_name, image_binary: image_binary}
    ExAws.S3.put_object(
      image_bucket,
      image_name,
      image_binary
    ) |> ExAws.request()
    #Task.start(
    #  __MODULE__,
    #  :upload_image_helper,
    #  params: params
    #)  # Note no confirmation of completion
    {:ok, image_name}
  end

  @doc """
    @deprecated
  """
  def upload_image_extended(image_base64, _id) do
    # Decode the image
    encoded_data = String.split(image_base64, ",")
    {:ok, image_binary} = Base.decode64(Enum.at(encoded_data, 1))
    case Jetzy.Image.Repo.from_api(image_binary, :user_profile, Noizu.ElixirCore.CallingContext.admin(), []) do
      image = %{__struct__: Jetzy.Image.Entity} ->
        {image_name, thumb_name, blur_hash} = (with {:ok, full_name} <- (image.file_format in [:png, :jpg, :gif]) && {:ok, "#{image.base}.#{image.file_format}"},
                                                    contents <- File.read!(image.base),
                                                    {:ok, image_name} <- JetzyModule.AssetStoreModule.upload_raw_image(full_name, contents) do
                                                 (with {:ok, full_name} <- (image.file_format in [:png, :jpg, :gif]) && {:ok, "#{image.base}.thumb.#{image.file_format}"},
                                                       contents <- File.read!(image.base <> ".thumb"),
                                                       {:ok, thumb_name} <- JetzyModule.AssetStoreModule.upload_raw_image(full_name, contents) do
                                                    {image_name, thumb_name, image.blur_hash}
                                                  else
                                                    _ ->
                                                      {image_name, image_name, image.blur_hash}
                                                  end)
                                               else
                                                 _ ->
                                                   image = Data.Context.DefaultProfileImages.get_random()
                                                   image && {image.image_name, image.small_image, nil} || {nil, nil, nil}
                                               end)
        {:ok, {image_name, thumb_name, blur_hash}}
      error ->
        Logger.error("Unable to download image: #{inspect error}")
        error
    end
  end

  @doc """
    @deprecated
  """
  def upload_image(image_base64, id) do
    # Decode the image
    encoded_data = String.split(image_base64, ",")
    {:ok, image_binary} = Base.decode64(Enum.at(encoded_data, 1))
    {:ok, random} = Ecto.UUID.load(Ecto.UUID.bingenerate())
    image_bucket = @storage_bucket
    {:ok, extension} = image_binary |> image_extension()
    image_name = id <> "/" <> random <> "." <> extension

    # Uploading to S3 Asynchronously
    #params = %{image_bucket: image_bucket, image_name: image_name, extension: extension, image_binary: image_binary}
    ExAws.S3.put_object(
      image_bucket,
      image_name,
      image_binary
    ) |> ExAws.request()
    {:ok, image_name}
  end

  @doc """
    @deprecated
  """
  def upload_if_image_with_thumbnail(params, image_key, id, previous_object \\ %{}) do
    case Map.has_key?(params, image_key) and !is_nil(Map.get(params, image_key)) and
         Map.get(params, image_key) != "" do
      true ->
        case Map.get(params, image_key)  do
          [] -> []
          img_base64 when is_list(img_base64) ->
            Enum.map(img_base64, fn
              "" -> nil
              img_base64 ->
                {:ok, img_name, small_image} = upload_image_with_thumbnail(img_base64, id)
                {img_name, small_image}
            end)
          img_base64 when is_binary(img_base64) ->
            {:ok, img_name, small_image} = upload_image_with_thumbnail(img_base64, id)
            {img_name, small_image}
          _ -> nil
        end
      false ->
        Map.get(previous_object, String.to_existing_atom(image_key))
    end
  end

  @doc """
    @deprecated
  """
  def upload_image_with_thumbnail(image_base64, id) do
    # Decode the image
    encoded_data = String.split(image_base64, ",")
    {:ok, image_binary} = Base.decode64(Enum.at(encoded_data, 1))
    {:ok, random} = Ecto.UUID.load(Ecto.UUID.bingenerate())
    image_bucket = @storage_bucket
    {:ok, extension} = image_binary |> image_extension()
    image_name = id <> "/" <> random <> "." <> extension
    thumbnail_path = id <> "/" <> random <> "_thumb" <> "." <> extension
    path = Path.absname("")
    File.mkdir(path <> "/#{id}")
    File.write(path <> "/#{image_name}", image_binary, [:binary])
    open(path <> "/#{image_name}") |> resize_to_limit("100x100") |> save(path: path <> "/#{thumbnail_path}")
    {:ok, small_image} = File.read(path <> "/#{thumbnail_path}")
    
    Task.start(fn  ->
    File.rm(path <> "/#{image_name}")
    File.rm(path <> "/#{thumbnail_path}")
    File.rm(path <> "/#{id}")
    end)

    # Uploading to S3 Asynchronously
    #params = %{image_bucket: image_bucket, image_name: image_name, extension: extension, image_binary: image_binary}
    ExAws.S3.put_object(
      image_bucket,
      image_name,
      image_binary
    ) |> ExAws.request()

    ExAws.S3.put_object(
      image_bucket,
      thumbnail_path,
      small_image
    ) |> ExAws.request()
    {:ok, image_name, thumbnail_path}
  end

  @doc """
    @deprecated
  """
  def upload_user_event_image_extended(image_base64, _id) do
    # Decode the image
    encoded_data = String.split(image_base64, ",")
    {:ok, image_binary} = Base.decode64(Enum.at(encoded_data, 1))
    case Jetzy.Image.Repo.from_api(image_binary, :post, Noizu.ElixirCore.CallingContext.admin(), []) do
      image = %{__struct__: Jetzy.Image.Entity} ->
        {image_name, thumb_name, blur_hash} = (with {:ok, full_name} <- (image.file_format in [:png, :jpg, :gif]) && {:ok, "#{image.base}.#{image.file_format}"},
                                                    contents <- File.read!(image.base),
                                                    {:ok, image_name} <- JetzyModule.AssetStoreModule.upload_raw_image(full_name, contents) do
                                                 (with {:ok, full_name} <- (image.file_format in [:png, :jpg, :gif]) && {:ok, "#{image.base}.thumb.#{image.file_format}"},
                                                       contents <- File.read!(image.base <> ".thumb"),
                                                       {:ok, thumb_name} <- JetzyModule.AssetStoreModule.upload_raw_image(full_name, contents) do
                                                    {image_name, thumb_name, image.blur_hash}
                                                  else
                                                    _ ->
                                                      {image_name, image_name, image.blur_hash}
                                                  end)
                                               else
                                                 _ ->
                                                   image = Data.Context.DefaultProfileImages.get_random()
                                                   image && {image.image_name, image.small_image, nil} || {nil, nil, nil}
                                               end)
        {:ok, {image_name, thumb_name, blur_hash}}
      error ->
        Logger.error("Unable to download image: #{inspect error}")
        error
    end
  end

  @doc """
    @deprecated
  """
  def upload_image_helper({_, %{image_bucket: image_bucket, image_name: image_name, extension: extension, image_binary: image_binary}}) do
    {:ok, _result} =
      S3.put_object(
        image_bucket,
        "#{image_name}.#{extension}",
        image_binary
      )
      |> ExAws.request()
  end

  @doc """
    @deprecated
  """
  def upload_image_helper({_, %{image_bucket: image_bucket, full_image_name: full_image_name, image_binary: image_binary}}) do
    {:ok, _result} =
      ExAws.S3.put_object(
        image_bucket,
        full_image_name,
        image_binary
      ) |> ExAws.request()
  end

  @doc """
    @deprecated
  """
  # Helper functions to read the binary to determine the image extension
  defp image_extension(<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>),
    do: {:ok, "png"}

  defp image_extension(<<0xFF, 0xD8, _::binary>>), do: {:ok, "jpg"}
end
