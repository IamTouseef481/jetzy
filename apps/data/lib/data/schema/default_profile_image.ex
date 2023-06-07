defmodule Data.Schema.DefaultProfileImage do
    @moduledoc """
      The schema for Like source
    """
    use Data.Schema

    @derive Noizu.ERP
  @derive Tanbits.Shim
    @derive Noizu.EctoEntity.Protocol
    @type t :: %__MODULE__{
          id: binary,
          deleted_at: DateTime.t | nil,
          small_image_name: String.t | nil,
          image_name: String.t | nil,
          blur_hash: String.t | nil,
          image_identifier: integer | nil,
      }

    @required_fields ~w|
        image_name
    |a

    @optional_fields ~w|
      small_image_name
      deleted_at
      inserted_at
      updated_at
      blur_hash
      image_identifier
    |a

    @all_fields @required_fields ++ @optional_fields


    schema "default_profile_images" do
      field :image_name, :string
      field :blur_hash, :string
      field :small_image_name, :string
      field :image_identifier, :integer
      timestamp()
    end

    def changeset(model, params \\ %{}) do
      model
      |> cast(params, @all_fields)
      |> validate_required(@required_fields)
    end

    @nmid_index 511
    use Data.Schema.TanbitsEntity, sref: "t-user"
  end
