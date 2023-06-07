defmodule Data.Schema.FrequentlyAskedQuestion do
  @moduledoc """
    The schema for User referral
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        question: String.t | nil,
        answer: String.t | nil,
        category: String.t | nil,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    question
    answer
    category
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "frequently_asked_questions" do
    field :question, :string
    field :answer, :string
    field :category, :string

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 515
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
