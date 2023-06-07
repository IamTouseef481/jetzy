defmodule SelectWeb.SelectView do
    @moduledoc false
    use ApiWeb, :view

    def humanized_date_time(date_time) when date_time not in [nil, ""] do
      date_time
      |> to_string()
      |> Timex.parse!("{RFC3339z}")
      |> Timex.Format.DateTime.Formatter.format!("%Y-%B-%d %r", :strftime)
    end

    def humanized_date_time(date_time), do: date_time
  end
