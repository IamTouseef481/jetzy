defmodule Data.Context.ApiUserActivityLogs do
  @moduledoc """
  The ApiUserActivityLogs context.
  """

  import Ecto.Query, warn: false
  alias Data.Repo

  alias Data.Schema.ApiUserActivityLog

  @doc """
  Returns the list of api_user_activity_logs.

  ## Examples

      iex> list_api_user_activity_logs()
      [%ApiUserActivityLog{}, ...]

  """
  def list_api_user_activity_logs do
    Repo.all(ApiUserActivityLog)
  end

  @doc """
  Gets a single api_user_activity_log.

  Raises `Ecto.NoResultsError` if the Api user activity log does not exist.

  ## Examples

      iex> get_api_user_activity_log!(123)
      %ApiUserActivityLog{}

      iex> get_api_user_activity_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_api_user_activity_log!(id), do: Repo.get!(ApiUserActivityLog, id)

  @doc """
  Creates a api_user_activity_log.

  ## Examples

      iex> create_api_user_activity_log(%{field: value})
      {:ok, %ApiUserActivityLog{}}

      iex> create_api_user_activity_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_api_user_activity_log(attrs \\ %{}) do
    %ApiUserActivityLog{}
    |> ApiUserActivityLog.changeset(attrs)
    |> Repo.insert()
    |> Tanbits.Shim.inject_uir()
  end

  @doc """
  Updates a api_user_activity_log.

  ## Examples

      iex> update_api_user_activity_log(api_user_activity_log, %{field: new_value})
      {:ok, %ApiUserActivityLog{}}

      iex> update_api_user_activity_log(api_user_activity_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_api_user_activity_log(%ApiUserActivityLog{} = api_user_activity_log, attrs) do
    api_user_activity_log
    |> ApiUserActivityLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a api_user_activity_log.

  ## Examples

      iex> delete_api_user_activity_log(api_user_activity_log)
      {:ok, %ApiUserActivityLog{}}

      iex> delete_api_user_activity_log(api_user_activity_log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_api_user_activity_log(%ApiUserActivityLog{} = api_user_activity_log) do
    Repo.delete(api_user_activity_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking api_user_activity_log changes.

  ## Examples

      iex> change_api_user_activity_log(api_user_activity_log)
      %Ecto.Changeset{data: %ApiUserActivityLog{}}

  """
  def change_api_user_activity_log(%ApiUserActivityLog{} = api_user_activity_log, attrs \\ %{}) do
    ApiUserActivityLog.changeset(api_user_activity_log, attrs)
  end
end
