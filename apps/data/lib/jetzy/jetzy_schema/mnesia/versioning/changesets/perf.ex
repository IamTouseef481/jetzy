#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2019 JetzyApp All rights reserved.
#-------------------------------------------------------------------------------

defmodule JetzySchema.Mnesia.Changesets.Perf do
  use Noizu.MnesiaVersioning.SchemaBehaviour
  alias Noizu.MnesiaVersioning.ChangeSet
  # alias Jetzy.Database, as: T
  use Amnesia
  use JetzySchema.Database
  import Ecto.Query
  
  # @default_timeout 60_000
  
  #@initial_tables  [
  #]
  
  
  
  
  #-----------------------------------------------------------------------------
  # ChangeSets
  #-----------------------------------------------------------------------------
  def change_sets do
    [
      
      %ChangeSet{
        changeset: "Jetzy - Update to RockDB to reduce memory requirements.",
        author: "Keith Brings",
        update: fn() ->
        
                  switch_to_rocksdb = [
                    JetzySchema.Database.Entity.Reaction.RollUp.Table,
                    JetzySchema.Database.LocationVersionedString.Table,
                    JetzySchema.Database.User.Relative.Table,
                    JetzySchema.Database.Service.UserManager.Table,
                    JetzySchema.Database.UniversalIdentifierResolution.Table,
                    JetzySchema.Database.User.Reward.Table,
                    Noizu.AdvancedScaffolding.Database.UniversalLookup.Table,
                    JetzySchema.Database.Business.Table,
                    JetzySchema.Database.Channel.Definition.Field.Table,
                    JetzySchema.Database.Reward.Table,
                    JetzySchema.Database.User.Mute.Table,
                    JetzySchema.Database.User.Point.Balance.Table,
                    JetzySchema.Database.UserAboutVersionedString.History.Table,
                    JetzySchema.Database.VersionedString.Table,
                    JetzySchema.Database.Entity.Contact.Channel.Table,
                    JetzySchema.Database.Entity.Subject.Comment.History.Table,
                    JetzySchema.Database.UserAboutVersionedString.Table,
                    JetzySchema.Database.Contact.Channel.Field.Table,
                    JetzySchema.Database.PostVersionedString.History.Table,
                    JetzySchema.Database.TanbitsResolution.Table,
                    JetzySchema.Database.User.Friend.Table,
                    JetzySchema.Database.User.Session.Table,
                    Noizu.V3.CMS.Database.Article.Active.Version.Revision.Table,
                    JetzySchema.Database.Entity.Sphinx.Index.State.Table,
                    JetzySchema.Database.CMS.Article.Active.Version.Revision.Table,
                    JetzySchema.Database.CommentVersionedString.History.Table,
                    JetzySchema.Database.Location.Country.Table,
                    Noizu.EmailService.V3.Database.Email.Template.Table,
                    Noizu.V3.CMS.Database.Article.Version.Table,
                    JetzySchema.Database.Comment.Table,
                    JetzySchema.Database.Setting.Table,
                    JetzySchema.Database.Location.Redirect.Table,
                    JetzySchema.Database.Reward.Event.Table,
                    JetzySchema.Database.User.Friend.Request.Table,
                    JetzySchema.Database.VersionedAddress.History.Table,
                    JetzySchema.Database.VersionedBusiness.Table,
                    JetzySchema.Database.VersionedDeal.Table,
                    JetzySchema.Database.Location.Place.Table,
                    JetzySchema.Database.Post.Table,
                    JetzySchema.Database.User.Device.Table,
                    JetzySchema.Database.User.Relative.Request.Table,
                    JetzySchema.Database.UserVersionedString.History.Table,
                    JetzySchema.Database.Device.Table,
                    JetzySchema.Database.Entity.Share.RollUp.Table,
                    JetzySchema.Database.Offer.Deal.Table,
                    JetzySchema.Database.User.Friend.Lookup.Table,
                    JetzySchema.Database.VersionedAddress.Table,
                    JetzySchema.Database.VersionedName.Table,
                    JetzySchema.Database.Business.Vendor.Table,
                    JetzySchema.Database.School.Table,
                    JetzySchema.Database.User.Referral.Redemption.Table,
                    JetzySchema.Database.UserPanicVersionedString.Table,
                    JetzySchema.Database.Entity.Video.Table,
                    JetzySchema.Database.Image.Table.Migrate,
                    JetzySchema.Database.UserBioVersionedString.History.Table,
                    Noizu.AdvancedScaffolding.Database.UniversalReverseLookup.Table,
                    JetzySchema.Database.User.Referral.Code.Table,
                    JetzySchema.Database.VersionedImageString.History.Table,
                    JetzySchema.Database.CommentVersionedString.Table,
                    JetzySchema.Database.Employer.Table,
                    JetzySchema.Database.Location.City.Table,
                    JetzySchema.Database.ModerationVersionedString.Table,
                    JetzySchema.Database.Post.Entity.Tag.Contact.Table,
                    JetzySchema.Database.UserBioVersionedString.Table,
                    JetzySchema.Database.Entity.Interactions.Table,
                    JetzySchema.Database.Location.Relation.Table,
                    JetzySchema.Database.User.Relation.Group.Table,
                    JetzySchema.Database.Vocation.Table,
                    JetzySchema.Database.CheckInVersionedString.Table,
                    JetzySchema.Database.Entity.Subject.Share.History.Table,
                    JetzySchema.Database.Image.Table,
                    JetzySchema.Database.User.Session.Generation.Table,
                    JetzySchema.Database.VersionedImageString.Table,
                    JetzySchema.Database.Business.Restaurant.Table,
                    JetzySchema.Database.Location.State.Table,
                    JetzySchema.Database.Contact.Channel.Table,
                    JetzySchema.Database.Entity.Image.Table,
                    JetzySchema.Database.ModerationVersionedString.History.Table,
                    JetzySchema.Database.User.Notification.Type.Table,
                    JetzySchema.Database.Entity.Image.Table.Migrate,
                    JetzySchema.Database.User.Authentication.Setting.Table,
                    JetzySchema.Database.User.Block.Lookup.Table,
                    JetzySchema.Database.User.Follow.Table,
                    Noizu.EmailService.V3.Database.Email.Queue.Table,
                    Noizu.V3.CMS.Database.Article.Tag.Table,
                    JetzySchema.Database.Offer.Activity.Table,
                    JetzySchema.Database.OperatingSystem.Table,
                    JetzySchema.Database.User.Guid.Lookup.Table,
                    JetzySchema.Database.User.Relation.Table,
                    JetzySchema.Database.VersionedActivity.Table,
                    Noizu.AdvancedScaffolding.Database.EctoIdentifierLookup.Table,
                    JetzySchema.Database.LocationVersionedString.History.Table,
                    JetzySchema.Database.Post.Interest.Table,
                    JetzySchema.Database.User.Credential.Table,
                    JetzySchema.Database.User.Interest.Table,
                    JetzySchema.Database.VersionedLink.Table,
                    JetzySchema.Database.CMS.Article.Version.Revision.Table,
                    JetzySchema.Database.Entity.Comment.RollUp.Table,
                    JetzySchema.Database.Interest.Table,
                    JetzySchema.Database.System.Event.Table,
                    JetzySchema.Database.VersionedNightLife.Table,
                    Noizu.V3.CMS.Database.Article.Active.Version.Table,
                    Noizu.V3.CMS.Database.Article.VersionSequencer.Table,
                    JetzySchema.Database.Degree.Table,
                    JetzySchema.Database.Business.Location.Table,
                    JetzySchema.Database.Business.Vendor.Location.Table,
                    JetzySchema.Database.CMS.Article.ActiveTag.Table,
                    JetzySchema.Database.CMS.Article.Index.Table,
                    JetzySchema.Database.Group.Table,
                    JetzySchema.Database.Offer.Table,
                    JetzySchema.Database.PostVersionedString.Table,
                    JetzySchema.Database.UserPanicVersionedString.History.Table,
                    JetzySchema.Database.UserVersionedString.Table,
                    JetzySchema.Database.CMS.Article.Active.Version.Table,
                    JetzySchema.Database.CMS.Article.Table,
                    JetzySchema.Database.CMS.Article.Version.Table,
                    JetzySchema.Database.Service.ChatRoom.Table,
                    JetzySchema.Database.User.Block.Table,
                    JetzySchema.Database.VersionedLink.History.Table,
                    JetzySchema.Database.VersionedName.History.Table,
                    JetzySchema.Database.Business.Hotel.Table,
                    JetzySchema.Database.Entity.Share.Table,
                    JetzySchema.Database.User.Notification.Event.Table,
                    JetzySchema.Database.User.Notification.Setting.Table,
                    Noizu.EmailService.V3.Database.Email.Queue.Event.Table,
                    JetzySchema.Database.Business.Hotel.Location.Table,
                    JetzySchema.Database.Business.Restaurant.Location.Table,
                    JetzySchema.Database.CMS.Article.VersionSequencer.Table,
                    JetzySchema.Database.LegacyResolution.Table,
                    Noizu.SmartToken.V3.Database.Token.Table,
                    Noizu.V3.CMS.Database.Article.Version.Revision.Table,
                    JetzySchema.Database.VersionedString.History.Table,
                    JetzySchema.Database.User.Location.History.Table,
                    JetzySchema.Database.User.Location.Table,
                    JetzySchema.Database.Reward.Tier.Table,
                    Noizu.V3.CMS.Database.Article.Table,
                    JetzySchema.Database.Import.Error.Table,
                    Noizu.V3.CMS.Database.Article.Index.Table,
                  ]
                  Enum.map(switch_to_rocksdb,
                    fn(t) ->
                      case t.copying(node(), :rock!) do
                        :ok -> :ok
                        {:error, {:already_exists, _, _, {:ext, :rocksdb_copies, :mnesia_rocksdb}}} -> :ok
                      end
                  end)
                  :success
        end,
        rollback: fn() ->
            :success
        end
      },
  
  
  
  
    ]
  end

end