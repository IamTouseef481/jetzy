defmodule Jetzy.DomainObject.Schema do
  require Noizu.DomainObject
  require Logger
  alias Noizu.DomainObject.SchemaInfo.Default, as: Provider

  Noizu.DomainObject.noizu_schema_info(app: :data, base_prefix: Jetzy, database_prefix: JetzySchema.PG) do
    @cache_keys %{
      mssql_tables: :"__nzss__#{@app}__mssql",
      pg_tables: :"__nzss__#{@app}__pg",
      mnesia_tables: :"__nzss__#{@app}__mnesia",
      legacy_indexes: :"__nzss__#{@app}__legacy_indexes",
    }


    def sref_map() do
      case FastGlobal.get(:merged_sref_map, :cache_miss) do
        :cache_miss ->
          map = __noizu_info__(:sref_map)
          map2 = __noizu_info__(:tanbits_sref_map)
          cache = Map.merge(map, map2)
          FastGlobal.put(:merged_sref_map, cache)
          cache
        cache_hit -> cache_hit
      end
    end

    def nmid_keys(), do: __noizu_info__(:nmid_indexes)
    def legacy_tables(), do: __noizu_info__(:mssql_tables)


    def __noizu_info__(:mssql_tables = property) do
      Provider.cached_filter(@cache_keys[property], :data, JetzySchema.MSSQL, MapSet.new([:table, :entity_table, :enum_table]))
    end

    def __noizu_info__(:pg_tables = property) do
      Provider.cached_filter(@cache_keys[property], :data, JetzySchema.PG, MapSet.new([:table, :entity_table, :enum_table]))
    end

    def __noizu_info__(:tanbits_entity = property) do
      Provider.cached_filter(@cache_keys[property], :data, Data.Schema, :tanbits)
    end

    def __noizu_info__(:tanbits_sref_map = _property) do
      case FastGlobal.get(:tanbits_sref_map, :cache_miss) do
        :cache_miss ->
          entities = __noizu_info__(:tanbits_entity)
          cache = Enum.map(entities, &({&1.__noizu_info__(:sref_module), &1})) |> Map.new()
          FastGlobal.put(:tanbits_sref_map, cache)
          cache
        cache_hit -> cache_hit
      end
    end

    def __noizu_info__(:mnesia_tables = property) do
      Provider.cached_filter(@cache_keys[property], :data, JetzySchema.Database)
    end

    def __noizu_info__(:legacy_indexes) do
      key = :__nzss__legacy_indexes_q
      case FastGlobal.get(key, :cache_miss) do
        :cache_miss ->
          tables = __noizu_info__(:mssql_tables)
          cache = Enum.map(tables, &({&1, &1.__nmid__(:index)})) |> Map.new()
          FastGlobal.put(key, cache)
          cache
        cache_hit -> cache_hit
      end
    end
  end

  def __ecto_source_atom_to_enum__() do
    key = :__nzss__ecto_source_atom_to_enum
    case FastGlobal.get(key, :cache_miss) do
      :cache_miss ->
        tables = __noizu_info__(:pg_tables)
        tables = tables ++ __noizu_info__(:tanbits_entity)
        tables = tables ++ (Jetzy.DomainObject.Schema.__noizu_info__(:entities) |> Enum.filter(&(&1.__persistence__(:schemas)[JetzySchema.PG.Repo] == nil)))
        cache = Enum.map(tables, &({&1, &1.__nmid__(:index)})) |> Map.new()
        FastGlobal.put(key, cache)
        cache
      cache_hit -> cache_hit
    end
  end

  def __ecto_source_enum_to_atom__() do
    key = :__nzss__ecto_source_enum_to_atom
    case FastGlobal.get(key, :cache_miss) do
      :cache_miss ->
        tables = __ecto_source_atom_to_enum__()
        cache = Enum.map(tables, fn({a,e}) ->  {e, a} end) |> Map.new()
        FastGlobal.put(key, cache)
        cache
      cache_hit -> cache_hit
    end
  end

  def __ecto_source_json_to_atom__() do
    key = :__nzss__ecto_source_json_to_atom
    case FastGlobal.get(key, :cache_miss) do
      :cache_miss ->
        tables = __ecto_source_atom_to_enum__()
        cache = Enum.map(tables, fn({a,_e}) ->  {Enum.slice(a, 7..-1), a} end) |> Map.new()
        FastGlobal.put(key, cache)
        cache
      cache_hit -> cache_hit
    end
  end


  def __legacy_source_atom_to_enum__() do
    key = :__nzss__legacy_source_atom_to_enum
    case FastGlobal.get(key, :cache_miss) do
      :cache_miss ->
        tables = __noizu_info__(:mssql_tables)
        cache = Enum.map(tables, &({&1, &1.__nmid__(:index)})) |> Map.new()
        FastGlobal.put(key, cache)
        cache
      cache_hit -> cache_hit
    end
  end

  def __legacy_source_enum_to_atom__() do
    key = :__nzss__legacy_source_enum_to_atom
    case FastGlobal.get(key, :cache_miss) do
      :cache_miss ->
        tables = __legacy_source_atom_to_enum__()
        cache = Enum.map(tables, fn({a,e}) ->  {e, a} end) |> Map.new()
        FastGlobal.put(key, cache)
        cache
      cache_hit -> cache_hit
    end
  end

  def __legacy_source_json_to_atom__() do
    key = :__nzss__legacy_source_json_to_atom
    case FastGlobal.get(key, :cache_miss) do
      :cache_miss ->
        tables = __legacy_source_atom_to_enum__()
        cache = Enum.map(tables, fn({a,_e}) ->  {Enum.slice(a, 7..-1), a} end) |> Map.new()
        FastGlobal.put(key, cache)
        cache
      cache_hit -> cache_hit
    end
  end


  def __tanbits_source_atom_to_enum__() do
    key = :__nzss__tanbits_source_atom_to_enum
    case FastGlobal.get(key, :cache_miss) do
      :cache_miss ->
        tables = __noizu_info__(:tanbits_entity)
        cache = Enum.map(tables, &({&1, &1.__nmid__(:index)})) |> Map.new()
        FastGlobal.put(key, cache)
        cache
      cache_hit -> cache_hit
    end
  end

  def __tanbits_source_enum_to_atom__() do
    key = :__nzss__tanbits_source_enum_to_atom
    case FastGlobal.get(key, :cache_miss) do
      :cache_miss ->
        tables = __tanbits_source_atom_to_enum__()
        cache = Enum.map(tables, fn({a,e}) ->  {e, a} end) |> Map.new()
        FastGlobal.put(key, cache)
        cache
      cache_hit -> cache_hit
    end
  end

  def __tanbits_source_json_to_atom__() do
    key = :__nzss__tanbits_source_json_to_atom
    case FastGlobal.get(key, :cache_miss) do
      :cache_miss ->
        tables = __tanbits_source_atom_to_enum__()
        cache = Enum.map(tables, fn({a,_e}) ->  {Enum.slice(a, 7..-1), a} end) |> Map.new()
        FastGlobal.put(key, cache)
        cache
      cache_hit -> cache_hit
    end
  end

  def __framework_table_nmid_index_list__() do
    %{
      Noizu.EmailService.V3.Email.Queue.Entity => 9000,
      Noizu.EmailService.V3.Email.Queue.Event.Entity => 9001,
      Noizu.SmartToken.V3.Token.Entity => 9050,
    }
  end
  

  @doc """
    Note,must stay in sync with UniversalIdentifierResolution.Source.Enum.Entity
  """
  def __nmid_index_list__() do
    key = :__nzss__nmid_q
    case FastGlobal.get(key, :cache_miss) do
      :cache_miss ->
        tables = __noizu_info__(:pg_tables) ++ __noizu_info__(:entities) ++ __noizu_info__(:tanbits_entity)
        cache = Enum.map(tables, &({&1, &1.__nmid__(:index)}))
                |> Map.new()
                |> Map.merge(__framework_table_nmid_index_list__())
        FastGlobal.put(key, cache)
        cache
      cache_hit -> cache_hit
    end
  end
  
  def parse_sref(sref) do
    cond do
      Regex.match?(~r/^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$/, sref) ->
        Enum.find_value(__noizu_info__(:tanbits_entity), fn(entity) ->
          v = entity.entity!(sref)
          v && entity.ref(sref)
        end
        )
      :else -> super(sref)
    end
  end

  def __refresh_enums__(context, options \\ nil) do
    Enum.map(__MODULE__.enums(), &(__refresh_enum__(&1, context, options)))
  end
  def __refresh_enum__(entity, context, options \\ nil)
  def __refresh_enum__(entity = Jetzy.User.Notification.Type.Entity, context, options) do
    []
  end
  def __refresh_enum__(entity = Jetzy.Locale.Language.Enum.Entity, context, options) do
    # replace base/repo/etc. with entity struct.
    base = entity.__base__()
    entity = entity.__entity__()
    repo = entity.__repo__()
    now = options[:current_time] || DateTime.utc_now
    entities = Enum.map(
      base.atoms(),
      fn ({atom, identifier}) ->
        Logger.info "REFRESHING: #{atom} . . ."
        cond do
          existing = repo.get!(identifier, context, options[:get]) ->
            existing
          :else ->
            struct(
              entity,
              [
                identifier: identifier,
                description: %{
                  title: "#{atom}",
                  body: entity.__enum__(:type).description(atom)
                },
                iso_639_code: "#{atom}",
                time_stamp: %{
                  created_on: now,
                  modified_on: now,
                  deleted_on: nil
                }
              ]
            )
            |> repo.create!(context, options[:create])
        end
      end
    )

    max = Enum.map(base.atoms(), &(elem(&1, 1)))
          |> Enum.max()
    repo.__nmid__(:generator).set_incr(repo.__nmid__(:sequencer), max)

    entities
  end

  def __refresh_enum__(entity = Jetzy.Locale.Country.Enum.Entity, context, options) do
    # replace base/repo/etc. with entity struct.
    base = entity.__base__()
    entity = entity.__entity__()
    repo = entity.__repo__()
    now = options[:current_time] || DateTime.utc_now
    entities = Enum.map(
      base.atoms(),
      fn ({atom, identifier}) ->
        cond do
          existing = repo.get!(identifier, context, options[:get]) ->
            existing
          :else ->
            struct(
              entity,
              [
                identifier: identifier,
                description: %{
                  title: "#{atom}",
                  body: entity.__enum__(:type).description(atom)
                },
                iso_3166_code: "#{atom}",
                time_stamp: %{
                  created_on: now,
                  modified_on: now,
                  deleted_on: nil
                }
              ]
            )
            |> repo.create!(context, options[:create])
        end
      end
    )

    max = Enum.map(base.atoms(), &(elem(&1, 1)))
          |> Enum.max()
    repo.__nmid__(:generator).set_incr(repo.__nmid__(:sequencer), max)

    entities
  end

  def __refresh_enum__(entity, context, options) do
    # replace base/repo/etc. with entity struct.
    base = entity.__base__()
    entity = entity.__entity__()
    repo = entity.__repo__()
    now = options[:current_time] || DateTime.utc_now
    entities = Enum.map(
      base.atoms(),
      fn ({atom, identifier}) ->
        :ok = entity.__persistence__[:schemas][JetzySchema.Database].table.wait(5000)
        cond do
          existing = repo.get!(identifier, context, options[:get]) ->
            existing
          :else ->
            struct(
              entity,
              [
                identifier: atom,
                description: %{
                  title: "#{atom}",
                  body: entity.__enum__(:type).description(atom)
                },
                time_stamp: %{
                  created_on: now,
                  modified_on: now,
                  deleted_on: nil
                }
              ]
            )
            |> repo.create!(context, options[:create])
            Process.sleep(200)
        end
      end
    )

    max = Enum.map(base.atoms(), &(elem(&1, 1)))
          |> Enum.max()
    repo.__nmid__(:generator).set_incr(repo.__nmid__(:sequencer), max)

    entities
    rescue error ->
      Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{Exception.format(:error, error, __STACKTRACE__)}")
      error
    catch error ->
    Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{Exception.format(:error, error, __STACKTRACE__)}")
    error
  end

  def generate_code_snippet(:nmid_array, clean \\ false) do
    existing = clean && %{} || Jetzy.DomainObject.Schema.nmid_keys()
    cut_off = Enum.max(Map.values(existing) ++ [0])

    tables = Jetzy.DomainObject.Schema.__noizu_info__(:tables)
    entities = Jetzy.DomainObject.Schema.__noizu_info__(:entities)
    non_entity_tables = tables -- Enum.map(
      entities,
      fn (s) ->
        r = s.__persistence__(:schemas)[JetzySchema.PG.Repo]
        r && r.table
      end
                        )
                        |> Enum.filter(&(&1))

    entities = entities -- Map.keys(existing)
    non_entity_tables = non_entity_tables -- Map.keys(existing)

    {entities, index} = Enum.map_reduce(
      entities,
      cut_off + 1,
      fn (s, acc) ->
        case s.__persistence__(:schemas)[JetzySchema.PG.Repo] do
          %{table: table} ->
            {[{s, acc}, {table, acc}], acc + 1}
          _ ->
            {[{s, acc}], acc + 1}
        end
      end
    )
    entities = List.flatten(entities)
    {append, _index} = Enum.map_reduce(non_entity_tables, index, fn (s, acc) -> {{s, acc}, acc + 1} end)

    output = existing
             |> Enum.sort(&(elem(&1, 1) < elem(&2, 1)))
    existing_gen = Enum.map(
                     output,
                     fn ({s, i}) ->
                       "#{s} => #{i},"
                     end
                   )
                   |> Enum.join("\n")
    output = (entities ++ append)
             |> Enum.sort(&(elem(&1, 1) < elem(&2, 1)))
    gen = cond do
            length(output) > 0 ->
              new_gen = Enum.map(
                          output,
                          fn ({s, i}) ->
                            "#{s} => #{i},"
                          end
                        )
                        |> Enum.join("\n")
              existing_gen <> "# New Records #{
                DateTime.utc_now()
                |> DateTime.to_iso8601()
              }\n" <> new_gen
            :else ->
              existing_gen <> "# No Additional Records #{
                DateTime.utc_now()
                |> DateTime.to_iso8601()
              }\n"
          end
    File.mkdir_p!("_build/gen")
    File.write!("_build/gen/nmid_indexes.gen", "@nmid_indexes %{\n" <> gen <> "\n}")

    atom_to_enum = (
                     Enum.filter(
                       output,
                       fn ({m, _a}) ->
                         String.ends_with?("#{m}", ".Table")
                       end
                     ))
                   |> Enum.map(
                        fn ({s, i}) ->
                          "{#{s}, #{i}},"
                        end
                      )
                   |> Enum.join("\n")


    enum_to_atom = (
                     Enum.filter(
                       output,
                       fn ({m, _a}) ->
                         String.ends_with?("#{m}", ".Table")
                       end
                     ))
                   |> Enum.map(
                        fn ({s, i}) ->
                          "{#{i}, #{s}},"
                        end
                      )
                   |> Enum.join("\n")


    json_to_atom = (
                     Enum.filter(
                       output,
                       fn ({m, _a}) ->
                         String.ends_with?("#{m}", ".Table")
                       end
                     ))
                   |> Enum.map(
                        fn ({s, _i}) ->
                          "{\"#{
                            Atom.to_string(s)
                            |> String.slice(7..-1)
                          }\", #{s}},"
                        end
                      )
                   |> Enum.join("\n")


    content = """

    def atom_to_enum() do
    [
    #{atom_to_enum}
    ]
    end
    def atom_to_enum(k), do: atom_to_enum()[k]

    def enum_to_atom() do
    [
    #{enum_to_atom}
    ]
    end
    def enum_to_atom(k), do: enum_to_atom()[k]

    def json_to_atom() do
    [
    #{json_to_atom}
    ]
    end
    def json_to_atom(k), do: json_to_atom()[k]

    """




    File.write!("_build/gen/universal_identifier_sources.gen", content)
  end



