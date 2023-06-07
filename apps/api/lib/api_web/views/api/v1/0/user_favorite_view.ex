defmodule ApiWeb.Api.V1_0.UserFavoriteView do
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.{UserView, UserFavoriteView}


  def render("user_favorites.json", %{user_favorites: user_favorites}) do
    data = render_many(user_favorites.entries, UserFavoriteView, "user_favorite.json", as: :user_favorite)
    page_data = %{
      total_rows: user_favorites.total_entries,
      page: user_favorites.page_number,
      total_pages: user_favorites.total_pages
    }
    %{data: data, pagination: page_data}
  end

  def render("user_favorite.json", %{user_favorite: user_favorite})do
    %{
            id: user_favorite.id,
            description: user_favorite.description,
            image: user_favorite.image,
            image_thumbnail: user_favorite.small_image,
            address: user_favorite.address,
            name: user_favorite.name,
            user_id: user_favorite.user_id,
            user_favorite_type_id: user_favorite.user_favorite_type_id,
            latitude: user_favorite.latitude,
            longitude: user_favorite.longitude
    }
  end

  def render("nearby_recommendations.json", %{favorites: favorites}) do
    data = render_many(favorites.entries, UserFavoriteView, "nearby_recommendation.json", as: :favorite)
    page_data = %{
      total_rows: favorites.total_entries,
      page: favorites.page_number,
      total_pages: favorites.total_pages
    }
    %{data: data, pagination: page_data}
  end

  def render("nearby_recommendation.json", %{favorite: {favorite, distance}}) do
    %{
      name: favorite.name,
      description: favorite.description,
      distance: distance,
      image: favorite.image,
      thumbnail: favorite.small_image,
      latitude: favorite.latitude,
      longitude: favorite.longitude,
      type: favorite.user_favorite_type_id,
      user: %{
            first_name: favorite.user.first_name,
            last_name: favorite.user.last_name,
            image: favorite.user.image_name,
            thumbnail: favorite.user.small_image_name
          }
    }
  end

  def render("error.json", %{error: error}) do
    %{errors: error}
  end

end
