defmodule Data.Helper.SeedHelper do
  NimbleCSV.define(MyParser, separator: ",", escape: "\"") #, skip_headers: false)
#  alias NimbleCSV.RFC4180, as: NCSV
  @moduledoc false

  @doc false
  defmacro __using__(_) do
    quote do
      use Ecto.Migration

      def import_from_csv(
            csv_path,
            callback,
            should_coonvert_empty_to_nil \\ false,
            base_path \\ nil
          ) do
        base_path =
          if base_path == nil,
             #            do: Application.get_env(:easy_ecto, :repo)[:seed_base_path],
             do: "apps/data/priv/repo/seeds/",
             else: base_path

        row = case csv_path do
          "user_geo_location" ->
          headers = ["id", "user_id", "location", "latitude", "longitude", "inserted_at", "updated_at", "is_actual_location", "city_lat_long_id"]
          (csv_path <> ".csv")
          |> Path.expand(base_path)
          |> File.stream!()
          |> MyParser.parse_stream()
          |> Stream.each(fn row ->
            row = Enum.zip(headers, row) |> Enum.into(%{})
            row
            |> map_escap_sql(should_coonvert_empty_to_nil)
            |> callback.()
          end)
          |> Stream.run()
          "notifications_record" ->
          headers = ["id", "sender_id", "receiver_id", "description", "type", "friend_activity_type", "pending_friend_request", "chat_message_type", "moment_message_type", "moment_id", "shoutout_id", "comment_id", "comment_source_id", "group_id", "is_deleted", "inserted_at", "updated_at"]
            (csv_path <> ".csv")
            |> Path.expand(base_path)
            |> File.stream!()
    #        |> CSV.decode!(headers: true)
            |> MyParser.parse_stream()
            |> Stream.each(fn row ->
              row = Enum.zip(headers, row) |> Enum.into(%{})
              row
              |> map_escap_sql(should_coonvert_empty_to_nil)
              |> callback.()
            end)
            |> Stream.run()

          _ ->
            (csv_path <> ".csv")
            |> Path.expand(base_path)
            |> File.stream!()
            |> CSV.decode!(headers: true)
            |> Stream.each(fn row ->
              row
              |> map_escap_sql(should_coonvert_empty_to_nil)
              |> callback.()
            end)
            |> Stream.run()
          end
#        row = case csv_path do
#          "notifications_record" ->#
#          _ -> row

      end

      def map_escap_sql(map, should_coonvert_empty_to_nil) do
        for {key, value} <- map, into: %{} do
          case value do
            "nil" ->
              {key, "null"}

            "null" ->
              {key, value}

            "" ->
              if should_coonvert_empty_to_nil do
                {key, "null"}
              else
                value =
                  value
                  |> String.replace("'", "''")

                {key, ~s('#{value}')}
              end

            _ ->
              value =
                value
                |> String.replace("'", "''")

              {key, ~s('#{value}')}
          end
        end
      end

      def map_to_table(map, table) do
        keys =
          map
          |> Map.keys()
          |> Enum.join(~s(", "))

        values =
          map
          |> Map.values()
          |> Enum.join(", ")

        Ecto.Migration.execute("INSERT INTO #{table} (\"#{keys}\") values (#{values})")
      end

      def reset_id_seq(table, id \\ "id") do
        Ecto.Migration.execute("SELECT setval('#{table}_#{id}_seq', (SELECT MAX(#{id}) from \"#{table}\"));")
      end
    end
  end
end
