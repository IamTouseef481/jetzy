defmodule Data.Migration do
  @moduledoc """
  Imports all functionality for an ecto migration

  ### Usage

  ```
  defmodule Data.Migration.MyMigration do
    use Data.Migration

    def change do
      # Fields
    end
  end
  ```
  """
  defmacro __using__(_opts) do
    quote do
      use Ecto.Migration

      def timestamp do
        add :deleted_at, :utc_datetime
        timestamps()
      end
    end
  end
end
