defmodule Data.Schema.CommentReply do
  @moduledoc """
    The schema for Comment reply
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        parent_comment_id: binary,
        child_comment_id: binary,

    }

  @required_fields ~w|
    
  |a

  @optional_fields ~w|
    deleted_at
    parent_comment_id
    child_comment_id
    inserted_at
    updated_at
    
  |a

  @all_fields @required_fields ++ @optional_fields

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  schema "comment_replies" do

    belongs_to :parent_comment, Data.Schema.Comment
    belongs_to :child_comment, Data.Schema.Comment

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 603
  use Data.Schema.TanbitsEntity, sref: "t-comment-reply"

end