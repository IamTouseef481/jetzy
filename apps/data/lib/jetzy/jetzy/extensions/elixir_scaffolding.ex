defmodule Jetzy.ElixirScaffolding do
  defmacro __using__(_options \\ nil) do
    quote do
      use Noizu.DomainObject
    end
  end

  #--------------------------------------------
  # jetzy_repo
  #--------------------------------------------
  defmacro jetzy_repo(options \\ [], [do: block]) do
    options = Macro.expand(options, __ENV__)
    base_logic = Noizu.AdvancedScaffolding.Internal.DomainObject.Repo.__noizu_repo__(__CALLER__, options, block)
    quote do
      unquote base_logic

      def post_create_callback(entity, context, options) do
        if entity && entity.identifier do
          %Jetzy.UniversalIdentifierResolution.Entity{identifier: entity.identifier, ref: Noizu.ERP.ref(entity)}
          |> Jetzy.UniversalIdentifierResolution.Repo.create!(context)
        end
        super(entity, context, options)
      end

      defoverridable [post_create_callback: 3]

    end

  end

  #--------------------------------------------
  #
  #--------------------------------------------
  defmacro enum_table(options \\ [], [do: block]) do
    options = Macro.expand(options, __ENV__)
    Jetzy.ElixirScaffolding.__jetzy_enum_table(__CALLER__, options, block)
  end

  #--------------------------------------------
  #
  #--------------------------------------------
  def __jetzy_enum_table(_caller, options, block) do
    time_stamp_type = Noizu.DomainObject.TimeStamp.Second.TypeHandler

    values = options[:values]
    default_value = options[:default] || :none
    ecto_type = options[:ecto_type] || :integer
    has_block = block && true || false
    versioning = options[:versioning] || Jetzy.VersionedString.TypeHandler
    json_provider = cond do
                      v = options[:provider] -> v
                      :else -> Jetzy.Poison.LookupValueEncoder
                    end
    quote do
      use Jetzy.ElixirScaffolding
      #--------------
      #  Load contents, where enum values are stored.
      #-------------------------

      if unquote(has_block) do
        try do
          unquote(block)
        after
          :ok
        end
      end

      if [] == (Module.has_attribute?(__MODULE__, :enum_list) && Module.get_attribute(__MODULE__, :enum_list) || []) do
        Module.put_attribute(__MODULE__, :enum_list, unquote(values))
      end
      if !(Module.has_attribute?(__MODULE__, :default_value) && Module.get_attribute(__MODULE__, :default_value)) do
        Module.put_attribute(__MODULE__, :default_value, unquote(default_value))
      end
      if !(Module.has_attribute?(__MODULE__, :ecto_type) && Module.get_attribute(__MODULE__, :ecto_type)) do
        Module.put_attribute(__MODULE__, :ecto_type, unquote(ecto_type))
      end

      # Verify Value
      if Module.get_attribute(__MODULE__, :enum_list) == nil do
        raise "#{__MODULE__}.jetzy_enum_table must include an @enum_list field"
      end

      if [] == (Module.has_attribute?(__MODULE__, :persistence_layer) && Module.get_attribute(__MODULE__, :persistence_layer) || []) do
        Module.put_attribute(__MODULE__, :persistence_layer, :mnesia)
        Module.put_attribute(__MODULE__, :persistence_layer, {:ecto, cascade?: true})
      end

      if !Module.has_attribute?(__MODULE__, :auto_generate) do
        Module.put_attribute(__MODULE__, :auto_generate, false)
      end

      #-----------------------
      # Gen
      #-----------------------
      @json_format_group {:user_clients, [:compact]}
      @json_provider unquote(json_provider)
      defmodule Entity do
        @auto_generate false
        @universal_identifier false
        @nmid_bare true
        @index false
        Noizu.DomainObject.noizu_entity() do
          @meta {:enum_entity, true}
          identifier :atom

          @json {:*, :expand}
          @json_embed {:user_clients, [{:title, as: :name}]}
          @json_embed {:verbose_mobile, [{:title, as: :name}, {:body, as: :description}, {:editor, sref: true}, :revision]}
          public_field :description, nil, type: unquote(versioning)

          @json_ignore :user_clients
          public_field :time_stamp, nil, unquote(time_stamp_type)
        end

        def ecto_identifier(entity) do
          cond do
            ref = Noizu.ERP.ref(entity) ->
              atom = Noizu.ERP.id(ref)
              cond do
                is_integer(atom) -> atom
                :else -> __enum__()[:type].atom_to_enum(atom)
              end
            :else -> nil
          end
        end

      end
      defmodule Repo do
        Noizu.DomainObject.noizu_repo do

        end
      end
    end
  end
end
