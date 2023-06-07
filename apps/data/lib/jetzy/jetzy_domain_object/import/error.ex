#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Import.Error do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "import-error"
  @persistence_layer {JetzySchema.Database, [cascade?: true, sync: true]}
  @persistence_layer {JetzySchema.PG.Repo, [cascade?: true, sync: true]}
  @universal_identifier true
  @auto_generate true
  defmodule Entity do
    use Amnesia
    @nmid_index 304
    require Logger
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :source
      public_field :source_identifier

      public_field :status
      public_field :import_error_type
      public_field :import_error_section
      public_field :error_message, nil, Jetzy.VersionedString.TypeHandler
      public_field :debug_comment, nil, Jetzy.VersionedString.TypeHandler

      public_field :legacy_source
      public_field :legacy_integer_identifier
      public_field :legacy_guid_identifier
      public_field :legacy_string_identifier
      public_field :legacy_sub_identifier

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end

    def new(section, title, error, existing, record)
    def new(section, title, error, existing, %{__struct__: JetzySchema.MSSQL.Post.Table} = record) do
      %Jetzy.Import.Error.Entity{
        import_error_section: section,
        error_message: %{title: title, body: "#[inspect error}\n#{inspect record}"},
        status: :active,
        import_error_type: :text_encoding,
        source: JetzySchema.PG.Post.Table,
        source_identifier: Noizu.ERP.id(existing),
        legacy_source: record.__struct__,
        legacy_integer_identifier: record.id,
        legacy_guid_identifier: record.guid,
        time_stamp: Noizu.DomainObject.TimeStamp.Second.new(DateTime.utc_now()),
      }
    end
    def new(section, title, error, existing, %{__struct__: JetzySchema.MSSQL.User.Table} = record) do
      %Jetzy.Import.Error.Entity{
        import_error_section: section,
        error_message: %{title: title, body: "#[inspect error}\n#{inspect record}"},
        status: :active,
        import_error_type: :text_encoding,
        source: JetzySchema.PG.User.Table,
        source_identifier: Noizu.ERP.id(existing),
        legacy_source: record.__struct__,
        legacy_guid_identifier: record.id,
        time_stamp: Noizu.DomainObject.TimeStamp.Second.new(DateTime.utc_now()),
      }
    end


  end

  defmodule Repo do
    import Ecto.Query, only: [from: 2]
    Noizu.DomainObject.noizu_repo do
    end
  end



end
