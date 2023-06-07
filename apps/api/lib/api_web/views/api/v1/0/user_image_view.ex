defmodule ApiWeb.Api.V1_0.UserImageView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.UserImageView

  def render("user_images.json", %{user_images: user_images}) do
    %{user_images: render_many(user_images, UserImageView, "user_image.json")}
  end

  def render("user_image.json", %{user_image: user_image}) do
    user_image = Map.from_struct(user_image) |> Map.drop([:__meta__, :user])
    
    %{
        small_images: user_image.small_images,
        images: user_image.images,
        id: user_image.id,
        blur_hash: user_image.blur_hash
    }
  end

  def render("create_user_image.json", %{user_image: user_image}) do
    %{user_images: render_one(user_image, UserImageView, "user_image.json")}
  end

  def render("user_image.json", %{error: error}) do
    %{errors: error}
  end
end
