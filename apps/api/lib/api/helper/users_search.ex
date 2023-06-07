defmodule Api.Helper.UsersSearch do
  @moduledoc """
    Implementation of the full-text user search
    """

    import Ecto.Query

    @spec run(Ecto.Query.t(), any()) :: Ecto.Query.t()
    def run(query, search_term) do
      where(
      query,
      fragment(
        "to_tsvector('english', first_name || ' ' || coalesce(last_name, ' ')) @@ to_tsquery(?)",
        ^prefix_search(search_term)
      )
    )
    end

    def prefix_search(term) do
      term =
      term
      |> String.trim(" ")
      |> String.replace(~r/\W+/u, ":*&")
      |> String.trim(":*&")
      |> Kernel.<>":*"
      # |> then(&(&1<> ":*"))

      # String.replace(~r/\W/u, "|") <> ":*"
    end
end
