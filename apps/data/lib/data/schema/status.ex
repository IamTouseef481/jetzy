defmodule Data.Schema.Status do
  @moduledoc """
    The schema for Status
  """
  use Data.Schema
  import Ecto.Query
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        status: String.t | nil,

    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    status
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "statuses" do
    field :status, :string


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  def by_atom(atom) do
    s = Macro.camelize("#{atom}")
    query = from u in Data.Schema.Status,
                 where: u.status == ^s
    case Data.Repo.all(query) do
      [h|_] -> h
      _ -> nil
    end
  end

  @nmid_index 544
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
