defmodule Jetzy.ElixirScaffolding.EnumEntity do
  defmacro __using__(options \\ nil) do
    options = Macro.expand(options, __ENV__)
    Jetzy.ElixirScaffolding.__jetzy_enum_table(__CALLER__, options, nil)
  end
end
