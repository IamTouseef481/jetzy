defmodule Data.Schema.Comment do
  @moduledoc """
    The schema for Comment
  """
  use Data.Schema
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
       id: binary,
       deleted_at: DateTime.t | nil,
       description: String.t | nil,
       is_deleted: boolean | nil,
       updated_by_id: binary | nil,
       user_id: binary,
       parent_id: binary,
       shoutout_id: binary,
   }

  @required_fields ~w|
    
  |a

  @optional_fields ~w|
    deleted_at
    comment_source_id
    user_id
    description
    parent_id
    shoutout_id
    is_deleted
    updated_by_id
    inserted_at
    updated_at
    
  |a

  @all_fields @required_fields ++ @optional_fields

  
  schema "comments" do
    field :description, :string
    field :is_deleted, :boolean
#    field :updated_by, :binary

    belongs_to :comment_source, Data.Schema.CommentSource
    belongs_to :user, Data.Schema.User
    belongs_to :parent, Data.Schema.Comment
    belongs_to :shoutout, Data.Schema.UserShoutout
    belongs_to :updated_by, Data.Schema.User


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 508
  use Data.Schema.TanbitsEntity, sref: "t-comment"

end