end

#--------------------------------
#
#--------------------------------
defimpl Noizu.ERP, for: BitString do
  def ref(sref), do: Jetzy.DomainObject.Schema.parse_sref(sref)
  def id(sref),
      do: ref(sref)
          |> Noizu.ERP.id()
  def sref("ref." <> _ = sref), do: sref
  def sref(sref) when is_bitstring(sref) do
    Regex.match?(~r/^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$/, sref) && Jetzy.DomainObject.Schema.parse_sref(sref) |> Noizu.ERP.sref()
  end
  def sref(_), do: nil

  def entity(sref, options \\ nil) do
    cond do
      Regex.match?(~r/^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$/, sref) ->
        Enum.find_value(Jetzy.DomainObject.Schema.__noizu_info__(:tanbits_entity), fn(entity) ->
          entity.entity(sref)
        end
        )
      :else -> Noizu.ERP.entity(ref(sref), options)
    end
  end

  def entity!(sref, options \\ nil) do
    cond do
      Regex.match?(~r/^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$/, sref) ->
        Enum.find_value(Jetzy.DomainObject.Schema.__noizu_info__(:tanbits_entity), fn(entity) ->
          entity.entity!(sref)
        end
        )
      :else -> Noizu.ERP.entity!(ref(sref), options)
    end
  end
  def record(sref, options \\ nil) do
    cond do
      Regex.match?(~r/^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$/, sref) ->
        Enum.find_value(Jetzy.DomainObject.Schema.__noizu_info__(:tanbits_entity), fn(entity) ->
          entity.record(sref)
        end
        )
      :else -> Noizu.ERP.record(ref(sref), options)
    end
  end
  def record!(sref, options \\ nil) do
    cond do
      Regex.match?(~r/^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$/, sref) ->
        Enum.find_value(Jetzy.DomainObject.Schema.__noizu_info__(:tanbits_entity), fn(entity) ->
          entity.record!(sref)
        end
        )
      :else -> Noizu.ERP.record!(ref(sref), options)
    end
  end



  def id_ok(o) do
    r = id(o)
    r && {:ok, r} || {:error, o}
  end
  def ref_ok(o) do
    r = ref(o)
    r && {:ok, r} || {:error, o}
  end
  def sref_ok(o) do
    r = sref(o)
    r && {:ok, r} || {:error, o}
  end
  def entity_ok(o, options \\ %{}) do
    r = entity(o, options)
    r && {:ok, r} || {:error, o}
  end
  def entity_ok!(o, options \\ %{}) do
    r = entity!(o, options)
    r && {:ok, r} || {:error, o}
  end

end
