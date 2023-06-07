defmodule Data.Schema.UserCommentTagged do
  @moduledoc """
    The schema for User comment tagged
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        contact_number: String.t | nil,
        email: String.t | nil,
        flag: boolean,
        parent_id: binary,
        user_id: binary,
        comment_source_id: binary,
        shoutout_id: binary
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    parent_id
    user_id
    comment_source_id
    email
    contact_number
    flag
    shoutout_id
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_comments_tagged" do
    field :contact_number, :string
    field :email, :string
    field :flag, :boolean
#    field :parent_id, :binary

    belongs_to :comment_source, Data.Schema.CommentSource
    belongs_to :user, Data.Schema.User
    belongs_to :parent, Data.Schema.Comment
    belongs_to :shoutout, Data.Schema.UserShoutout

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:comment_source_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:shoutout_id)
    |> foreign_key_constraint(:parent_id)

  end

  @nmid_index 551
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
