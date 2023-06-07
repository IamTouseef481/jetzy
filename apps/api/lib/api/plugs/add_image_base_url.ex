defmodule Api.Plugs.AddImageBaseURL do
  import Plug.Conn
  @image_string_camelcase_list [
    "image",
    "images",
    "imageName",
    "smallImageName",
    "userImage",
    "messageImages",
    "profileImage",
    "imagePath",
    "shoutoutImages",
    "userEventImages"
  ]
  @image_atom_camelcase_list [
    :image,
    :images,
    :imageName,
    :smallImageName,
    :userImage,
    :messageImages,
    :profileImage,
    :imagePath,
    :shoutoutImages,
    :userEventImages
    ]
  @image_string_snake_list [
    "image_name",
    "small_image_name",
    "user_image",
    "message_images",
    "profile_image",
    "image_path",
    "shoutout_images",
    "user_event_images"
    ]
  @image_atom_snake_list [
    :image_name,
    :small_image_name,
    :user_image,
    :message_images,
    :profile_image,
    :image_path,
    :shoutout_images,
    :user_event_images
  ]



  def init(opts), do: opts

  def call(conn, _opts) do
    register_before_send(conn, fn(conn) -> add_image_base_url(conn) end)
  end

  def add_image_base_url(conn) do
    case Poison.decode(conn.resp_body) do
      {:error, _} -> conn
      {:ok, decoded_resp} ->
      data = adding_image_base_url(decoded_resp)
      resp(conn, conn.status, Poison.encode!(data))
    end
  end

  def adding_image_base_url(response) when is_list(response) do
    Enum.map(response, fn resp ->
      adding_image_base_url(resp)
    end)
  end
  
  def adding_image_base_url(response) when is_map(response) do
    image_bucket = JetzyModule.AssetStoreModule.image_bucket()
    base_url = JetzyModule.AssetStoreModule.image_base_url()
    Enum.reduce(response, response, fn {key, value}, acc ->
      cond do
        key in @image_atom_snake_list and value in [nil, ""] -> Map.put(acc, :base_url, nil)
        key in @image_string_snake_list and value in [nil, ""] -> Map.put(acc, "base_url", nil)
        key in @image_atom_camelcase_list and value in [nil, ""] -> Map.put(acc, :baseUrl, nil)
        key in @image_string_camelcase_list and value in [nil, ""] -> Map.put(acc, "baseUrl", nil)
        key in @image_atom_snake_list and value not in [nil, ""] -> Map.put(acc, :base_url, "https://#{base_url}/")
        key in @image_string_snake_list and value not in [nil, ""] -> Map.put(acc, "base_url", "https://#{base_url}/")
        key in @image_atom_camelcase_list and value not in [nil, ""] -> Map.put(acc, :baseUrl, "https://#{base_url}/")
        key in @image_string_camelcase_list and value not in [nil, ""] -> Map.put(acc, "baseUrl", "https://#{base_url}/")
        is_struct(value) and value.__struct__ in [DateTime, NaiveDateTime, Date, Time] -> acc
        is_map(value) or is_list(value) -> Map.put(acc, key, adding_image_base_url(value))
        true -> acc
      end
    end)
  end

  def adding_image_base_url(response) do
    response
  end
end
