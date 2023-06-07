defmodule Data.Schema.UserChatSession do
  @moduledoc """
    The schema for User chat session
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        last_chat_date: :date,
        first_user_id: binary,
        second_user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    first_user_id
    second_user_id
    last_chat_date
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_chat_sessions" do
    field :last_chat_date, :date

    belongs_to :first_user, Data.Schema.User
    belongs_to :second_user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 550
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
