defmodule Data.Context.ElmahErrors do
  @moduledoc """
  The ElmahErrors context.
  """

  import Ecto.Query, warn: false
  alias Data.Repo

  alias Data.Schema.ElmahError

  @doc """
  Returns the list of elmah_errors.

  ## Examples

      iex> list_elmah_errors()
      [%ElmahError{}, ...]

  """
  def list_elmah_errors do
    Repo.all(ElmahError)
  end

  @doc """
  Gets a single elmah_error.

  Raises `Ecto.NoResultsError` if the Elmah error does not exist.

  ## Examples

      iex> get_elmah_error!(123)
      %ElmahError{}

      iex> get_elmah_error!(456)
      ** (Ecto.NoResultsError)

  """
  def get_elmah_error!(id), do: Repo.get!(ElmahError, id)

  @doc """
  Creates a elmah_error.

  ## Examples

      iex> create_elmah_error(%{field: value})
      {:ok, %ElmahError{}}

      iex> create_elmah_error(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_elmah_error(attrs \\ %{}) do
    %ElmahError{}
    |> ElmahError.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a elmah_error.

  ## Examples

      iex> update_elmah_error(elmah_error, %{field: new_value})
      {:ok, %ElmahError{}}

      iex> update_elmah_error(elmah_error, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_elmah_error(%ElmahError{} = elmah_error, attrs) do
    elmah_error
    |> ElmahError.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a elmah_error.

  ## Examples

      iex> delete_elmah_error(elmah_error)
      {:ok, %ElmahError{}}

      iex> delete_elmah_error(elmah_error)
      {:error, %Ecto.Changeset{}}

  """
  def delete_elmah_error(%ElmahError{} = elmah_error) do
    Repo.delete(elmah_error)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking elmah_error changes.

  ## Examples

      iex> change_elmah_error(elmah_error)
      %Ecto.Changeset{data: %ElmahError{}}

  """
  def change_elmah_error(%ElmahError{} = elmah_error, attrs \\ %{}) do
    ElmahError.changeset(elmah_error, attrs)
  end
end
