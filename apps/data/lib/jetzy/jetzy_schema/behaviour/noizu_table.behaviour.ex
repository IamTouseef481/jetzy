defmodule JetzySchema.NoizuTableBehaviour do

  def import_common_ecto_types() do
    quote do
    end
  end

  defmacro mssql_table(ecto_table, options \\ nil) do
    #options = Macro.expand(options, __ENV__)
    options = (options || [])
              |> put_in([:ecto_table], ecto_table)
              |> update_in([:entity], &(&1 || false))
              |> put_in([:repo], JetzySchema.MSSQL.Repo)
              |> update_in([:nmid_source], &(&1 || :legacy_indexes))

    JetzySchema.NoizuTableBehaviour.import_common_ecto_types()
    Noizu.AdvancedScaffolding.Internal.DomainObject.Table.__noizu_table__(__CALLER__, options)
  end

  defmacro table(ecto_table, options \\ nil) do
    options = Macro.expand(options, __ENV__)
    options = (options || [])
              |> put_in([:ecto_table], ecto_table)
              |> update_in([:entity], &(&1 || false))
              |> put_in([:repo], JetzySchema.PG.Repo)
    JetzySchema.NoizuTableBehaviour.import_common_ecto_types()
    Noizu.AdvancedScaffolding.Internal.DomainObject.Table.__noizu_table__(__CALLER__, options)
  end

  defmacro enum_table(ecto_table, options \\ nil) do
    options = Macro.expand(options, __ENV__)
    options = (options || [])
              |> put_in([:ecto_table], ecto_table)
              |> put_in([:repo], JetzySchema.PG.Repo)
    JetzySchema.NoizuTableBehaviour.import_common_ecto_types()
    Noizu.AdvancedScaffolding.Internal.DomainObject.Table.__noizu_table__(__CALLER__, options)
  end

  defmacro entity_table(ecto_table, options \\ nil) do
    options = Macro.expand(options, __ENV__)
    options = (options || [])
              |> put_in([:ecto_table], ecto_table)
              |> put_in([:repo], JetzySchema.PG.Repo)
    JetzySchema.NoizuTableBehaviour.import_common_ecto_types()
    Noizu.AdvancedScaffolding.Internal.DomainObject.Table.__noizu_table__(__CALLER__, options)
  end

end
