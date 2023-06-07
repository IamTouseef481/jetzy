defmodule ApiWeb.Utils.Common do
  @moduledoc false
  require Logger
  
  @firebase_api_key Application.get_env(:api, :firebase)[:api_key]
  
  
  @doc """
  Replaces the old key with new
  i.e, replace_map_key(%{iex: 1234}, :iex, :integer)
  iex> %{integer: 1234}
  """
  alias Data.Context
  alias Data.Context.{UserRewardTransactions, RewardManagers}
  alias Data.Schema.{UserRewardTransaction, Permission, Resource, RewardManager}
  def replace_map_key(map, replace, replace_with) do
    if Map.has_key?(map, replace) do
      map
      |> Map.put(replace_with, Map.fetch!(map, replace))
      |> Map.drop([replace])
    end
  end

  def struct_into_map(struct) when is_struct(struct) do
    keys = [:__meta__]

    Map.from_struct(struct)
    |> Map.drop(keys)
    |> struct_into_map()
  end

  def struct_into_map(map) do
    keys = [:__meta__]

    Enum.reduce(map, %{}, fn
      {key, %Ecto.Association.NotLoaded{}}, acc ->
        Map.put(acc, key, nil)

      {key, val}, acc when val.__struct__ in [DateTime, NaiveDateTime, Date, Time] ->
        Map.put(acc, key, nil)

      {key, val}, acc when is_struct(val) ->
        Map.put(acc, key, struct_into_map(Map.from_struct(val) |> Map.drop(keys)))

      {key, val}, acc when is_list(val) ->
        Map.put(acc, key, Enum.map(val, fn x -> struct_into_map(x) end))

      {key, val}, acc ->
        Map.put(acc, key, val)
    end)
  end

  def keys_to_atoms(string_key_map) when is_map(string_key_map) do
    for {key, val} <- string_key_map, into: %{} do
      if is_struct(val) do
        if val.__struct__ in [DateTime, NaiveDateTime, Date, Time] do
          {String.to_atom(key), val}
        else
          {String.to_atom(key), keys_to_atoms(val)}
        end
      else
        {String.to_atom(key), keys_to_atoms(val)}
      end
    end
  end

  def keys_to_atoms(string_key_list) when is_list(string_key_list) do
    string_key_list
    |> Enum.map(&keys_to_atoms/1)
  end

  def keys_to_atoms(value), do: value

  def generate_token do
    :crypto.strong_rand_bytes(64) |> Base.url_encode64() |> binary_part(0, 64)
  end

  def update_points(user_id, reward_id, points, remarks \\ nil, is_completed \\ true) do
    Data.Context.RewardManagers.update_points(user_id, reward_id, points, remarks, is_completed)
  end

  def update_points(user_id, activity_type) do
    Data.Context.RewardManagers.update_points(user_id, activity_type)
  end

  def decode_changeset_errors_internal(changeset) do
    Ecto.Changeset.traverse_errors(changeset , fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts
        |> Keyword.get(String.to_existing_atom(key), key)
        |> to_string()
      end)
    end)
    |> Enum.map(fn {key, value} ->
      "#{key} #{List.first(value)}"
    end)
  end

  
  def decode_changeset_errors(changeset)do
    if Application.get_env(:api, ApiWeb.Endpoint)[:environment] == :prod do
      "Internal Error: Please try again later or contact support."
    else
      decode_changeset_errors_internal(changeset)
    end
  end

  def convert_seconds_to_readable_string(time_in_seconds) when time_in_seconds == 0, do: "0 second"

  def convert_seconds_to_readable_string(time_in_seconds) do
    seconds = rem(time_in_seconds, 60)
    min_hours = trunc((time_in_seconds - seconds) / 60)
    minutes = rem(min_hours, 60)
    hr_days = trunc((min_hours - minutes) / 60)
    hours = rem(hr_days, 24)
    day_months = trunc((hr_days - hours) / 24)
    days = rem(day_months, 30)
    month_years = trunc((day_months - days) / 30)
    months = rem(month_years, 12)
    years = trunc((month_years - months) / 12)
    result = [years, months, days, hours, minutes, seconds]
    time_ago = Enum.reduce_while(result, "", fn x, acc ->
      if x == 0 do
        {:cont, acc}
        else
        {:halt, x}
      end
    end)
    time_ago_unit_index = Enum.find_index(result, &(&1 == time_ago))
    cond do
      time_ago_unit_index == 0 -> "#{time_ago} year"
      time_ago_unit_index == 1 -> "#{time_ago} month"
      time_ago_unit_index == 2 -> "#{time_ago} day"
      time_ago_unit_index == 3 -> "#{time_ago} hour"
      time_ago_unit_index == 4 -> "#{time_ago} minute"
      time_ago_unit_index == 5 -> "#{time_ago} second"
    end |> append_or_prepend_s_in_string(time_ago)
  end

  def append_or_prepend_s_in_string(string, time_ago), do: (if time_ago > 1, do:  string <> "s", else: string)

  def convert_time_string_to_time_format(time) do
    case time do
      nil -> nil
      "" -> nil
      _ ->
        case Time.from_iso8601(time) do
          {:ok, time} -> time
          _ -> nil
        end
    end
  end

  def convert_date_string_to_date_format(date) do
    case date do
      nil -> nil
      "" -> nil
      _ ->
        case Date.from_iso8601(date) do
          {:ok, date} -> date
          _ -> nil
        end
    end
  end

  def popular_interest_ids do
    [
      "0e8283b9-a1cd-4bcb-b799-810a9137d985", "fb1348ba-3388-477c-b422-35524a93ee8e",
      "2cfd8787-315b-4f3b-8c50-83f2a14d3f3c", "bfc4645c-10b5-4adf-b944-6830918d2e60",
      "0d3b5923-2435-4f7b-ae20-983700687bb0", "7aad45a5-f697-4dae-bf0a-a88dd9e0adec",
      "12de9bc9-e4f6-4f8e-8df7-3cd572faea55", "de9dca9a-66f0-4975-aa83-0c4d3ecba074",
      "a59e6e53-d6eb-4b89-9c50-1c0384f29e65", "f6c16a76-3896-43b1-941f-1b11bea24d81"
    ]
  end
