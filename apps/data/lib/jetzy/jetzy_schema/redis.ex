defmodule JetzySchema.Redis do
  @pool_size 50

  def rebuild_channels() do
    l = Enum.map(
          1..@pool_size,
          fn (index) ->
            {index, :"redix_#{index}"}
          end
        )
        |> Map.new()
    FastGlobal.put(:redix_cluster, l)
    l
  end

  def random_channel() do
    FastGlobal.get(:redix_cluster)[random_index()] || rebuild_channels()[random_index()]
  end

  def child_spec(_args) do
    # Specs for the Redix connections.
    children = Enum.map(
      1..@pool_size,
      fn (index) ->
        Supervisor.child_spec({Redix, name: :"redix_#{index}"}, id: {Redix, index})
      end
    )
    rebuild_channels()
    # Spec for the supervisor that will supervise the Redix connections.
    %{
      id: RedixSupervisor,
      type: :supervisor,
      start: {Supervisor, :start_link, [children, [strategy: :one_for_one]]}
    }
  end

  defp random_index(), do: :rand.uniform(@pool_size)
  def command(command), do: Redix.command(random_channel(), command)
  def flush(), do: command(["FLUSHALL"])

  def create_handler(_record, _context, _options) do
    # wip
    nil
  end

  def create_handler!(_record, _context, _options) do
    # wip
  end

  def update_handler(_record, _context, _options) do
    # wip
  end

  def update_handler!(_record, _context, _options) do
    # wip
  end

  def delete_handler(_record, _context, _options) do
    # wip
  end

  def delete_handler!(_record, _context, _options) do
    # wip
  end

  def metadata(), do: %Noizu.AdvancedScaffolding.Schema.Metadata.Redis{repo: __MODULE__}
end
