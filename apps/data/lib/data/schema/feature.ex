defmodule Data.Schema.Feature do
  @moduledoc """
    The schema for trackable/grant-able feature. view_post, submit_post, view_user, submit_message, follow_user, message_user, message_group ...
  """
  use Data.Schema
  
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               name: String.t,
               handle: String.t,
               description: String.t,
               inserted_at: DateTime.t,
               updated_at: DateTime.t,
               deleted_at: DateTime.t
             }

  @all_fields ~w|
    name
    handle
    description
    inserted_at
    updated_at
    deleted_at
  |a

  @required_fields ~w|
    name
    handle
    description
    inserted_at
    updated_at
  |a


  schema "feature" do
    field :name, :string
    field :handle, :string
    field :description, :string
    timestamp()
  end
  
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
  
  @nmid_index 606
  use Data.Schema.TanbitsEntity, sref: "t-feature"
end