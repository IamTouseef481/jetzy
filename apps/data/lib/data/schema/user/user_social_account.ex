defmodule Data.Schema.UserSocialAccount do
  use Data.Schema
  import Ecto.Changeset

  alias Data.Schema.User

  schema "user_social_accounts" do
    field :type, :string
    field :external_id, :string

    belongs_to :user, User

    timestamps()
  end
  @required_fields ~w|
  type
  external_id
  user_id
  |a

  @optional_fields ~w|

    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  @types ~w[facebook google apple]

  @doc false
  def changeset(social_account, attrs) do
    social_account
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @types)
  end

end