#  def insert_or_update_resources(obj) do
#    case Context.get(Resource, obj.id) do
#      nil -> Context.create(Resource, obj)
#      data -> Context.update(Resource, data, obj)
#    end
#  end
#  def insert_or_update_permissions(%{role_id: role_id, resource_id: resource_id} = obj) do
#    case Context.get_by(Permission, [role_id: role_id, resource_id: resource_id]) do
#      nil -> Context.create(Permission, obj)
#      data -> Context.update(Permission, data, obj)
#    end
#  end
#  def insert_or_update(model, obj) do
#    case Context.get_by(model, [event: obj.event]) do
#      nil -> Context.create(model, obj)
#      data -> Context.update(model, data, obj)
#    end
#  end
#
#  def insert_or_update_reward_managers(model, obj) do
#    case Context.get_by(model, [id: obj.id]) do
#      nil -> Context.create(model, obj)
#      data -> Context.update(model, data, obj)
#    end
#  end

  def insert_or_update(model, obj, get_by_list) do
    case Context.get_by(model, get_by_list) do
      nil -> Context.create(model, obj)
      data -> Context.update(model, data, obj)
    end
  end

  def string_to_float(string) when is_binary(string) do
    if String.contains?(string, ".") do
      String.to_float(string)
    else
    String.to_integer(string)
    end
  end

  def string_to_float(value) do
   value
  end

  def check_message(nil, event, nil) do
    {:error, "Cannot send empty #{event}}"}
  end

  def check_message(nil, event, []) do
    {:error, "Cannot send empty #{event}}"}
  end

  def check_message(nil, event, images) do
    case filter_images(images) do
      [] -> {:error, "Cannot send empty #{event}}"}
      _ -> true
    end
  end

  def check_message(message, event, images) do
    message = String.trim(message)
    cond do
      message == "" && is_nil(images) -> {:error, "Cannot send empty #{event}}"}
      message == "" && filter_images(images) == [] -> {:error, "Cannot send empty #{event}}"}
      true -> true
    end
  end

  defp filter_images(images) do
    Enum.flat_map(images , fn
      nil -> []
      "" -> []
      image -> String.trim(image) == "" && [] || [image]
    end)
  end
  def generate_url(event, id, title \\ "", description \\ "", image \\ "https://jetzyapp.com/Splash/images/logo2.png"), do: Data.Helper.generate_url(event, id, title, description, image)

  def broadcast_for_comment(topic, user_event, comments_count) do
        payload = %{
          "post" => %{
            "id" => user_event.id
          },
          "commentsCount" => comments_count
        }
        ApiWeb.Endpoint.broadcast(
        topic,
        "comment",
        payload
        )
  end

  def broadcast_for_like(topic, user_event, likes_count) do
       payload = %{
          "post" => %{
            "id" => user_event.id
          },
          "likesCount" => likes_count
        }
        ApiWeb.Endpoint.broadcast(
          topic,
          "post_liked",
          payload
        )
  end


  def raw_binary_to_string(raw) do
    codepoints = String.codepoints(raw)
    val = Enum.reduce(codepoints,
      fn(w, result) ->
        cond do
          String.valid?(w) ->
            result <> w
          true ->
            << parsed :: 8>> = w
            result <>   << parsed :: utf8 >>
        end
      end)

  end

  def get_pagination(params) do
    [
      page: params["page"] || 1,
      page_size: params["page_size"] || 30
    ]
  end
end
