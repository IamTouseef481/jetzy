#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2019 JetzyApp All rights reserved.
#-------------------------------------------------------------------------------

defmodule JetzySchema.Mnesia.Changesets.PG do
  require Jetzy.DomainObject.Schema
  require Logger
  use Noizu.MnesiaVersioning.SchemaBehaviour
  alias Noizu.MnesiaVersioning.ChangeSet
  use Amnesia
  #use JetzySchema.Database

  def initial_tables() do
    [
      JetzySchema.Database.Import.Error.Section.Enum.Table,
      JetzySchema.Database.Import.Error.Type.Enum.Table,
      JetzySchema.Database.Import.Error.Table,

      JetzySchema.Database.UniversalIdentifierResolution.Source.Enum.Table,

      JetzySchema.Database.Location.Redirect.Table,
      JetzySchema.Database.Location.Relation.Table,
      JetzySchema.Database.OperatingSystem.Table,
      JetzySchema.Database.Post.Interest.Table,
      JetzySchema.Database.Transaction.Status.Enum.Table,
      JetzySchema.Database.Entity.Subject.Comment.History.Table,
      JetzySchema.Database.Entity.Subject.Share.History.Table,

      JetzySchema.Database.CommentVersionedString.History.Table,
      JetzySchema.Database.LocationVersionedString.History.Table,
      JetzySchema.Database.ModerationVersionedString.History.Table,
      JetzySchema.Database.PostVersionedString.History.Table,
      JetzySchema.Database.UserAboutVersionedString.History.Table,
      JetzySchema.Database.UserBioVersionedString.History.Table,
      JetzySchema.Database.UserPanicVersionedString.History.Table,
      JetzySchema.Database.UserVersionedString.History.Table,
      JetzySchema.Database.VersionedAddress.History.Table,
      JetzySchema.Database.VersionedImageString.History.Table,
      JetzySchema.Database.VersionedLink.History.Table,
      JetzySchema.Database.VersionedName.History.Table,
      JetzySchema.Database.VersionedString.History.Table,
      JetzySchema.Database.User.Relative.Request.Table,
      JetzySchema.Database.User.Relative.Table,
      JetzySchema.Database.User.Relation.Group.Table,
      JetzySchema.Database.User.Mute.Table,
      JetzySchema.Database.User.Friend.Lookup.Table,
      JetzySchema.Database.User.Block.Lookup.Table,
      JetzySchema.Database.User.Reward.Table,
      JetzySchema.Database.User.Point.Balance.Table,
      JetzySchema.Database.UniversalIdentifierResolution.Table,
      JetzySchema.Database.System.Event.Table,
      JetzySchema.Database.Image.Table.Migrate,
      JetzySchema.Database.Entity.Image.Table.Migrate,
      JetzySchema.Database.Channel.Definition.Field.Table,
      JetzySchema.Database.Contact.Channel.Field.Table,



      JetzySchema.Database.Location.Country.Table,
      JetzySchema.Database.Location.State.Table,
      JetzySchema.Database.Location.City.Table,
      JetzySchema.Database.Location.Place.Table,
      JetzySchema.Database.Social.Type.Enum.Table,
      JetzySchema.Database.Offer.Table,
      JetzySchema.Database.Reward.Table,
      JetzySchema.Database.Reward.Tier.Table,
      JetzySchema.Database.Reward.Event.Table,
      JetzySchema.Database.Setting.Table,
      JetzySchema.Database.User.Notification.Setting.Table,
      JetzySchema.Database.User.Notification.Type.Table,
      JetzySchema.Database.User.Notification.Event.Table,
      JetzySchema.Database.Comment.Table,
      JetzySchema.Database.Post.Table,
      JetzySchema.Database.User.Interest.Table,
      JetzySchema.Database.TanbitsResolution.Table,
      JetzySchema.Database.Post.Entity.Tag.Contact.Table,

      JetzySchema.Database.Employer.Table,
      JetzySchema.Database.Vocation.Table,
      JetzySchema.Database.School.Table,
      JetzySchema.Database.Degree.Table,

      JetzySchema.Database.User.Relation.Table,
      JetzySchema.Database.User.Block.Table,
      JetzySchema.Database.User.Follow.Table,
      JetzySchema.Database.User.Friend.Table,
      JetzySchema.Database.User.Friend.Request.Table,

      # Enums
      JetzySchema.Database.TanbitsResolution.Source.Enum.Table,

      JetzySchema.Database.System.Enum.Table,
      JetzySchema.Database.UniversalIdentifierResolution.Source.Enum.Table,
      JetzySchema.Database.LegacyResolution.Source.Enum.Table,


      JetzySchema.Database.LegacyResolution.Table,
      JetzySchema.Database.Entity.Sphinx.Index.State.Table,
      JetzySchema.Database.Sphinx.Index.Type.Enum.Table,


      JetzySchema.Database.User.Authentication.Setting.Table,
      JetzySchema.Database.User.Device.Table,
      JetzySchema.Database.Device.Table,
      JetzySchema.Database.User.Session.Table,
      JetzySchema.Database.User.Session.Generation.Table,

      JetzySchema.Database.Interest.Table,


      JetzySchema.Database.Entity.Contact.Channel.Table,
      JetzySchema.Database.Contact.Channel.Table,
      JetzySchema.Database.Channel.Definition.Table,

      # From Noizu Tables
      JetzySchema.Database.CMS.Article.Table,
      JetzySchema.Database.CMS.Article.Index.Table,
      JetzySchema.Database.CMS.Article.ActiveTag.Table,
      JetzySchema.Database.CMS.Article.Version.Table,
      JetzySchema.Database.CMS.Article.Version.Revision.Table,
      JetzySchema.Database.CMS.Article.Active.Version.Table,
      JetzySchema.Database.CMS.Article.Active.Version.Revision.Table,
      JetzySchema.Database.CMS.Article.VersionSequencer.Table,

      # Extended Functionality
      JetzySchema.Database.CMS.Article.Type.Enum.Table,
      JetzySchema.Database.CMS.Article.Tag.Enum.Table,
      JetzySchema.Database.CMS.Article.Revision.Attribute.Value.Type.Enum.Table,
      JetzySchema.Database.CMS.Article.Attribute.Enum.Table,


      JetzySchema.Database.UserVersionedString.Table,
      JetzySchema.Database.UserAboutVersionedString.Table,
      JetzySchema.Database.UserBioVersionedString.Table,
      JetzySchema.Database.UserPanicVersionedString.Table,
      JetzySchema.Database.CommentVersionedString.Table,
      JetzySchema.Database.PostVersionedString.Table,
      JetzySchema.Database.CheckInVersionedString.Table,

      JetzySchema.Database.VersionedString.Table,
      JetzySchema.Database.VersionedNightLife.Table,
      JetzySchema.Database.VersionedName.Table,
      JetzySchema.Database.VersionedLink.Table,
      JetzySchema.Database.VersionedImageString.Table,
      JetzySchema.Database.VersionedDeal.Table,
      JetzySchema.Database.VersionedBusiness.Table,
      JetzySchema.Database.VersionedAddress.Table,
      JetzySchema.Database.VersionedActivity.Table,
      JetzySchema.Database.ModerationVersionedString.Table,
      JetzySchema.Database.LocationVersionedString.Table,

      JetzySchema.Database.Video.Type.Enum.Table,
      JetzySchema.Database.Visibility.Type.Enum.Table,
      JetzySchema.Database.User.Relation.Status.Enum.Table,
      JetzySchema.Database.User.Relation.Group.Type.Enum.Table,
      JetzySchema.Database.Transaction.Type.Enum.Table,
      JetzySchema.Database.Tag.Type.Enum.Table,
      JetzySchema.Database.Tag.State.Enum.Table,
      JetzySchema.Database.System.Event.Type.Enum.Table,
      JetzySchema.Database.Status.Enum.Table,
      JetzySchema.Database.State.Enum.Table,
      JetzySchema.Database.Staff.Role.Enum.Table,
      JetzySchema.Database.Sphinx.Index.Enum.Table,
      JetzySchema.Database.ShoutOut.Type.Enum.Table,
      JetzySchema.Database.Share.Type.Enum.Table,
      JetzySchema.Database.Share.Event.Type.Enum.Table,
      JetzySchema.Database.SearchVisibility.Level.Enum.Table,
      JetzySchema.Database.Relative.Type.Enum.Table,
      JetzySchema.Database.Relationship.Type.Enum.Table,
      JetzySchema.Database.Redeem.Type.Enum.Table,
      JetzySchema.Database.Reaction.Type.Enum.Table,
      JetzySchema.Database.Reaction.Event.Type.Enum.Table,
      JetzySchema.Database.Question.Type.Enum.Table,
      JetzySchema.Database.Post.Type.Enum.Table,
      JetzySchema.Database.Post.Topic.Enum.Table,
      JetzySchema.Database.Post.Content.Enum.Table,
      JetzySchema.Database.Permission.Enum.Table,
      JetzySchema.Database.Origin.Source.Enum.Table,
      JetzySchema.Database.Opportunity.Type.Enum.Table,
      JetzySchema.Database.OperatingSystem.Enum.Table,
      JetzySchema.Database.Offer.Deal.Type.Enum.Table,
      JetzySchema.Database.Offer.Deal.Category.Enum.Table,
      JetzySchema.Database.Offer.Activity.Type.Enum.Table,
      JetzySchema.Database.Notification.Type.Enum.Table,
      JetzySchema.Database.Notification.Delivery.Type.Enum.Table,
      JetzySchema.Database.Moment.Type.Enum.Table,
      JetzySchema.Database.Moderation.Type.Enum.Table,
      JetzySchema.Database.Moderation.Status.Enum.Table,
      JetzySchema.Database.Moderation.Resolution.Enum.Table,
      JetzySchema.Database.Media.Type.Enum.Table,
      JetzySchema.Database.ManagedGroup.Type.Enum.Table,
      JetzySchema.Database.Locale.Country.Enum.Table,
      JetzySchema.Database.Locale.Language.Enum.Table,
      JetzySchema.Database.Location.Zone.Enum.Table,
      JetzySchema.Database.Location.Type.Enum.Table,
      JetzySchema.Database.Location.Source.Enum.Table,
      JetzySchema.Database.Location.Relation.Type.Enum.Table,
      JetzySchema.Database.Location.Image.Type.Enum.Table,
      JetzySchema.Database.Interaction.Type.Enum.Table,
      JetzySchema.Database.Image.Type.Enum.Table,
      JetzySchema.Database.Group.SignUp.Type.Enum.Table,
      JetzySchema.Database.Group.Permission.Rule.Enum.Table,
      JetzySchema.Database.Group.Permission.Enum.Table,
      JetzySchema.Database.Group.LookupRule.Enum.Table,
      JetzySchema.Database.Group.Join.Type.Enum.Table,
      JetzySchema.Database.Group.Grant.Type.Enum.Table,
      JetzySchema.Database.Grant.Type.Enum.Table,
      JetzySchema.Database.Gender.Enum.Table,
      JetzySchema.Database.Friend.Status.Enum.Table,
      JetzySchema.Database.File.Format.Enum.Table,
      JetzySchema.Database.Entity.Aspect.Enum.Table,
      JetzySchema.Database.Employment.Type.Enum.Table,
      JetzySchema.Database.Employment.Status.Enum.Table,
      JetzySchema.Database.EmergencyContact.Type.Enum.Table,
      JetzySchema.Database.Document.Type.Enum.Table,
      JetzySchema.Database.Device.Type.Enum.Table,
      JetzySchema.Database.Device.Token.Type.Enum.Table,
      JetzySchema.Database.Degree.Type.Enum.Table,
      JetzySchema.Database.Degree.Status.Enum.Table,
      JetzySchema.Database.Data.Source.Type.Enum.Table,
      JetzySchema.Database.Data.Source.Enum.Table,
      JetzySchema.Database.Credential.Type.Enum.Table,
      JetzySchema.Database.Credential.Provider.Enum.Table,
      JetzySchema.Database.Content.Flag.Enum.Table,
      JetzySchema.Database.Contact.Type.Enum.Table,
      JetzySchema.Database.Comment.Type.Enum.Table,
      JetzySchema.Database.Comment.Event.Type.Enum.Table,


      JetzySchema.Database.CheckIn.Type.Enum.Table,
      JetzySchema.Database.Channel.Type.Enum.Table,
      JetzySchema.Database.Channel.Field.Type.Enum.Table,
      JetzySchema.Database.Channel.Handler.Enum.Table,
      JetzySchema.Database.Business.SubType.Enum.Table,
      JetzySchema.Database.Business.Type.Enum.Table,
      JetzySchema.Database.Business.PricePoint.Enum.Table,
      JetzySchema.Database.Business.DressCode.Enum.Table,
      JetzySchema.Database.Business.Attribute.Type.Enum.Table,
      JetzySchema.Database.Address.Type.Enum.Table,
      JetzySchema.Database.Activity.Type.Enum.Table,
      JetzySchema.Database.Achievement.Type.Enum.Table,
      JetzySchema.Database.Account.Flag.Enum.Table,
      JetzySchema.Database.User.Referral.Redemption.Table,
      JetzySchema.Database.User.Referral.Code.Table,
      JetzySchema.Database.User.Guid.Lookup.Table,
      JetzySchema.Database.User.Table,
      JetzySchema.Database.User.Credential.Table,


      JetzySchema.Database.Offer.Deal.Table,
      JetzySchema.Database.Offer.Activity.Table,
      JetzySchema.Database.Image.Table,
      JetzySchema.Database.Entity.Interactions.Table,
      JetzySchema.Database.Entity.Image.Table,
      JetzySchema.Database.Business.Vendor.Location.Table,
      JetzySchema.Database.Business.Vendor.Table,
      JetzySchema.Database.Business.Restaurant.Location.Table,
      JetzySchema.Database.Business.Restaurant.Table,
      JetzySchema.Database.Business.Hotel.Location.Table,
      JetzySchema.Database.Business.Hotel.Table,
      JetzySchema.Database.Business.Location.Table,
      JetzySchema.Database.Business.Table,
      JetzySchema.Database.Session.Status.Enum.Table,

      JetzySchema.Database.Service.UserManager.Table,
      JetzySchema.Database.Service.ChatRoom.Table,

      JetzySchema.Database.Account.Flag.Entity.Enum.Table,
      JetzySchema.Database.Achievement.Type.Entity.Enum.Table,
      JetzySchema.Database.Activity.Type.Entity.Enum.Table,
      JetzySchema.Database.Address.Type.Entity.Enum.Table,
      JetzySchema.Database.Channel.Type.Entity.Enum.Table,
      JetzySchema.Database.CheckIn.Type.Entity.Enum.Table,
      JetzySchema.Database.CMS.Article.Attribute.Entity.Enum.Table,
      JetzySchema.Database.CMS.Article.Revision.Attribute.Value.Type.Entity.Enum.Table,
      JetzySchema.Database.CMS.Article.Tag.Entity.Enum.Table,
      JetzySchema.Database.CMS.Article.Type.Entity.Enum.Table,
      JetzySchema.Database.Comment.Type.Entity.Enum.Table,
      JetzySchema.Database.Contact.Type.Entity.Enum.Table,
      JetzySchema.Database.Content.Flag.Entity.Enum.Table,
      JetzySchema.Database.Credential.Provider.Entity.Enum.Table,
      JetzySchema.Database.Credential.Type.Entity.Enum.Table,
      JetzySchema.Database.Degree.Status.Entity.Enum.Table,
      JetzySchema.Database.Degree.Type.Entity.Enum.Table,
      JetzySchema.Database.Device.Token.Type.Entity.Enum.Table,
      JetzySchema.Database.Device.Type.Entity.Enum.Table,
      JetzySchema.Database.Document.Type.Entity.Enum.Table,
      JetzySchema.Database.EmergencyContact.Type.Entity.Enum.Table,
      JetzySchema.Database.Employment.Status.Entity.Enum.Table,
      JetzySchema.Database.Employment.Type.Entity.Enum.Table,
      JetzySchema.Database.Entity.Aspect.Entity.Enum.Table,
      JetzySchema.Database.File.Format.Entity.Enum.Table,
      JetzySchema.Database.Friend.Status.Entity.Enum.Table,
      JetzySchema.Database.Gender.Entity.Enum.Table,
      JetzySchema.Database.Grant.Type.Entity.Enum.Table,
      JetzySchema.Database.Group.Grant.Type.Entity.Enum.Table,
      JetzySchema.Database.Group.Join.Type.Entity.Enum.Table,
      JetzySchema.Database.Group.LookupRule.Entity.Enum.Table,
      JetzySchema.Database.Group.Permission.Entity.Enum.Table,
      JetzySchema.Database.Group.Permission.Rule.Entity.Enum.Table,
      JetzySchema.Database.Group.SignUp.Type.Entity.Enum.Table,
      JetzySchema.Database.Image.Type.Entity.Enum.Table,
      JetzySchema.Database.Interaction.Type.Entity.Enum.Table,
      JetzySchema.Database.Location.Image.Type.Entity.Enum.Table,
      JetzySchema.Database.Location.Relation.Type.Entity.Enum.Table,
      JetzySchema.Database.Location.Source.Entity.Enum.Table,
      JetzySchema.Database.Location.Type.Entity.Enum.Table,
      JetzySchema.Database.Location.Zone.Entity.Enum.Table,
      JetzySchema.Database.ManagedGroup.Type.Entity.Enum.Table,
      JetzySchema.Database.Media.Type.Entity.Enum.Table,
      JetzySchema.Database.Moderation.Resolution.Entity.Enum.Table,
      JetzySchema.Database.Moderation.Status.Enum.Entity.Enum.Table,
      JetzySchema.Database.Moderation.Type.Entity.Enum.Table,
      JetzySchema.Database.Moment.Type.Entity.Enum.Table,
      JetzySchema.Database.Notification.Delivery.Type.Entity.Enum.Table,
      JetzySchema.Database.Notification.Type.Entity.Enum.Table,
      JetzySchema.Database.OperatingSystem.Entity.Enum.Table,
      JetzySchema.Database.Opportunity.Type.Entity.Enum.Table,
      JetzySchema.Database.Origin.Source.Entity.Enum.Table,
      JetzySchema.Database.Permission.Entity.Enum.Table,
      JetzySchema.Database.Post.Content.Entity.Enum.Table,
      JetzySchema.Database.Post.Topic.Entity.Enum.Table,
      JetzySchema.Database.Post.Type.Entity.Enum.Table,
      JetzySchema.Database.Question.Type.Entity.Enum.Table,
      JetzySchema.Database.Reaction.Event.Type.Entity.Enum.Table,
      JetzySchema.Database.Reaction.Type.Entity.Enum.Table,
      JetzySchema.Database.Redeem.Type.Entity.Enum.Table,
      JetzySchema.Database.Relationship.Type.Entity.Enum.Table,
      JetzySchema.Database.Relative.Type.Entity.Enum.Table,
      JetzySchema.Database.SearchVisibility.Level.Entity.Enum.Table,
      JetzySchema.Database.ShoutOut.Type.Entity.Enum.Table,
      JetzySchema.Database.Sphinx.Index.Entity.Enum.Table,
      JetzySchema.Database.Staff.Role.Entity.Enum.Table,
      JetzySchema.Database.State.Entity.Enum.Table,
      JetzySchema.Database.Status.Entity.Enum.Table,
      JetzySchema.Database.System.Enum.Entity.Enum.Table,
      JetzySchema.Database.System.Event.Type.Entity.Enum.Table,
      JetzySchema.Database.Tag.State.Entity.Enum.Table,
      JetzySchema.Database.Tag.Type.Entity.Enum.Table,
      JetzySchema.Database.Transaction.Type.Entity.Enum.Table,
      JetzySchema.Database.User.Relation.Group.Type.Entity.Enum.Table,
      JetzySchema.Database.User.Relation.Status.Entity.Enum.Table,
      JetzySchema.Database.Visibility.Type.Entity.Enum.Table,
      JetzySchema.Database.Entity.Comment.RollUp.Table,
      JetzySchema.Database.Entity.Reaction.RollUp.Table,
      JetzySchema.Database.Entity.Share.RollUp.Table,
      JetzySchema.Database.Group.Table,

      JetzySchema.Database.Entity.Share.Table,
      JetzySchema.Database.Entity.Video.Table,
    ]
  end

  def lookup_entities() do
    [
      Jetzy.Account.Flag.Entity,
      Jetzy.Achievement.Type.Entity,
      Jetzy.Activity.Type.Entity,
      Jetzy.Address.Type.Entity,
      Jetzy.Channel.Type.Entity,
      Jetzy.CheckIn.Type.Entity,
      Jetzy.CMS.Article.Attribute.Entity,
      Jetzy.CMS.Article.Revision.Attribute.Value.Type.Entity,
      Jetzy.CMS.Article.Tag.Entity,
      Jetzy.CMS.Article.Type.Entity,
      Jetzy.Comment.Type.Entity,
      Jetzy.Contact.Type.Entity,
      Jetzy.Content.Flag.Entity,
      Jetzy.Credential.Provider.Entity,
      Jetzy.Credential.Type.Entity,
      Jetzy.Degree.Status.Entity,
      Jetzy.Degree.Type.Entity,
      Jetzy.Device.Token.Type.Entity,
      Jetzy.Device.Type.Entity,
      Jetzy.Document.Type.Entity,
      Jetzy.EmergencyContact.Type.Entity,
      Jetzy.Employment.Status.Entity,
      Jetzy.Employment.Type.Entity,
      Jetzy.Entity.Aspect.Entity,
      Jetzy.File.Format.Entity,
      Jetzy.Friend.Status.Entity,
      Jetzy.Gender.Entity,
      Jetzy.Grant.Type.Entity,
      Jetzy.Group.Grant.Type.Entity,
      Jetzy.Group.Join.Type.Entity,
      Jetzy.Group.LookupRule.Entity,
      Jetzy.Group.Permission.Entity,
      Jetzy.Group.Permission.Rule.Entity,
      Jetzy.Group.SignUp.Type.Entity,
      Jetzy.Image.Type.Entity,
      Jetzy.Interaction.Type.Entity,
      Jetzy.Location.Image.Type.Entity,
      Jetzy.Location.Relation.Type.Entity,
      Jetzy.Location.Source.Entity,
      Jetzy.Location.Type.Entity,
      Jetzy.Location.Zone.Entity,
      Jetzy.ManagedGroup.Type.Entity,
      Jetzy.Media.Type.Entity,
      Jetzy.Moderation.Resolution.Entity,
      Jetzy.Moderation.Status.Enum.Entity,
      Jetzy.Moderation.Type.Entity,
      Jetzy.Moment.Type.Entity,
      Jetzy.Notification.Delivery.Type.Entity,
      #Jetzy.Notification.Type.Entity,
      Jetzy.OperatingSystem.Entity,
      Jetzy.Opportunity.Type.Entity,
      Jetzy.Origin.Source.Entity,
      Jetzy.Permission.Entity,
      Jetzy.Post.Content.Entity,
      Jetzy.Post.Topic.Entity,
      Jetzy.Post.Type.Entity,
      Jetzy.Question.Type.Entity,
      Jetzy.Reaction.Event.Type.Entity,
      Jetzy.Reaction.Type.Entity,
      Jetzy.Redeem.Type.Entity,
      Jetzy.Relationship.Type.Entity,
      Jetzy.Relative.Type.Entity,
      Jetzy.SearchVisibility.Level.Entity,
      Jetzy.ShoutOut.Type.Entity,
      Jetzy.Sphinx.Index.Entity,
      Jetzy.Staff.Role.Entity,
      Jetzy.State.Entity,
      Jetzy.Status.Entity,
      Jetzy.System.Enum.Entity,
      Jetzy.System.Event.Type.Entity,
      Jetzy.Tag.State.Entity,
      Jetzy.Tag.Type.Entity,
      Jetzy.Transaction.Type.Entity,
      Jetzy.User.Relation.Group.Type.Entity,
      Jetzy.User.Relation.Status.Entity,
      Jetzy.Visibility.Type.Entity,
      Jetzy.Import.Error.Section.Entity,
      Jetzy.Import.Error.Type.Entity,
    ]
  end

  #-----------------------------------------------------------------------------
  # ChangeSets
  #-----------------------------------------------------------------------------
  def change_sets do
    [
      %ChangeSet{
        changeset: "Jetzy - Tanbits Shim Setup",
        author: "Keith Brings",
        update: fn() ->
                  JetzySchema.Database.UniversalIdentifierResolution.Table.create(disk: [node()])
                    :success
                 end,
        rollback: fn() ->
                    # Intentionally Left Blank to avoid loss of nonrecoverable data.
                    :removed
        end
      },

      %ChangeSet{
        changeset: "Jetzy - Initial PG Table Setup",
        author: "Keith Brings",
        note: "Initial Tables",
        update:
          fn () ->
            Enum.map(initial_tables(),
              fn (t) ->
                try do
                  create_table(t, disk: [node()])
                rescue error ->
                  Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{Exception.format(:error, error, __STACKTRACE__)}")
                  error
                catch error ->
                  Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{Exception.format(:error, error, __STACKTRACE__)}")
                  error
                end
              end)
            :success
          end,
        rollback:
          fn () ->
            Enum.map(Enum.reverse(initial_tables()), fn (t) -> destroy_table(t) end)
            :removed
          end
      },

      %ChangeSet{
        changeset: "Jetzy - UniversalIdentifierResolution.Source Populate",
        author: "Keith Brings",
        note: "Populate UID source table. ",
        update:
          fn () ->
            Amnesia.start()
            Amnesia.info()
            :ok = JetzySchema.Database.UniversalIdentifierResolution.Source.Enum.Table.wait(500)
            context = Noizu.ElixirCore.CallingContext.system()
            Jetzy.UniversalIdentifierResolution.Source.Enum.atoms()
            |> Enum.sort(&(elem(&1, 1) < elem(&2, 1)))
            |> Enum.map(
                 fn ({table, identifier}) ->
                   now = DateTime.utc_now()
                   entity = table.__noizu_info__(:entity)
                   :ok = JetzySchema.Database.UniversalIdentifierResolution.Source.Enum.Table.wait(5000)
                   Process.sleep(500)
                   # Temp hack
                   tn = try do
                          "#{table.__schema_table__}"
                   rescue _ -> ""
                   catch _ -> ""
                        end
                   
                   %Jetzy.UniversalIdentifierResolution.Source.Enum.Entity{
                     identifier: identifier,
                     table_name: tn,
                     ecto_name: "#{table}",
                     entity_name: "#{entity}",
                     description: nil,
                     time_stamp: now,
                   }
                   |> Jetzy.UniversalIdentifierResolution.Source.Enum.Repo.create!(context)
                 end
               )
            :success
          end,
        rollback:
          fn () ->
            :removed
          end
      },


      %ChangeSet{
        changeset: "Jetzy - LegacyResolution.Source Populate",
        author: "Keith Brings",
        note: "Populate UID source table. ",
        update:
          fn () ->
            :ok = JetzySchema.Database.LegacyResolution.Source.Enum.Table.wait(5000)
            context = Noizu.ElixirCore.CallingContext.system()
            Jetzy.LegacyResolution.Source.Enum.Ecto.EnumType.atom_to_enum()
            |> Enum.sort(&(elem(&1, 1) < elem(&2, 1)))
            |> Enum.map(
                 fn ({table, identifier}) ->
                   :ok = JetzySchema.Database.LegacyResolution.Source.Enum.Table.wait(5000)
                   now = DateTime.utc_now()
                   %Jetzy.LegacyResolution.Source.Enum.Entity{
                     identifier: identifier,
                     table_name: "#{table.__schema_table__}",
                     ecto_name: "#{table}",
                     description: nil,
                     time_stamp: now,
                   }
                   |> Jetzy.LegacyResolution.Source.Enum.Repo.create!(context)
                 end
               )
            :success
          end,
        rollback:
          fn () ->
            :removed
          end
      },


      # Populate Lookup Tables
      %ChangeSet{
        changeset: "Jetzy - Populate Enum Records.",
        author: "Keith Brings",
        note: "Populate/Refresh all Enum Entities.",
        update:
          fn () ->
            context = Noizu.ElixirCore.CallingContext.system()
            Jetzy.DomainObject.Schema.__refresh_enums__(context)
            :success
          end,
        rollback:
          fn () ->
            :removed
          end
      },

      # Import Interests
      %ChangeSet{
        changeset: "Jetzy - Import Interests.",
        author: "Keith Brings",
        note: "Import interest entities from MSSQL. ",
        update:
          fn () ->
            context = Noizu.ElixirCore.CallingContext.admin()
            options = nil
            #JetzyModule.LegacyModule.import_all!(Elixir.Jetzy.Interest, context, options)
            :success
          end,
        rollback:
          fn () ->
            :removed
          end
      },

      # User.Notification.Type templates
      %ChangeSet{
        changeset: "Jetzy - User Notification Types.",
        author: "Keith Brings",
        note: "User Notification Types. ",
        update:
          fn () ->
            context = Noizu.ElixirCore.CallingContext.admin()
            options = []
            types = [
              %{identifier: :friend_request_sent, title: "Friend Request Sent", description: "", template: "{{sender.name}} sent you a friend request"},
              %{identifier: :friend_request_accepted, title: "Friend Request Accepted", description: "", template: "{{sender.name}} accepted your friend request"},
              %{identifier: :post_like, title: "Post Liked", description: "", template: "{{sender.name}} liked your Post"},
              %{identifier: :post_comment, title: "Post Comment", description: "", template: "{{sender.name}} commented on your Post"},
              %{identifier: :reply, title: "Comment Reply", description: "", template: "{{sender.name}} replied to your comment"},
              %{identifier: :referral_complete, title: "Referral Registration", description: "", template: "Your referred friend {{sender.name}} is now on Jetzy!"},
              %{identifier: :tagged_in_post, title: "Tagged in Post", description: "", template: "You have been tagged in a post by {{sender.name}}"},
            ]
            Enum.map(types,
              fn(type) ->
                %Jetzy.User.Notification.Type.Entity{
                identifier: type.identifier,
                description: %{title: type.title, body: type.description},
                template: %{title: "Template", body: type.template},
                time_stamp: Noizu.DomainObject.TimeStamp.Second.now()
                } |> Jetzy.User.Notification.Type.Repo.create!(context, options)
            end)
            :success
          end,
        rollback:
          fn () ->
            :removed
          end
      },




      %ChangeSet{
        changeset: "Jetzy - Communication Channel Definitions.",
        author: "Keith Brings",
        note: "User Communication Channel Templates/Types",
        update:
          fn () ->
            context = Noizu.ElixirCore.CallingContext.admin()
            options = []


            %Jetzy.Channel.Definition.Entity{
              handle: "email",
              channel_handler: JetzyModule.Channel.Handler.Email,
              description: %{title: "Email Communication Channel", body: "Standard Email"},
              fields: %Jetzy.Channel.Definition.Field.Repo{
                entities: [
                  %{
                    field_type: :email,
                    validation: "(.+@.+)",
                    description: %{title: "Email Address", body: ""},
                  },
                  %{
                    field_type: :verified,
                    validation: "(true|false)",
                    description: %{title: "Email Verification Status", body: ""},
                  },
                  %{
                    field_type: :locale,
                    validation: ".*",
                    description: %{title: "Language Preference for this Channel", body: ""},
                  },
                ],
                length: 3,
              }
            } |> Jetzy.Channel.Definition.Repo.create!(context, options)


            %Jetzy.Channel.Definition.Entity{
              handle: "quick_blox",
              channel_handler: JetzyModule.Channel.Handler.Email,
              description: %{title: "QuickBlox Communication Channel", body: ""},
              fields: %Jetzy.Channel.Definition.Field.Repo{
                entities: [
                  %{
                    field_type: :quick_blox_user,
                    validation: ".*",
                    description: %{title: "Quick Blox User", body: ""},
                  },
                  %{
                    field_type: :quick_blox_auth,
                    validation: ".*",
                    description: %{title: "Quick Blox Author", body: ""},
                  },
                ],
                length: 2,
              }
            } |> Jetzy.Channel.Definition.Repo.create!(context, options)



            :success
          end,
        rollback:
          fn () ->
            :removed
          end
      },




      %ChangeSet{
        changeset: "Jetzy - Default Profile Images. (V4)",
        author: "Keith Brings",
        note: "User Communication Channel Templates/Types",
        update:
          fn () ->
            JetzySchema.Database.Image.Table.destroy!()
            JetzySchema.Database.Image.Table.create!(rock!: [node()])
            context = Noizu.ElixirCore.CallingContext.admin()
            options = []
            images = [
              "http://d1exz3ac7m20xz.cloudfront.net/default_profile_images/sampleImage0.png",
              "http://d1exz3ac7m20xz.cloudfront.net/default_profile_images/sampleImage1.png",
              "http://d1exz3ac7m20xz.cloudfront.net/default_profile_images/sampleImage2.png",
            ]
            entities = Enum.map(images, fn(image) ->
              case Jetzy.Image.Repo.from_uri(image, :default_profile_image, context) do
                entity = %Jetzy.Image.Entity{} -> Jetzy.Image.Repo.create!(entity, context) |> Noizu.ERP.ref
                _ -> nil
              end
            end) |> Enum.filter(&(&1))
            Jetzy.Helper.set_cached_setting(:default_profile_images, entities)
            :success
          end,
        rollback:
          fn () ->
            :removed
          end
      },
  
  
  
  
      # User.Notification.Type templates
      %ChangeSet{
        changeset: "Jetzy - User Location History Tables.",
        author: "Keith Brings",
        note: "User Notification Types. ",
        update:
          fn () ->
            create_table(JetzySchema.Database.User.Location.Table, disk: [node()])
            create_table(JetzySchema.Database.User.Location.History.Table, disk: [node()])
            :success
          end,
        rollback:
          fn () ->
            :nop
            :removed
          end
      },
  
      %ChangeSet{
        changeset: "Jetzy - Payment Providers.",
        author: "Keith Brings",
        note: "Payment Provers and Accounts (e.g. Stripe).",
        update:
          fn () ->
            create_table(JetzySchema.Database.Payment.Provider.Table, rock!: [node()])
            create_table(JetzySchema.Database.User.Payment.Provider.Account.Table, rock!: [node()])
            :success
          end,
        rollback:
          fn () ->
            JetzySchema.Database.User.Payment.Provider.Account.Table.destroy()
            JetzySchema.Database.Payment.Provider.Table.destroy()
            :removed
          end
      },
  
      


    ]
  end
end
