defmodule Data.Schema.InfluencerMessage do
  @moduledoc """
    The schema for Status
  """
  use Data.Schema
  import Ecto.Query
  alias Data.Repo
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               message: String.t | nil,
               type: String.t | nil,
               category: String.t | nil,
               deleted_at: DateTime.t | nil,
               inserted_at: DateTime.t | nil,
               updated_at: DateTime.t | nil
             }

  @required_fields ~w|
    message
    type
  |a

  @optional_fields ~w|
    category
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "influencer_messages" do
    field :message, :string
    field :type, Ecto.Enum, values: [:caption, :comment]
    field :category, :string
    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:message, :type, :category], name: :uniq_influencer_messages)
    |> verify_influencer_message()
  end

  def verify_influencer_message(%Ecto.Changeset{changes: %{message: message, type: :caption}} = changeset) do
    case Data.Context.get_by(__MODULE__, [message: message, type: :caption]) do
      nil -> changeset
      _ -> Map.put(changeset, :valid?, false) |> add_error(:caption, "has already been taken")
    end
  end

  def verify_influencer_message(%Ecto.Changeset{changes: %{message: message, type: :comment, category: _catergory}} = changeset) do
    changeset
  end

  def verify_influencer_message(%Ecto.Changeset{changes: %{message: message, type: :comment}} = changeset) do
    case get_comment_by_message_and_type(message, :comment) do
      nil -> changeset
      _ -> Map.put(changeset, :valid?, false) |> add_error(:message, "has already been taken")
    end
  end

  def get_comment_by_message_and_type(message, type) do
    __MODULE__
    |> where([im], im.message == ^message and im.type == ^type and is_nil(im.category))
    |> limit(1)
    |> Repo.one()
  end


  @nmid_index 617
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
