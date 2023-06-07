#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------
defmodule JetzySchema.PG.User.Guid.Lookup.Table do
  @moduledoc """
  table defined in  liquibase/1.0/004_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user_guid_lookup)
  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user_guid_lookup" do
    #  Fields and Secondary Relations
    field :user, JetzySchema.Types.User.Reference
    field :guid, :binary
    field :status, JetzySchema.Types.Status.Enum
  end
end
