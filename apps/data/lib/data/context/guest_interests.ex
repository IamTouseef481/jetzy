defmodule Data.Context.GuestInterests do
  import Ecto.Query, warn: false

  alias Data.Repo
  alias Data.Context
  #  alias Data.Context
  alias Data.Schema.GuestInterest

  def get_guest_interest_by_device_and_interest_id(device_id, interest_id) do
    GuestInterest
    |> where([gi], gi.device_id == ^device_id)
    |> where([gi], gi.interest_id == ^interest_id)
    |> Repo.one()
  end

  def get_guest_interest_by_device_id(device_id) do
    GuestInterest
    |> where([gi], gi.device_id == ^device_id)
    |> select([gi], gi.interest_id)
    |> Repo.all()
  end

  def get_all_guest_interests_by_device_id(device_id) do
    GuestInterest
    |> where([gi], gi.device_id == ^device_id)
    |> Repo.all()
  end

  def delete_guest_interests_by_device_id(device_id) do
    case get_all_guest_interests_by_device_id(device_id) do
      nil ->
        :do_nothing
      interests ->
        Enum.each(interests, fn interest ->
            Context.delete(interest)
          end
        )
    end
  end
end
