defprotocol Tanbits.Shim do
  @fallback_to_any true

  def inject_uir(v)
end

defimpl Tanbits.Shim, for: Any do
  defmacro __deriving__(module, _struct, _options) do
    quote do
      defimpl Tanbits.Shim, for: unquote(module) do
        def inject_uir(v), do: unquote(module).inject_uir(v)
      end
    end
  end

  def inject_uir(v), do: v
end

defimpl Tanbits.Shim, for: Tuple do
  def inject_uir({:ok, v}), do: {:ok, Tanbits.Shim.inject_uir(v)}
  def inject_uir(v), do: v
end

defmodule Data.Schema.TanbitsEntity do

  defmacro __using__(opts) do
    sref_name = opts[:sref] || raise "sref required when using Data.Schema.TanbitsEntity"
    sref_base = "ref.#{sref_name}."

    quote do
      @sref_base unquote(sref_base)

      def __tanbits_noizu__, do: true

      def id(%__MODULE__{id: id}), do: id
      def id({:ref, __MODULE__, id}), do: id
      def id(@sref_base <> id), do: id
      def id(id) when is_bitstring(id), do: id
      def id(_), do: nil

      def id_ok(ref) do
        v = id(ref)
        v && {:ok, v} || {:error, {:invalid, ref}}
      end
      
      
      @doc "Cast to noizu reference object"
      def ref(%__MODULE__{id: id}), do: {:ref, __MODULE__, id}
      def ref({:ref, __MODULE__, id}), do: {:ref, __MODULE__, id}
      def ref(@sref_base <> id), do: {:ref, __MODULE__, id}
      def ref(id) when is_bitstring(id), do: {:ref, __MODULE__, id}
      def ref(_), do: nil

      def ref_ok(ref) do
        v = ref(ref)
        v && {:ok, v} || {:error, {:invalid, ref}}
      end
      
      @doc "Cast to noizu string reference object"
      def sref(%__MODULE__{id: id}), do: @sref_base <> id
      def sref({:ref, __MODULE__, id}), do: @sref_base <> id
      def sref(@sref_base <> id), do: @sref_base <> id
      def sref(id) when is_bitstring(id), do: @sref_base <> id
      def sref(_), do: nil

      def sref_ok(ref) do
        v = sref(ref)
        v && {:ok, v} || {:error, {:invalid, ref}}
      end
      
      @doc "Convert to persistence object. Options may be passed to coordinate actions like expanding embedded references."
      def record(obj, context \\ nil, options \\ %{})
      def record(%__MODULE__{} = record, _context, _options), do: record
      def record({:ref, __MODULE__, id}, _context, _options) do
        case Data.Repo.get(__MODULE__, id) do
          record = %__MODULE__{} -> record
          _ -> nil
        end
      end
      def record(@sref_base <> id, _context, _options), do: record(ref(id))
      def record(id, _context, _options) when is_bitstring(id), do: record(ref(id))
      def record(_, _context, _options), do: nil

      @doc "Convert to persistence object Options may be passed to coordinate actions like expanding embedded references. (With transaction wrapper if required)"
      def record!(obj, context \\ nil, options \\ %{}), do: record(obj, context, options)

      @doc "Convert to scaffolding.struct object. Options may be passed to coordinate actions like expanding embedded references."
      def entity(obj, context \\ nil, options \\ %{}), do: record(obj, context, options)

      def entity_ok(ref) do
        v = entity(ref)
        v && {:ok, v} || {:error, {:invalid, ref}}
      end
      
      @doc "Convert to scaffolding.struct object Options may be passed to coordinate actions like expanding embedded references. (With transaction wrapper if required)"
      def entity!(obj, context \\ nil, options \\ %{}), do: record(obj, context, options)

      def entity_ok!(ref) do
        v = entity!(ref)
        v && {:ok, v} || {:error, {:invalid, ref}}
      end
      
      def __noizu_info__(:type), do: :tanbits
      def __noizu_info__(:entity), do: __MODULE__
      def __noizu_info__(:sref_module), do: unquote(sref_name)

      def ecto_identifier(identifier), do: id(identifier)

      def universal_identifier(identifier) do
          ref = ref(identifier)
        case ref && JetzySchema.Database.UniversalIdentifierResolution.Table.match!([ref: ref]) |> Amnesia.Selection.values() do
          [v|_] -> v.identifier
          _ ->
            identifier = Data.Schema.User.id(identifier)
            case identifier && JetzySchema.PG.Repo.get_by(JetzySchema.PG.UniversalIdentifierResolution.Table, [source_uuid: identifier]) do
              %JetzySchema.PG.UniversalIdentifierResolution.Table{identifier: identifier} -> identifier
              _ -> nil
            end
        end
      end


      def source(_), do: __MODULE__
      def __nmid__(:bare), do: false
      def __nmid__(:index), do: @nmid_index
      def __erp__(), do: __MODULE__
      def ecto_entity?, do: true

      def __schema_table__(), do: String.to_atom(__MODULE__.__schema__(:source))

      def inject_uir(m) do
        if Application.get_env(:data, :tanbits_shim)[:enable_shim] && m do
            %Jetzy.UniversalIdentifierResolution.Entity{identifier: m.id , ref: Noizu.ERP.ref(m)}
            |> Jetzy.UniversalIdentifierResolution.Repo.create!(Noizu.ElixirCore.CallingContext.system())
        end
        m
      end

      @__generated_always_fields Module.get_attribute(__MODULE__, :generated_fields, [])
      def __extended_schema__(:generated_fields) do
        @__generated_always_fields
      end
      
      
      defoverridable [
        id: 1,
        ref: 1,
        sref: 1,
        entity: 1,
        entity: 2,
        entity!: 1,
        entity!: 2,
        record: 1,
        record: 2,
        record!: 1,
        record!: 2,
        __noizu_info__: 1,
        ecto_identifier: 1,
        universal_identifier: 1,
        source: 1,
        __nmid__: 1,
        inject_uir: 1,
        __extended_schema__: 1,
      ]

    end
  end



end