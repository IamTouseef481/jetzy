defmodule JetzySchema.Types.Noizu.MarkdownField do
  @moduledoc "Place Holder, Custom Implementation required."
  use Ecto.Type
  def type, do: :any

  # Provide custom casting rules.
  def cast(v) when is_binary(v) do
    {:ok, Noizu.V3.CMS.MarkdownField.new(v)}
  end
  def cast(%Noizu.V3.CMS.MarkdownField{} = v) do
    {:ok, v}
  end
  def cast(nil) do
    {:ok, nil}
  end
  # Everything else is a failure though
  def cast(_), do: :error

  def load(data) when is_bitstring(data) do
    {:ok, Noizu.V3.CMS.MarkdownField.new(data)}
  end

  def dump(v) when is_bitstring(v), do: {:ok, v}
  def dump(%Noizu.V3.CMS.MarkdownField{} = v), do: {:ok, v.markdown}
  def dump(nil), do: {:ok, nil}
  def dump(_), do: :error
end