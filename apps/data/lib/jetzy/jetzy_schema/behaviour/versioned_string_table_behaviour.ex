defmodule JetzySchema.VersionedStringTableBehaviour do
  defmacro table(table_name, entity, table \\ :auto) do
    table_name = Macro.expand(table_name, __ENV__)
    source_name = "#{table_name}" |> String.replace_prefix("vnext_", "") |> String.to_atom()
    history_table_name = :"#{table_name}_history"
    entity = Macro.expand(entity, __ENV__)
    table = Macro.expand(table, __ENV__)
    quote do
      table = JetzySchema.EnumTableBehaviour.expand_table(unquote(entity), unquote(table))
      history_table = Module.concat(Enum.slice(Module.split(table), 0..-2) ++ ["History", "Table"])
      table_ecto_ref = Module.concat(Enum.slice(Module.split(unquote(entity)), 0..-2) ++ ["Ecto", "UniversalReference"])

      defmodule history_table do
        @table_key unquote(history_table_name)
        @history_table_name unquote(history_table_name)
        @table_ecto_ref table_ecto_ref
        use Ecto.Schema
        require JetzySchema.NoizuTableBehaviour
        JetzySchema.NoizuTableBehaviour.entity_table(unquote(history_table_name))

        @primary_key {:identifier, Ecto.UUID, autogenerate: false}
        @derive {Phoenix.Param, key: :identifier}
        schema "#{unquote(history_table_name)}" do
          #  Fields and Secondary Relations
          field :editor, Noizu.DomainObject.UUID.UniversalReference.Type
          field unquote(source_name), @table_ecto_ref

          field :revision, :integer
          field :title, JetzySchema.Types.Noizu.MarkdownField
          field :body, JetzySchema.Types.Noizu.MarkdownField

          field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
          field :flagged, JetzySchema.Types.Content.Flag.Enum

          #  Standard Time Stamps
          field :modified_on, :utc_datetime_usec
        end
      end


      defmodule table do
        @table_name unquote(table_name)
        @history_table history_table
        use Ecto.Schema
        import Ecto.Query, only: [from: 2]
        require JetzySchema.NoizuTableBehaviour
        JetzySchema.NoizuTableBehaviour.entity_table(unquote(table_name))

        @primary_key {:identifier, Ecto.UUID, autogenerate: false}
        @derive {Phoenix.Param, key: :identifier}
        schema "#{unquote(table_name)}" do
          #  Fields and Secondary Relations
          field :editor, Noizu.DomainObject.UUID.UniversalReference.Type

          field :revision, :integer
          field :title, JetzySchema.Types.Noizu.MarkdownField
          field :body, JetzySchema.Types.Noizu.MarkdownField


          field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
          field :flagged, JetzySchema.Types.Content.Flag.Enum

          #  Standard Time Stamps
          field :modified_on, :utc_datetime_usec
        end

        def delete_history(versioned_string, context, options \\ nil) do
          ref = Noizu.ERP.ref(versioned_string)
          delete_query = from h in @history_table,
                              where: h.unquote(table_name) == ^ref
          JetzySchema.PG.Repo.delete_all(delete_query)
        end

      end



    end
  end


end
