defmodule Data.Schema.ShoutCommentLike do
  @moduledoc """
    The schema for Comment Like
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               user_id: binary,
               comment_id: binary,
               is_liked: binary
             }

  @required_fields ~w|


    |a

  @optional_fields ~w|
    is_liked
    comment_id
    user_id
    inserted_at
    updated_at

    |a

  @all_fields @required_fields ++ @optional_fields

  schema "shoutout_comment_likes" do
    field(:is_liked, :boolean)

    belongs_to :comment, Data.Schema.Comment
    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 541
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
