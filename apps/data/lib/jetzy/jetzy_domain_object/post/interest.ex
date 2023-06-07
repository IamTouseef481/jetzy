#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Post.Interest do

  use Noizu.DomainObject
  @vsn 1.0
  @sref "post-interest"
  @persistence_layer {:mnesia, cascade?: true, cascade_block?: true}
  @persistence_layer {:ecto, cascade?: true, cascade_block?: true}
  defmodule Entity do
    @nmid_index 112
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :post
      public_field :interest, nil, Jetzy.Interest.TypeHandler
      public_field :weight
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end


  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end


    #------------------------------------
    # import!
    #------------------------------------
    def import!(guid, context, options \\ nil)
    def import!(_guid, context, _options) when not is_system_caller(context), do: {:error, :permission_denied}
    def import!(guid, context, options) when is_integer(guid) do
      cond do
        #record = Data.Schema.EventInterest.by_legacy!(guid, context, options) -> import!(record, context, options)
        record = JetzySchema.MSSQL.Post.Interest.Table.by_legacy!(guid, context, options) -> import!(record, context, options)
        :else -> {:error, :not_found}
      end
    end
    def import!(%Decimal{} = guid, context, options) do
      import!(Decimal.to_integer(guid), context, options)
    end
    def import!(%{__struct__: JetzySchema.MSSQL.Post.Interest.Table} = record, context, options) do
      # Load Interest
      now = options[:current_time] || DateTime.utc_now()
      interest = Jetzy.Interest.Repo.by_legacy!(record.interest_id, context, options)
      post = Jetzy.Post.Repo.by_legacy_guid!(record.post_id, context, options)
      user = Jetzy.User.Repo.by_guid!(record.user_id, context, options)
      {:imported, %Jetzy.Post.Interest.Entity{
                    post: post,
                    interest: Noizu.ERP.ref(interest),
                    weight: 1,
                    time_stamp: Noizu.DomainObject.TimeStamp.Second.import(record.created_on, record.modified_on, nil),
                  } |> Jetzy.Post.Interest.Repo.create!(context)
      }
    end
    def import!(%{__struct__: Data.Schema.UserInterest} = record, context, options) do
      {:error, :nyi}
    end
    def import!(ref, _context, _options) do
      {:error, {:invalid_record, ref}}
    end

    #------------------------------------
    # by_legacy
    #------------------------------------
    def by_legacy(guid, context, options \\ nil), do: by_legacy!(guid, context, options)

    #------------------------------------
    # by_guid!
    #------------------------------------
    def by_legacy!(guid, context, options \\ nil)
    def by_legacy!(nil, _context, _options), do: nil
    def by_legacy!(guid, context, options) do
      cond do
        entity_ref = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Post.Interest.Table, guid, context, options) ->
          entity_ref
        options[:import] == false -> nil
        :else ->
          case Jetzy.Post.Interest.Repo.import!(guid, context, options) do
            {:imported, entity} ->
              Jetzy.LegacyResolution.Repo.insert!(Noizu.ERP.ref(entity), JetzySchema.MSSQL.Post.Interest.Table, guid, context, options)
              Noizu.ERP.ref(entity)
            {:refreshed, entity} ->
              Jetzy.LegacyResolution.Repo.insert!(Noizu.ERP.ref(entity), JetzySchema.MSSQL.Post.Interest.Table, guid, context, options)
              Noizu.ERP.ref(entity)
            v ->
              Logger.info """
              [DEBUG] #{__ENV__.line} - #{inspect v}
              """
              nil
          end
      end
    end



  end

end
