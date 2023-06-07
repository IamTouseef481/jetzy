defmodule Data.Context do
  import Ecto.Query, warn: false
  alias Data.Repo

  @spec list(any()) :: list(struct()) | []
  def list(model) do
    Repo.all(model)
  end

  @spec list_ids(any()) :: list(any()) | []
  def list_ids(model) do
    Repo.all(from m in model, select: m.id)
  end

  @spec get!(struct(), binary()) :: struct() | nil
  def get!(model, id), do: Repo.get!(model, id)

  @spec get(struct(), binary()) :: struct() | nil
  def get(model, id), do: Repo.get(model, id)

  @spec get_by(struct(), tuple()) :: struct() | nil
  def get_by(model, args) do
    Repo.get_by(model, args)
  end



  @spec preload_selective(struct() | list(struct()), any) :: any()
  def preload_selective(data, preloads) do
    cond do
      is_list(data) ->
        Task.async_stream(data, fn(datum) ->
          Repo.preload(datum, preloads)
        end) |> Enum.map(fn(x) ->
          case x do
            {:ok, v} -> v
            _ -> nil
          end
        end) |> Enum.filter(&(&1))
      :else -> Repo.preload(data, preloads)
    end
  end
  

  @spec create(struct(), map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def create(model, attrs \\ %{}) do
    struct(model)
    |> model.changeset(attrs)
    |> Repo.insert()
    |> Tanbits.Shim.inject_uir()
  end

  @spec update(struct(), struct(), map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def update(model, data, attrs) do
    data
    |> model.changeset(attrs)
    |> Repo.update()
  end

  @spec delete(struct()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def delete(data) do
    Repo.delete(data)
  end

  @spec change(struct(), struct(), map()) :: Ecto.Changeset.t()
  def change(model, data, attrs \\ %{}) do
    model.changeset(data, attrs)
  end

  def soft_delete_records_by_user_id(_, _, model, user_id) do
    fields = model.__schema__(:fields)
    query =
      model
      |> where([q], q.user_id == ^user_id)
      |> where([q], is_nil(q.deleted_at))
    try do
      if :is_deleted in fields do
        query |> Repo.update_all([set: [deleted_at: DateTime.utc_now(), is_deleted: true]])
      else
        query |> Repo.update_all([set: [deleted_at: DateTime.utc_now]])
      end
      {:ok, :success}
    rescue
      e ->
        {:error, e}
    end
  end

  def soft_delete_records_by_user_id(model, user_id) do
    fields = model.__schema__(:fields)
    query =
      model
      |> where([q], q.user_id == ^user_id)
      |> where([q], is_nil(q.deleted_at))
    try do
      if :is_deleted in fields do
        query |> Repo.update_all([set: [deleted_at: DateTime.utc_now, is_deleted: true]])
      else
        query |> Repo.update_all([set: [deleted_at: DateTime.utc_now]])
      end
      {:ok, :success}
    rescue
      e ->
        {:error, e}
  end
  end
end
