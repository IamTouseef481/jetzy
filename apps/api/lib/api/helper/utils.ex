defmodule Api.Helper.Utils do
  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" |> String.split("")

  def string_of_length(length \\ 10) do
    Enum.reduce((1..length), [],
      fn (_i, acc) ->
        [Enum.random(@chars) | acc]
      end)
    |> Enum.join("")
  end

  def number(min \\ 100_000, max \\ 999_999) do
    # :rand.uniform(count)
    Enum.random(min..max)
  end
end