defimpl Poison.Encoder, for: [PID, Reference] do
  def encode(p, options) do
    "#{inspect p}"
    |> Poison.Encoder.encode(options)
  end
end

defimpl Poison.Encoder, for: Tuple do
  def encode({:ai, p, c}, options),
      do: "ai.#{p}.#{c}"
          |> Poison.Encoder.encode(options)

  def encode({:ext_ref, _m, _identifier} = ref, options) do
    encode_ref(ref, options)
  end # end encode/2

  def encode({:ref, _m, _identifier} = ref, options) do
    encode_ref(ref, options)
  end # end encode/2

  def encode(entity, options) do
    %{tuple: Tuple.to_list(entity)}
    |> Poison.Encoder.encode(options)
  end

  def encode_ref({_, m, _id} = ref, options) do
    depth = (options[:depth] || 0) + 1
    path = options[:path]
    sm = try do
           m.__sref__
    rescue _ -> "[ERROR]"
         end
    path = sm <> (path && ".#{path}" || "")
    expand = Jetzy.Helper.Json.expand_ref?(path, depth, options)
    if (expand) do
      {cyclic_check, options} = Keyword.get_and_update(
        options,
        :cyclic_checks,
        fn (current) ->
          current = current || %{}
          updated = Map.put(current, ref, true)
          check = Map.get(current, ref, false)
          {check, updated}
        end
      )
      if cyclic_check do
        ref
        |> Noizu.ERP.sref()
        |> Poison.Encoder.encode(options)
      else
        (
          (
            ref
            |> Noizu.ERP.entity!()) || nil)
        |> Poison.Encoder.encode(options)
      end
    else
      ref
      |> Noizu.ERP.sref()
      |> Poison.Encoder.encode(options)
    end
  end
end

defmodule Jetzy.Poison.LookupValueEncoder do
  def encode(noizu_entity, options \\ nil) do
    json_format = options[:json_formats][noizu_entity.__struct__] || options[:json_formats][noizu_entity.__struct__.__noizu_info__(
                                                                                              :poly
                                                                                            )[:base]] || options[:json_format] || :mobile
    cond do
      json_format == :mobile ->
        ef = Module.concat(Enum.slice(Module.split(noizu_entity.__struct__), 0..-2) ++ ["Ecto.EnumType"])
        ef.enum_to_atom(noizu_entity.identifier)
        |> Poison.Encoder.encode(options)
      json_format == :admin ->
        Noizu.Poison.Encoder.encode(noizu_entity, options)
      :else ->
        ef = Module.concat(Enum.slice(Module.split(noizu_entity.__struct__), 0..-2) ++ ["Ecto.EnumType"])
        noizu_entity = put_in(noizu_entity, [Access.key(:identifier)], ef.enum_to_atom(noizu_entity.identifier))
        Noizu.Poison.Encoder.encode(noizu_entity, options)
    end
  end
end
