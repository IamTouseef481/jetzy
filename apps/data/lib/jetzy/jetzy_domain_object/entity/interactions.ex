#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Interactions do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "interactions"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  @auto_generate false
  defmodule Entity do
    @nmid_index 89
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :ref

      @index true
      public_field :comments

      @index true
      public_field :shares

      @index true
      public_field :like

      @index true
      public_field :dislike

      @index true
      public_field :heart

      @index true
      public_field :angry

      @index true
      public_field :sad

      @index true
      public_field :laugh

      @index true
      public_field :confused

      @index true
      public_field :comfort

      @index true
      public_field :reaction_09

      @index true
      public_field :reaction_10

      @index true
      public_field :synchronized_on, nil,  Noizu.DomainObject.DateTime.Millisecond.TypeHandler
      @index true
      public_field :modified_on, nil,  Noizu.DomainObject.DateTime.Second.TypeHandler
    end
  end

  defmodule Repo do
    import Ecto.Query, only: [from: 2]
    Noizu.DomainObject.noizu_repo do
    end

    def increment!(:subject, :none, _context, _options), do: :ok
    def increment!(subject, action, context, options) do
      spawn fn ->
        cond do
          u = Jetzy.Entity.Interactions.entity!(Noizu.ERP.ref(subject)) ->
            update_in(u, [Access.key(action)], &(&1 + 1))
            |> update!(context, options)
          :else -> :nop
        end
      end
      :ok
    end

    def decrement!(:subject, :none, _context, _options), do: :ok
    def decrement!(subject, action, context, options) do
      spawn fn ->
        cond do
          u = Jetzy.Entity.Interactions.entity!(Noizu.ERP.ref(subject)) ->
            update_in(u, [Access.key(action)], &(&1 - 1))
            |> update!(context, options)
          :else -> :nop
        end
      end
      :ok
    end

    #----------------------------
    # rebuild!
    #----------------------------
    def rebuild!(this, context, options) do
      #uid = Noizu.EctoEntity.Protocol.universal_identifier(this)
      ref = Noizu.ERP.ref(this)

      # Pull up to now - 5 seconds (to allow for database replication)
      cut_off = DateTime.utc_now() |> Timex.shift(seconds: -5)
      reactions = [:like, :dislike, :heart, :angry, :sad, :laugh, :confused, :comfort]
      tallies = Enum.map(reactions, fn(reaction) ->
        {start_date, tally} = cond do
                                options[:rebuild] -> {DateTime.from_unix!(0), 0}
                                roll_up = Jetzy.Entity.Reaction.RollUp.Entity.entity!({ref, reaction}) -> {roll_up.synchronized_on, roll_up.count}
                                :else -> {DateTime.from_unix!(0), 0}
                              end


        query = from u in JetzySchema.PG.Entity.Subject.Reaction.History.Table,
                     where: u.subject == ^ref,
                     where: u.reaction == ^reaction,
                     where: u.modified_on > ^start_date,
                     where: u.modified_on <= ^cut_off,
                     select: sum(u.count)
        updated_tally = case JetzySchema.PG.Repo.one(query) do
          v when is_integer(v) -> v + tally
          _ -> 0
        end


        %Jetzy.Entity.Reaction.RollUp.Entity{
          subject: ref,
          reaction: reaction,
          tally: updated_tally,
          synchronized_on: cut_off
        } |> Jetzy.Entity.Reaction.RollUp.Repo.create!(context, options)

        {reaction, updated_tally}
      end)

      #===----
      # comments
      #===----
      {start_date, tally} = cond do
                              options[:rebuild] -> {DateTime.from_unix!(0), 0}
                              roll_up = Jetzy.Entity.Comment.RollUp.Entity.entity!(ref) -> {roll_up.synchronized_on, roll_up.count}
                              :else -> {DateTime.from_unix!(0), 0}
                            end


      query = from u in JetzySchema.PG.Entity.Subject.Comment.History.Table,
                   where: u.subject == ^ref,
                   where: u.modified_on > ^start_date,
                   where: u.modified_on <= ^cut_off,
                   select: sum(u.count)
      updated_tally = case JetzySchema.PG.Repo.one(query) do
                        v when is_integer(v) -> v + tally
                        _ -> 0
                      end
      %Jetzy.Entity.Comment.RollUp.Entity{
        identifier: ref,
        subject: ref,
        tally: updated_tally,
        synchronized_on: cut_off
      } |> Jetzy.Entity.Comment.RollUp.Repo.create!(context, options)


      comments = [{:comments, updated_tally}]


      #===----
      # shares
      #===----
      {start_date, tally} = cond do
                              options[:rebuild] -> {DateTime.from_unix!(0), 0}
                              roll_up = Jetzy.Entity.Share.RollUp.Entity.entity!(ref) -> {roll_up.synchronized_on, roll_up.count}
                              :else -> {DateTime.from_unix!(0), 0}
                            end

      query = from u in JetzySchema.PG.Entity.Subject.Share.History.Table,
                   where: u.subject == ^ref,
                   where: u.created_on > ^start_date,
                   where: u.created_on <= ^cut_off,
                   select: sum(u.count)
      updated_tally = case JetzySchema.PG.Repo.one(query) do
                        v when is_integer(v) -> v + tally
                        _ -> 0
                      end
      %Jetzy.Entity.Share.RollUp.Entity{
        subject: ref,
        tally: updated_tally,
        synchronized_on: cut_off
      } |> Jetzy.Entity.Share.RollUp.Repo.create!(context, options)
      shares = [{:shares, updated_tally}]

      %{struct(Jetzy.Entity.Interactions.Entity, tallies ++ comments ++ shares)|
        identifier: ref,
        reaction_09: 0,
        reaction_10: 0,
        modified_on: DateTime.utc_now(),
        synchronized_on: cut_off
      } |> Jetzy.Entity.Interactions.Repo.update!(context, options)
    end
  end

end
