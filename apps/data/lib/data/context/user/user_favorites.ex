defmodule Data.Context.UserFavorites do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
#  alias Data.Schema.User
  alias Data.Schema.{UserFavorite, User, UserFollow, UserInterest, UserGeoLocation}
#  alias Api.Guardian

  @spec preload_all(UserFavorite.t()) :: UserFavorite.t()
  def preload_all(data),
      do: Repo.preload(data, [:user_favorite_type])

  def get_by_type(user_id, user_favorite_type_id, page, page_size \\ 5)do
  UserFavorite
  |> where([uf], uf.user_id == ^user_id and uf.user_favorite_type_id == ^user_favorite_type_id)
  |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_near_by_favorites(current_user_id, %{"latitude" => lat, "longitude" => long, "page" => page, "page_size" => page_size} = params) do
    follow_status = "followed"
    lat = is_binary(lat) && String.to_float(lat) || lat
    long = is_binary(long) && String.to_float(long) || long
    radius = params["radius"] || 50.0
    radius = is_binary(radius) && String.contains?(radius, ".") && String.to_float(radius) ||  is_binary(radius) && String.to_integer(radius)/1 || radius
    {distance, multiplication_factor} =  case params["distance_unit"] do
      "km" -> {1.60934 * radius, 0.621372736649807}
      _ -> {radius, 1}
    end

    UserFavorite
    |> where([uff], fragment("(point(?,?) <@> point(?,?))/?<?", uff.longitude, uff.latitude, ^long, ^lat, ^multiplication_factor, ^distance))
    |> order_by([uff], [asc: fragment("(point(?,?) <@> point(?,?))/?", uff.longitude, uff.latitude, ^long, ^lat, ^multiplication_factor)])
    |> preload(:user)
    |> select([uff],
         {uff, fragment("(point(?,?) <@> point(?,?))/?", uff.longitude, uff.latitude, ^long, ^lat, ^multiplication_factor)})
    |> Repo.paginate(%{page: page, page_size: page_size})
  end

#  def get_near_by_favorites(current_user_id, %{"latitude" => lat, "longitude" => long, "page" => page, "page_size" => page_size} = params) do
#    follow_status = "followed"
#    lat = is_binary(lat) && String.to_float(lat) || lat
#    long = is_binary(long) && String.to_float(long) || long
#    radius = params["radius"] || 50.0
#    radius = is_binary(radius) && String.to_float(radius) || radius
#    {distance, multiplication_factor} =  case params["distance_unit"] do
#      "km" -> {1.60934 * radius, 0.621372736649807}
#      _ -> {radius, 1}
#    end
#
#    User
#    |> join(:inner, [u], uf in UserFollow, on: (uf.follower_id == ^current_user_id and uf.follow_status == ^follow_status) or uf.followed_id == u.id)
#    |> join(:inner, [u, _], ui in UserInterest, on: ui.user_id == ^current_user_id)
#    |> join(:inner, [u, _, ui], ui2 in UserInterest, on: ui.interest_id == ui2.interest_id and ui2.user_id == u.id)
#    |> join(:inner, [u, ...], uff in UserFavorite, on: uff.user_id == u.id)
#    |> where([_, _, _, _, uff], fragment("(point(?,?) <@> point(?,?))/?<?", uff.longitude, uff.latitude, ^long, ^lat, ^multiplication_factor, ^distance))
#    |> distinct([u, _, _, _, uff], [asc: fragment("(point(?,?) <@> point(?,?))/?", uff.longitude, uff.latitude, ^long, ^lat, ^multiplication_factor), asc: u.id])
#    |> order_by([u, _, _, _, uff], [asc: fragment("(point(?,?) <@> point(?,?))/?", uff.longitude, uff.latitude, ^long, ^lat, ^multiplication_factor)])
#    |> select([..., uff],
#         %{
#           name: uff.name,
#           description: uff.description,
#           distance: fragment("(point(?,?) <@> point(?,?))/?", uff.longitude, uff.latitude, ^long, ^lat, ^multiplication_factor),
#           image: uff.image,
#           thumbnail: uff.small_image,
#           latitude: uff.latitude,
#           longitude: uff.longitude,
#           type: uff.user_favorite_type_id
#         })
#    |> Repo.paginate(%{page: page, page_size: page_size})
#  end

  def get_user_recommendations(user_id, page, page_size) do
    UserFavorite
    |> join(:inner, [uf], ugl in UserGeoLocation, on: ugl.user_id == uf.user_id)
    |> where([uf, _], uf.user_id == ^user_id)
    |> order_by([uf, ugl], [asc: fragment("(point(?,?) <@> point(?,?))", uf.longitude, uf.latitude, ugl.longitude, ugl.latitude)])
    |> select([uf, ugl],
         %{
           name: uf.name,
           description: uf.description,
           distance: fragment("(point(?,?) <@> point(?,?))", uf.longitude, uf.latitude, ugl.longitude, ugl.latitude),
           image: uf.image,
           thumbnail: uf.small_image,
           latitude: uf.latitude,
           longitude: uf.longitude,
           type: uf.user_favorite_type_id
         })
    |> Repo.paginate(%{page: page, page_size: page_size})
  end

end
