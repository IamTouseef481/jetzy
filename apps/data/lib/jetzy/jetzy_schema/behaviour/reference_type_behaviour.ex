defmodule JetzySchema.Type.ReferenceTypeBehaviour do

  defmacro __using__(options \\ nil) do
    #options = Macro.expand(options, __ENV__)
    reference_source = Macro.escape(options[:source])
    quote do
      require Noizu.DomainObject
      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"

      @__nzdo_reference_source Module.get_attribute(__MODULE__, :reference_source)
      defp __reference_source__(), do: (Macro.expand(unquote(reference_source), __ENV__) || @__nzdo_reference_source)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      use Ecto.Type

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def type(), do: :integer

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def cast(v), do: __reference_source__().cast(v)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def cast!(v), do: __reference_source__().cast!(v)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def dump(v), do: __reference_source__().dump(v)

      @file unquote(__ENV__.file) <> ":#{unquote(__ENV__.line)}" <> "(via #{__ENV__.file}:#{__ENV__.line})"
      def load(v), do: __reference_source__().load(v)


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
        type: 0,
        cast: 1,
        cast!: 1,
        dump: 1,
        load: 1,

        __strip_inspect__: 3,

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
      ]

    end
  end

end
