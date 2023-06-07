defmodule ApiWeb.Api.V1_1.PushNotificationView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_1.PushNotificationView
  alias Data.Context.NotificationsRecords
  alias Data.Context
  alias Data.Schema.User

  def render("notifications.json", %{repo: repo}) do
    entities = render_many(repo.entities, PushNotificationView, "show.json", as: :entity)
    %{length: repo.length, entities: entities}
  end


  def render("notifications_meta.json", %{meta: meta}) do
    meta
  end

  def render("user.json", %{entity: user}) do
    user_entity = Noizu.ERP.entity!(user)
    {image_name,thumb_name, blur_hash} = (with %Jetzy.Entity.Image.Entity{image: image} <- user_entity && Noizu.ERP.entity!(user_entity.profile_image),
                                               image = %Jetzy.Image.Entity{} <- Noizu.ERP.entity!(image),
                                               {:ok, full_name} <- (image.file_format in [:png, :jpg, :gif]) && {:ok, "#{image.base}.#{image.file_format}"} do
                                            with {:ok, thumb_name} <- (image.file_format in [:png, :jpg, :gif]) && {:ok, "#{image.base}.thumb.#{image.file_format}"} do
                                              {String.slice(full_name, 1..-1), String.slice(thumb_name, 1..-1), image.blur_hash}
                                            else
                                              _ -> {String.slice(full_name, 1..-1), String.slice(full_name, 1..-1), image.blur_hash}
                                            end
                                          else
                                            _ -> {nil, nil, nil}
                                          end)

    entity_name = user_entity && Noizu.ERP.entity!(user_entity.name)

    id = cond do
         v = user_entity && user_entity.__transient__[:guid] -> v
         :else -> Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(user), Noizu.ElixirCore.CallingContext.admin(), []) |> Noizu.ERP.id()
         end

    %{
      id: id,
      ref: Noizu.ERP.sref(user_entity),
      first_name: entity_name && entity_name.first,
      last_name: entity_name && entity_name.last,
      image: image_name,
      thumb: thumb_name,
      blur_hash: blur_hash,
    }
  end

  def render("show.json", %{entity: entity}) do
    type = Jetzy.User.Notification.Type.Entity.entity!(entity.notification_type)
    template = type && Noizu.ERP.entity!(type.template)
    subject = case ref = Noizu.ERP.ref(entity.subject) do
                nil -> nil
                {:ref, Jetzy.Post.Entity, _} ->
                  Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.UserEvent, ref, Noizu.ElixirCore.CallingContext.system(), [])
                {:ref, Jetzy.Comment.Entity, _} ->
                  Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.RoomMessage, ref, Noizu.ElixirCore.CallingContext.system(), [])
                {:ref, Jetzy.User.Relation.Entity, _} ->
                  Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.UserFriend, ref, Noizu.ElixirCore.CallingContext.system(), [])
                _ -> nil
              end
    %{
      ref: Noizu.ERP.sref(entity),
      template: template && template.body && template.body.markdown,
      user: render("user.json", entity: entity.user),
      sender: render("user.json", entity: entity.sender),
      subject: subject && Noizu.ERP.sref(subject),
      notification_type: entity.notification_type,
      status: entity.status,
      viewed_on: entity.viewed_on,
      cleared_on: entity.cleared_on,
      created_on: entity.time_stamp.created_on,
      modified_on: entity.time_stamp.modified_on,
      deleted_on: entity.time_stamp.deleted_on,
    }
  end
end