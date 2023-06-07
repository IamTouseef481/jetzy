defmodule JetzySchema.Type.EnumTypeBehaviour do

  defmacro __using__(options \\ nil) do
    #options = Macro.expand(options, __ENV__)
    enum_source = Macro.escape(options[:source])
    quote do
      require Noizu.DomainObject
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      #@enum_source Module.get_attribute(__MODULE__, :enum_source)
      @sphinx_bits unquote(options[:bits]) || Module.get_attribute(__MODULE__, :sphinx_bits) || 8
      @sphinx_encoding unquote(options[:encoding]) || Module.get_attribute(__MODULE__, :sphinx_encoding) || :attr_uint

      @__nzdo_enum_source Module.get_attribute(__MODULE__, :enum_source)
      defp __enum_source__(), do: (Macro.expand(unquote(enum_source), __ENV__) || @__nzdo_enum_source)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      use Ecto.Type

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      Noizu.DomainObject.noizu_sphinx_handler()

      #===------
      #
      #===------
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def __search_clauses__(_index, {field, _settings}, conn, params, _context, options) do
        search = case field do
                   {p, f} -> "#{p}.#{f}"
                   _ -> "#{field}"
                 end
        case Noizu.AdvancedScaffolding.Helpers.extract_setting(:extract, search, conn, params, nil, options) do
          {source, v} when source in [:query_param, :body_param, :params, :default] and is_bitstring(v) ->
              atoms = Enum.split(v, ",")
                      |> Enum.map(&(String.trim(&1)))
                      |> Enum.filter(&(&1 != ""))
                      |> Enum.map(&(json_to_atom(&1)))
                      |> Enum.filter(&(&1))
                      |> Enum.map(&(atom_to_enum(&1)))
              cond do
                length(atoms) > 0 ->
                  param = String.replace(search, ".", "_")
                  atoms = Enum.join(atoms, ", ")
                  {:where, param, "#{param} in (#{atoms})"}
                :else -> nil
              end
          {source, v} when source in [:body_param, :default] and is_list(v) ->
            atoms = v
                    |> Enum.filter(&(is_bitstring(&1)))
                    |> Enum.map(&(String.trim(&1)))
                    |> Enum.filter(&(&1 != ""))
                    |> Enum.map(&(json_to_atom(&1)))
                    |> Enum.filter(&(&1))
                    |> Enum.map(&(atom_to_enum(&1)))
            cond do
              length(atoms) > 0 ->
                param = String.replace(search, ".", "_")
                atoms = Enum.join(atoms, ", ")
                {:where, param, "#{param} in (#{atoms})"}
              :else -> nil
            end
          _ -> nil
        end
      end


      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def __sphinx_has_default__(_field, _indexing, _settings), do: true

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def __sphinx_default__(_field, _indexing, _settings), do: __enum_source__().default_value()

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def __sphinx_encoded__(field, entity, _indexing, _settings) do
        atom = get_in(entity, [Access.key(field)])
        atom && __enum_source__().atom_to_enum(atom)
      end

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def type(), do: :integer

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def cast(v), do: __enum_source__().cast(v)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def cast!(v), do: __enum_source__().cast!(v)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def dump(v), do: __enum_source__().dump(v)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def load(v), do: __enum_source__().load(v)


      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def atom_to_enum(v), do: __enum_source__().atom_to_enum(v)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def enum_to_atom(v), do: __enum_source__().enum_to_atom(v)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def json_to_atom(v), do: __enum_source__().json_to_atom(v)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def from_json(_format, field, json, _context, options) do
        cond do
          v = json[Atom.to_string(field)] -> json_to_atom(v)
          :else -> nil
        end
      end

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def __strip_inspect__(field, value, _opts), do: {field, value}


      #--------------------------------------
      #
      #--------------------------------------
      def pre_create_callback(_field, entity, _context, _options) do
        entity
      end
      def pre_create_callback!(_field, entity, _context, _options) do
        entity
      end

      #--------------------------------------
      #
      #--------------------------------------
      def post_create_callback(_field, entity, _context, _options) do
        entity
      end
      def post_create_callback!(_field, entity, _context, _options) do
        entity
      end

      #-------------------------------
      #
      #-------------------------------
      def pre_update_callback(_field, entity, _context, _options) do
        entity
      end

      def pre_update_callback!(_field, entity, _context, _options) do
        entity
      end

      #-------------------------------
      #
      #-------------------------------
      def post_update_callback(_field, entity, _context, _options) do
        entity
      end

      def post_update_callback!(_field, entity, _context, _options) do
        entity
      end


      #-------------------------------
      #
      #-------------------------------
      def pre_delete_callback(_field, entity, _context, _options) do
        entity
      end

      def pre_delete_callback!(_field, entity, _context, _options) do
        entity
      end

      #-------------------------------
      #
      #-------------------------------
      def post_delete_callback(_field, entity, _context, _options) do
        entity
      end

      def post_delete_callback!(_field, entity, _context, _options) do
        entity
      end

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      defoverridable [
        __sphinx_has_default__: 3,
        __sphinx_default__: 3,
        __sphinx_encoded__: 4,

        atom_to_enum: 1,
        enum_to_atom: 1,
        json_to_atom: 1,


        type: 0,
        cast: 1,
        cast!: 1,
        dump: 1,
        load: 1,

        pre_create_callback: 4,
        pre_create_callback!: 4,
        post_create_callback: 4,
        post_create_callback!: 4,

        pre_update_callback: 4,
        pre_update_callback!: 4,
        post_update_callback: 4,
        post_update_callback!: 4,

        pre_delete_callback: 4,
        pre_delete_callback!: 4,
        post_delete_callback: 4,
        post_delete_callback!: 4,

        from_json: 5,
        __strip_inspect__: 3,
      ]

    end
  end

end
