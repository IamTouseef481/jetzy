defmodule JetzySchema.Types.MSSQL.GenderType do
  use Ecto.Type

  #----------------------------
  # type
  #----------------------------
  @doc false
  def type, do: :integer

  #----------------------------
  # cast
  #----------------------------
  @doc """
  Casts to Ref.
  """
  def cast(v) do
    case v do
      "1" -> {:ok, :male}
      "2" -> {:ok, :female}
      _ -> {:ok, :none}
    end
  end

  #----------------------------
  # cast!
  #----------------------------
  @doc """
  Same as `cast/1` but raises `Ecto.CastError` on invalid arguments.
  """
  def cast!(value) do
    case value do
      "1" -> {:ok, :male}
      "2" -> {:ok, :female}
      _ -> {:ok, :none}
    end
  end

  #----------------------------
  # dump
  #----------------------------
  @doc false
  def dump(v) when is_integer(v) do
    {:ok, v}
  end
  def dump(v) do
    case v do
      :male -> {:ok, "1"}
      :female -> {:ok, "2"}
      :none -> {:ok, nil}
    end
  end

  #----------------------------
  # load
  #----------------------------
  def load(v) do
    case v do
      "1" -> {:ok, :male}
      "2" -> {:ok, :female}
      _ -> {:ok, :none}
    end
  end
end
