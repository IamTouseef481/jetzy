defmodule JetzySchema.EnumTableBehaviour do

  defmacro table(table_name, entity, table \\ :auto) do
    entity = Module.concat([Macro.expand(entity, __ENV__), Entity])
    table = Macro.expand(table, __ENV__)
    quote do
      table = JetzySchema.EnumTableBehaviour.expand_table(unquote(entity), unquote(table))
      defmodule table do
        use Ecto.Schema
        require JetzySchema.NoizuTableBehaviour
        JetzySchema.NoizuTableBehaviour.enum_table(unquote(table_name), [entity: unquote(entity)])

        @primary_key {:identifier, :id, autogenerate: false}
        @derive {Phoenix.Param, key: :identifier}
        schema "#{unquote(table_name)}" do
          field :description, Jetzy.VersionedString.Ecto.UniversalReference

          #  Standard Time Stamps
          field :created_on, :utc_datetime
          field :modified_on, :utc_datetime
          field :deleted_on, :utc_datetime
        end

      end
    end
  end

  def expand_table(m, :auto) do
    b = Enum.slice(Module.split(m), 1..-2)
    Module.concat(["JetzySchema", "PG"] ++ b ++ ["Table"])
  end
  def expand_table(_, v), do: v

end
