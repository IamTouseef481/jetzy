defmodule Data.Helper.UserGeolocationHelper do
  @moduledoc false

  alias Data.Repo
  alias Data.Schema.{UserRole, User, UserGeoLocation, UserGeoLocationLog}
  alias Data.Context
  import Ecto.Query

  def duplicates() do
    duplicates = UserGeoLocation
    |> group_by([ugl], ugl.user_id)
    |> having([ugl], count(ugl.id) > 1)
    |> select([ugl], %{
      user_id: ugl.user_id,
      cnt: fragment("count(?) as cnt", ugl.id)
    })
    |> Repo.all()
    case duplicates do
      [%{cnt: cnt, user_id: user_id}|_] ->
        Enum.reduce(duplicates, [], fn dupl, acc ->
          data =
          UserGeoLocation
          |> where([ugl], ugl.user_id == ^dupl.user_id)
          |> order_by([ugl], desc: ugl.inserted_at)
          |> Repo.all()

          case data do
            any -> Enum.each(List.delete_at(data, 0), fn to_delete ->
              Context.delete(to_delete)
            end)
          end
        end
        )

      [] -> :ok
    end
  end

  def check_not_nil_user_geo do
    User
    |> select([u],%{user_id: u.id, latitude: u.latitude, longitude: u.longitude})
    |> Repo.all
    |> Enum.each(fn user ->
       case Context.get_by(UserGeoLocation,[user_id: user.user_id]) do
         nil ->
           case get_latest_location_of_user(user.user_id) do
             nil -> Context.create(UserGeoLocation, %{user_id: user.user_id, latitude: user.latitude, longitude: user.longitude})
             %UserGeoLocationLog{} = ugll ->
               Context.create(UserGeoLocation, %{latitude: ugll.latitude, longitude: ugll.longitude, user_id: user.user_id})
           end

         data -> :do_nothing
       end
    end)

  end

  defp get_latest_location_of_user(user_id) do
    UserGeoLocationLog
    |> where([ugll], ugll.user_id == ^user_id)
    |> order_by([ugll], desc: ugll.inserted_at)
    |> limit(1)
    |> Repo.one()
  end
end
