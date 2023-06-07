#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Comment do

  use Noizu.DomainObject
  @vsn 1.0
  @sref "comment"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  @persistence_layer {Data.Repo, Data.Schema.RoomMessage, [cascade?: true, sync: false, fallback?: false, cascade_block?: true]}
  @persistence_layer {JetzySchema.MSSQL.Repo,  [sync: false]}
  @index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]}
  defmodule Entity do
    @nmid_index 77
    @universal_identifier true
    use Amnesia
    require Logger
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      @index true
      public_field :subject, nil, Noizu.DomainObject.UUID.UniversalLink.TypeHandler
      public_field :owner, nil, Noizu.DomainObject.UUID.UniversalLink.TypeHandler
      @index {:with, JetzySchema.Types.Status.Enum}
      public_field :status
      @index {:with, JetzySchema.Types.Comment.Type.Enum}
      public_field :comment_type
      @index true
      public_field :content, nil, Jetzy.CMS.Article.Comment.TypeHandler
      public_field :snippet, nil, Jetzy.CommentVersionedString.TypeHandler

      @index true
      public_field :location, nil, Jetzy.Location.Place.TypeHandler
      @index true
      public_field :geo, nil, Jetzy.GeoLocation.TypeHandler

      @index true
      public_field :moderation, nil, Jetzy.ModerationDetails.TypeHandler

      @index true
      public_field :parent, nil, Noizu.DomainObject.UUID.UniversalLink.TypeHandler
      @index true
      public_field :path, nil, Noizu.DomainObject.EncodedPath.TypeHandler

      @ref Jetzy.Entity.Interactions.Entity
      public_field :interactions, nil, Jetzy.Entity.Interactions.TypeHandler
      transient_field :children, nil, Jetzy.Comment.Repo.TypeHandler

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end


    #----------------------------
    # __from_record__!
    #----------------------------
    def __from_record__!(layer, record, context, options \\ nil)
    def __from_record__!(%{__struct__: PersistenceLayer, schema: JetzySchema.MSSQL.Repo} = _layer, %{__struct__: JetzySchema.MSSQL.Comment.Table} = record, context, options) do
      existing = cond do
                   options[:existing] == false -> nil
                   options[:existing] -> options[:existing]
                   e = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Comment.Table, record.id, context, options) -> e
                   :else -> nil
                 end

      user = Jetzy.User.Repo.by_guid!(record.user, context, options)
      time_stamp =  JetzySchema.MSSQL.Comment.Table.time_stamp!(record, context, options)
      status =  JetzySchema.MSSQL.Comment.Table.status!(record, context, options)
      comment_type = JetzySchema.MSSQL.Comment.Table.comment_type!(record, context, options)
      subject = options[:subject] || JetzySchema.MSSQL.Comment.Table.subject!(record, context, options)
      parent = options[:parent] || JetzySchema.MSSQL.Comment.Table.parent!(record, context, options) || subject
      location = JetzySchema.MSSQL.Post.Table.location!(record, context, options)
      geo = JetzySchema.MSSQL.Comment.Table.geo!(record, context, options)
      path = cond do
               existing -> existing.path
               parent -> Jetzy.Comment.Repo.next_path!(subject, parent)
               :else -> Jetzy.Comment.Repo.next_path!(subject)
             end
      snippet = Jetzy.CommentVersionedString.TypeHandler.sync!(existing && existing.snippet, %{title: "", body: record.description || "", editor: user, time_stamp: time_stamp}, context, options)
      content = Jetzy.CMS.Article.Comment.TypeHandler.sync!(existing && existing.content, %{title: "", body: record.description || "", editor: user, time_stamp: time_stamp}, context, options)

      moderation = existing && existing.moderation || %Jetzy.ModerationDetails{}
      interactions = %{}

      %Jetzy.Comment.Entity{
        subject: subject,
        owner: user,
        comment_type: comment_type,
        snippet: snippet,
        content: content,
        parent: parent,
        location: location,
        geo: geo,
        status: status,
        path: path,
        children: nil,
        interactions: interactions,
        moderation: moderation,
        time_stamp: time_stamp,
        __transient__:  %{existing: existing, record: record},
      }
    end
    def __from_record__!(layer, record, context, options) do
      super(layer, record, context, options)
    end

    #----------------------------
    # __from_record__
    #----------------------------
    def __from_record__(layer, record, context, options \\ nil)
    def __from_record__(%{__struct__: PersistenceLayer, schema: JetzySchema.MSSQL.Repo} = _layer, %{__struct__: JetzySchema.MSSQL.Comment.Table} = record, context, options) do
      existing = cond do
                   options[:existing] == false -> nil
                   options[:existing] -> options[:existing]
                   e = Jetzy.LegacyResolution.Repo.by_legacy(JetzySchema.MSSQL.Comment.Table, record.id, context, options) -> e
                   :else -> nil
                 end
      user = Jetzy.User.Repo.by_guid(record.user, context, options)
      time_stamp =  JetzySchema.MSSQL.Comment.Table.time_stamp(record, context, options)
      status =  JetzySchema.MSSQL.Comment.Table.status(record, context, options)
      comment_type = JetzySchema.MSSQL.Comment.Table.comment_type(record, context, options)
      subject = options[:subject] || JetzySchema.MSSQL.Comment.Table.subject(record, context, options)
      parent = options[:parent] || JetzySchema.MSSQL.Comment.Table.parent(record, context, options) || subject
      location = JetzySchema.MSSQL.Post.Table.location(record, context, options)
      geo = JetzySchema.MSSQL.Comment.Table.geo(record, context, options)
      path = cond do
               existing && existing.path -> existing.path
               parent -> Jetzy.Comment.Repo.next_path(subject, parent)
               :else -> Jetzy.Comment.Repo.next_path(subject)
             end


      encoding = "ISO8859/8859-9"

      error_template = %Jetzy.Import.Error.Entity{
        status: :active,
        import_error_type: :text_encoding,
        source: JetzySchema.PG.Comment.Table,
        source_identifier: Noizu.ERP.id(existing),
        legacy_source: record.__struct__,
        legacy_integer_identifier: record.id,
        legacy_guid_identifier: record.guid,
        time_stamp: Noizu.DomainObject.TimeStamp.Second.new(DateTime.utc_now()),
      }


      record_description = case record.description && Codepagex.from_string(record.description || "", encoding) do
                             {:ok, v} -> v
                             nil -> ""
                             error = {:error, _} ->
                               Logger.error("#{inspect error}")
                               %Jetzy.Import.Error.Entity{error_template|
                                 import_error_section: :comment_body,
                                 error_message: %{title: "Import Comment Description Error", body: "#[inspect error}\n#{inspect record}"},
                               } |>Jetzy.Import.Error.Repo.create!(context)
                               # return blank
                               "[UTF8 Error]"
                           end

      snippet = Jetzy.CommentVersionedString.TypeHandler.sync(existing && existing.snippet, %{title: "", body: record_description || "", editor: user, time_stamp: time_stamp}, context, options)
      content = Jetzy.CMS.Article.Comment.Entity.sync(existing && existing.content, %{title: "", body: record_description || "", editor: user, time_stamp: time_stamp}, context, options)

      moderation = existing && existing.moderation || %Jetzy.ModerationDetails{}
      interactions = %{}

      %Jetzy.Comment.Entity{
        subject: subject,
        owner: user,
        comment_type: comment_type,
        snippet: snippet,
        content: content,
        parent: parent,
        location: location,
        geo: geo,
        status: status,
        path: path,
        children: nil,
        interactions: interactions,
        moderation: moderation,
        time_stamp: time_stamp,
        __transient__:  %{existing: existing, record: record},
      }
    end
    def __from_record__(layer, record, context, options) do
      super(layer, record, context, options)
    end

    #-----------------------------------
    # fold_comments
    #-----------------------------------
    def fold_comments(comments, parent_path) do
      slice_off = length(parent_path)
      comments
      |> Enum.reduce(%{},
           fn(comment, acc) ->
             if (List.starts_with?(comment.path.path, parent_path)) do
               path = Enum.slice(comment.path.path, slice_off..-1)
               Jetzy.Helper.Json.force_put(acc, path ++ [:comment], comment)
             else
               acc
             end
           end)
      |> comment_map_to_array()
    end

    #-----------------------------------
    # comment_map_to_array
    #-----------------------------------
    def comment_map_to_array(nil) do
      nil
    end
    def comment_map_to_array(map) do
      Map.keys(map)
      |> Enum.filter(&(&1 != :comment))
      |> Enum.sort()
      |> Enum.map(
           fn(key) ->
             comment = map[key][:comment]
             put_in(comment, [Access.key(:children)], comment_map_to_array(map[key]))
           end
         )
    end





    #===-------
    # has_permission?
    #===-------
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true


  end

  defmodule Repo do
    @default_depth 3
    import Ecto.Query, only: [from: 2]

    Noizu.DomainObject.noizu_repo do
    end

    #----------------------------
    # layer_create_callback
    #----------------------------
    def layer_create_callback(%{__struct__: PersistenceLayer, schema: JetzySchema.Database} = layer, entity, context, options), do: layer_post_create_callback!(layer, entity, context, options)
    def layer_create_callback(%{__struct__: PersistenceLayer, schema: Data.Repo} = layer, entity, context, options), do: layer_post_create_callback!(layer, entity, context, options)
    def layer_create_callback(layer, entity, context, options), do: super(layer, entity, context, options)
    def layer_create_callback!(%{__struct__: PersistenceLayer, schema: JetzySchema.Database} = layer, entity, context, options) do
      if (entity.__transient__[:record]) do
        le = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Comment.Table, entity.__transient__.record.id, context, options)
        le || Jetzy.LegacyResolution.Repo.insert!(Noizu.ERP.ref(entity), JetzySchema.MSSQL.Comment.Table, entity.__transient__.record.id, context, options)
      end
      super(layer, entity, context, options)
    end
    def layer_create_callback!(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
      with {:ok, parent} <- {:ok, entity.path.depth > 1 && Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.RoomMessage, Noizu.ERP.ref(entity.parent), context, options) || nil },
           {:ok, sender} <- {:ok, Jetzy.User.Guid.Lookup.Repo.by_user!(entity.owner, context, options)},
           user_event = {:ref, _, _identifier} <- Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.UserEvent, entity.subject, context, options) || {:error, {:tanbits_by_ref, entity.subject}},
           %Data.Schema.UserEvent{room_id: room_id} <- Noizu.ERP.entity!(user_event) || {:error, {:import_user_event, user_event}},
           snippet <- Noizu.ERP.entity!(entity.snippet),
           message <- snippet && snippet.body && snippet.body.markdown || "",
           record <- %{message: message && String.slice(message, 0..254), sender_id: sender, room_id: room_id, parent_id: Noizu.ERP.id(parent)},
           {:ok, inserted} <- sender && room_id && Data.Context.create(Data.Schema.RoomMessage, record) || {:error, {:create_room, record}} do
        Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.RoomMessage, inserted.id, context, options)
        owner = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(entity.owner), context, options)
        case owner && Data.Repo.get_by(Data.Schema.RoomUser, %{room_id: room_id, user_id: Noizu.ERP.id(owner)}) do
          nil ->
            owner && Data.Context.create(Data.Schema.RoomUser, %{room_id: room_id, user_id: Noizu.ERP.id(owner)})
          _ -> nil
        end
      else
        e -> Logger.warn "======= NOT INSERTED ===== \n Match: #{inspect e, pretty: true}"
      end
      entity
    end
    def layer_create_callback!(layer, entity, context, options), do: super(layer, entity, context, options)

    #------------------------------------
    #
    #------------------------------------
    def by_legacy(identifier, context, options) when is_integer(identifier) do
      Jetzy.LegacyResolution.Repo.by_legacy(JetzySchema.MSSQL.Comment.Table, identifier, context, options)
    end

    #------------------------------------
    #
    #------------------------------------
    def by_legacy!(identifier, context, options) when is_integer(identifier) do
      Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Comment.Table, identifier, context, options)
    end




    #-----------------
    # list
    #-------------------
    def list(pagination, filter, _context, _options) do
      # @todo generic logic to query mnesia or ecto, including pagination
      entities = JetzySchema.Database.Comment.Table.match!([]) |> Amnesia.Selection.values() |> Enum.map(&(&1.entity))
      struct(Jetzy.Comment.Repo, [pagination: pagination, filter: filter, entities: entities, length: length(entities), retrieved_on: DateTime.utc_now()])
    end

    #-----------------
    # list!
    #-------------------
    def list!(pagination, filter, _context, _options) do
      # @todo generic logic to query mnesia or ecto, including pagination
      entities = JetzySchema.Database.Comment.Table.match!([]) |> Amnesia.Selection.values() |> Enum.map(&(&1.entity))
      struct(Jetzy.Comment.Repo, [pagination: pagination, filter: filter, entities: entities, length: length(entities), retrieved_on: DateTime.utc_now()])
    end

    #===-------
    # has_permission?
    #===-------
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true



    #========================
    # Matrix Path Encoding Formulas
    #===========


    #-----------------------------------
    # subject_comments
    #-----------------------------------
    def subject_comments(subject_ref, context, options \\ nil) do
      start_depth = options[:start_depth] || 0
      end_depth = options[:end_depth] || @default_depth

      # todo paging
      query = from(c in JetzySchema.PG.Comment.Table,
        where: c.subject == ^subject_ref,
        where: c.path_depth >= ^start_depth,
        where: c.path_depth <= ^end_depth,
        order_by: [c.path_depth, c.path_a11], limit: 5000, offset: 0)
      r = (JetzySchema.PG.Repo.all(query) || [])
      entities = Enum.map(r, fn(record) ->
        Jetzy.Comment.Entity.entity(record.identifier, context, options) #from_pg(record, context, options)
      end)

      options[:fold] && fold_comments(entities, []) || entities
    rescue _e -> nil
    catch
      :exit, _e -> nil
      _e -> nil
    end

    #-----------------------------------
    # comment_descendents
    #-----------------------------------
    def comment_descendents(subject_ref, parent_comment_ref, context, options \\ nil) do
      parent_comment = Noizu.ERP.entity!(parent_comment_ref)
      if (parent_comment && parent_comment.path) do
        start_depth = parent_comment.path.depth + 1
        end_depth = start_depth + (options[:depth] || @default_depth)

        a11 = parent_comment.path.matrix[:a11]
        a12 = -parent_comment.path.matrix[:a12]
        a21 = parent_comment.path.matrix[:a21]
        a22 = -parent_comment.path.matrix[:a22]
        a_high = a11/a21 - 0.0000001 #@mantis
        a_low = ((a11-a12) / (a21-a22)) + 0.0000001 #@mantis

        # todo paging
        query = from(c in JetzySchema.PG.Comment.Table,
          where: c.subject == ^subject_ref,
          where: c.path_depth >= ^start_depth,
          where: c.path_depth <= ^end_depth,
          where: (c.path_a11 * ^a21 <= c.path_a21 * ^a11),
          where: (c.path_a11 * ^a22 <= c.path_a21 * ^a12),
          where: (^a_low <= c.path_left and c.path_left <= ^a_high),
          order_by: [c.path_depth, c.path_a11], limit: 5000, offset: 0)
        r = (JetzySchema.PG.Repo.all(query) || [])
        entities = Enum.map(r, fn(record) ->
          Jetzy.Comment.Entity.entity(record.identifier, context, options) #from_pg(record, context, options)
        end)
        options[:fold] && fold_comments(entities, parent_comment.path.path) || entities
      end
    rescue _e -> nil
    catch
      :exit, _e -> nil
      _e -> nil
    end

    #-----------------------------------
    # comment_children
    #-----------------------------------
    def comment_children(subject_ref, parent_comment_ref, context, options \\ nil) do
      parent_comment = Noizu.ERP.entity!(parent_comment_ref)
      if (parent_comment && parent_comment.path) do
        a11 = parent_comment.path.matrix[:a11]
        a21 = parent_comment.path.matrix[:a21]
        target_depth = (parent_comment.path.depth + 1)
        # todo paging
        query = from(c in JetzySchema.PG.Comment.Table,
          where: c.subject == ^subject_ref,
          where: c.path_depth == ^target_depth,
          where: c.path_a12 == ^a11,
          where: c.path_a22 == ^a21,
          order_by: c.path_a11, limit: 5000, offset: 0)
        r = (JetzySchema.PG.Repo.all(query) || [])
        _entities = Enum.map(r, fn(record) ->
          Jetzy.Comment.Entity.entity(record.identifier, context, options) #from_pg(record, context, options)
        end)
      end
    rescue _e -> nil
    catch
      :exit, _e -> nil
      _e -> nil
    end


    #-----------------------------------
    # comment_from_subject_comment_path
    #-----------------------------------
    def comment_from_subject_comment_path(subject, path, _context, _options) do
      path_string = Noizu.DomainObject.EncodedPath.path_string(path)
      subject_sref = Noizu.ERP.sref(subject)
      subject_ref = Noizu.ERP.ref(subject)
      if (subject_sref && path_string) do
        key = "[comment-by-path:#{subject_sref}:#{path_string}]"
        case JetzySchema.Redis.command(["GET", key]) do
          {:ok, "null"} -> nil
          {:ok, sref} -> Jetzy.Comment.Entity.ref(sref)
          _ ->
            try do
              a11 = path.path.matrix[:a11]
              a21 = path.path.matrix[:a21]
              target_depth = path.path.depth
              # todo paging
              query = from(c in JetzySchema.PG.Comment.Table,
                where: c.subject == ^subject_ref,
                where: c.path_depth == ^target_depth,
                where: c.path_a11 == ^a11,
                where: c.path_a21 == ^a21,
                order_by: c.path_a11, limit: 5000, offset: 0)
              case (JetzySchema.PG.Repo.all(query) || []) do
                [r] ->
                  ref = Jetzy.Comment.Entity.ref(r.id)
                  sref = Jetzy.Comment.Entity.sref(ref)
                  JetzySchema.Redis.command(["SET", key, sref, 600])
                  ref
                _ ->
                  JetzySchema.Redis.command(["SET", key, "null", 60])
                  nil
              end
            rescue _e -> nil
            catch
              :exit, _e -> nil
              _e -> nil
            end
        end
      end
    end


    #-----------------------------------
    #
    #-----------------------------------
    def next_path!(subject_ref) do
      # todo paging
      query = from(c in JetzySchema.PG.Comment.Table,
        where: c.subject == ^subject_ref,
        where: c.path_depth == 1,
        where: (c.path_a12 == 1),
        where: (c.path_a21 == 1),
        select: %{max: max(c.path_a11)}
      )
      case JetzySchema.PG.Repo.all(query) do
        [%{max: nil}] -> Noizu.DomainObject.EncodedPath.new([1])
        [%{max: n}] -> Noizu.DomainObject.EncodedPath.new([n])
        [] -> Noizu.DomainObject.EncodedPath.new([1])
      end
    rescue e ->
      Logger.error Exception.format(:error, e, __STACKTRACE__)
      nil

    catch
      :exit, e ->
        Logger.error Exception.format(:error, e, __STACKTRACE__)
        nil
      e ->
        Logger.error Exception.format(:error, e, __STACKTRACE__)
        nil
    end

    #-----------------------------------
    #
    #-----------------------------------
    def next_path(subject_ref) do
      # todo paging
      query = from(c in JetzySchema.PG.Comment.Table,
        where: c.subject == ^subject_ref,
        where: c.path_depth == 1,
        where: (c.path_a12 == 1),
        where: (c.path_a21 == 1),
        select: %{max: max(c.path_a11)}
      )
      case JetzySchema.PG.Repo.all(query) do
        [%{max: nil}] -> Noizu.DomainObject.EncodedPath.new([1])
        [%{max: n}] -> Noizu.DomainObject.EncodedPath.new([n])
        [] -> Noizu.DomainObject.EncodedPath.new([1])
      end
    rescue e ->
      Logger.error Exception.format(:error, e, __STACKTRACE__)
      nil

    catch
      :exit, e ->
        Logger.error Exception.format(:error, e, __STACKTRACE__)
        nil
      e ->
        Logger.error Exception.format(:error, e, __STACKTRACE__)
        nil
    end

    #-----------------------------------
    #
    #-----------------------------------
    def next_path!(subject_ref, nil) do
      next_path!(subject_ref)
    end
    def next_path!(subject_ref, parent_comment_ref) do
      Amnesia.async fn -> next_path(subject_ref, parent_comment_ref) end
    end

    def next_path(subject_ref, nil), do: next_path(subject_ref)
    def next_path(subject_ref, parent_comment_ref) do
      case Noizu.ERP.ref(parent_comment_ref) do
        {:ref, Jetzy.Comment.Entity, v} when is_integer(v) ->
          case _parent_comment = Jetzy.Comment.Entity.entity(parent_comment_ref) do

            %Jetzy.Comment.Entity{path: nil} ->
              next_path(subject_ref)

            parent_comment = %Jetzy.Comment.Entity{path: _} ->
              a11 = parent_comment.path.matrix.a11
              a21 = parent_comment.path.matrix.a21
              target_depth = parent_comment.path.depth + 1
              try do
                # todo paging
                query = from(c in JetzySchema.PG.Comment.Table,
                  where: c.subject == ^subject_ref,
                  where: c.path_depth == ^target_depth,
                  where: (c.path_a12 == ^a11),
                  where: (c.path_a22 == ^a21),
                  select: %{max: max(c.path_a11/c.path_a22)}
                )

                case JetzySchema.PG.Repo.all(query) do
                  [%{max: nil}] -> Noizu.DomainObject.EncodedPath.new(parent_comment.path.path ++ [1])
                  [%{max: %Decimal{} = n}]  ->
                    n = n
                        |> Decimal.round(0, :down)
                        |> Decimal.to_integer()
                    Noizu.DomainObject.EncodedPath.new(parent_comment.path.path ++ [n + 1])
                  [%{max: n}] when is_float(n) -> Noizu.DomainObject.EncodedPath.new(parent_comment.path.path ++ [trunc(n) + 1])
                  [%{max: n}] when is_integer(n) -> Noizu.DomainObject.EncodedPath.new(parent_comment.path.path ++ [n + 1])
                end

              rescue e ->
                Logger.error Exception.format(:error, e, __STACKTRACE__)
                nil

              catch
                :exit, e ->
                  Logger.error Exception.format(:error, e, __STACKTRACE__)
                  nil
                e ->
                  Logger.error Exception.format(:error, e, __STACKTRACE__)
                  nil
              end
            e ->
              Logger.error "ERROR CONDITION 1| #{inspect e, pretty: true}\n\n\n\n"
              next_path(subject_ref)
          end
        e ->
          Logger.error "ERROR CONDITION 2| #{inspect e, pretty: true}\n\n\n\n"
          next_path(subject_ref)
      end
    end


    #-----------------------------------
    # fold_comments
    #-----------------------------------
    def fold_comments(comments, parent_path) do
      slice_off = length(parent_path)
      comments
      |> Enum.reduce(%{},
           fn(comment, acc) ->
             if (List.starts_with?(comment.path.path, parent_path)) do
               path = Enum.slice(comment.path.path, slice_off..-1)
               Jetzy.Helper.Json.force_put(acc, path ++ [:comment], comment)
             else
               acc
             end
           end)
      |> comment_map_to_array()
    end

    #-----------------------------------
    # comment_map_to_array
    #-----------------------------------
    def comment_map_to_array(nil) do
      nil
    end
    def comment_map_to_array(map) do
      Map.keys(map)
      |> Enum.filter(&(&1 != :comment))
      |> Enum.sort()
      |> Enum.map(
           fn(key) ->
             comment = map[key][:comment]
             put_in(comment, [Access.key(:children)], comment_map_to_array(map[key]))
           end
         )
    end



    #------------------------------------
    # import!
    #------------------------------------
    def import!(identifier, context, options \\ nil)
    def import!(_identifier, context, _options) when not is_system_caller(context), do: {:error, :permission_denied}
    def import!(identifier, context, options) when is_integer(identifier) do
      cond do
        record = JetzySchema.MSSQL.Comment.Table.by_identifier!(identifier, context, options) -> import!(record, context, options)
        :else -> {:error, :not_found}
      end
    end
    def import!(%{__struct__: JetzySchema.MSSQL.Comment.Table} = record, context, options) do
      #now = options[:current_time] || DateTime.utc_now()

      load = %{}

      # Existing Record
      existing_entity = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Comment.Table, record.id, context, options)
      existing_entity = existing_entity && Jetzy.Comment.Repo.get!(existing_entity, context, [load: load])

      # Load
      options_b = (options || [])
                  |> put_in([:existing], existing_entity || false)
                  |> put_in([:load], load)
      cond do
        existing_entity && !options[:refresh] -> {:error, :already_imported}
        entity = Jetzy.Comment.Entity.__from_record__!(Jetzy.Comment.Repo.__persistence__().schemas[JetzySchema.MSSQL.Repo], record, context, options_b) ->
          imported_entity = cond do
                              existing_entity ->
                                options_c = (options[:update] || []) |> put_in([:persist], [])
                                update!(entity, context, options_c)
                              :else ->
                                options_c = (options[:create] || []) |> put_in([:persist], [])
                                create!(entity, context, options_c)
                            end

          #===---
          #  load children, if any,
          #===---
          subject = entity.subject
          parent = Noizu.ERP.ref(imported_entity)
          options_d = (options || [])
                      |> put_in([:parent], parent)
                      |> put_in([:subject], subject)
          c = JetzySchema.MSSQL.Comment.Table.children!(record, context, options)
              |> Enum.map(&(import!(&1, context, options_d)))
          children = %Jetzy.Comment.Repo{entities: c, length: length(c)}
          {:imported, %{imported_entity| children: children}}
      end
    end
    def import!(ref, _context, _options) do
      {:error, {:invalid_record, ref}}
    end
  end




end
