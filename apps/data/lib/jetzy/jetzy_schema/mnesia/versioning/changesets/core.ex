#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2019 JetzyApp All rights reserved.
#-------------------------------------------------------------------------------

defmodule JetzySchema.Mnesia.Changesets.Core do
  use Noizu.MnesiaVersioning.SchemaBehaviour
  alias Noizu.MnesiaVersioning.ChangeSet
  # alias Jetzy.Database, as: T
  use Amnesia
  use JetzySchema.Database
  # import Ecto.Query

  # @default_timeout 60_000

  #@initial_tables  [
  #]

  #-----------------------------------------------------------------------------
  # ChangeSets
  #-----------------------------------------------------------------------------
  def change_sets do
    [
      %ChangeSet{
        changeset: "Jetzy - Tanbits Subscription",
        author: "Keith Brings",
        update: fn() ->
                  JetzySchema.Database.Subscription.Group.Table.create(rock!: [node()])
                  JetzySchema.Database.Subscription.Table.create(rock!: [node()])
                  JetzySchema.Database.User.Subscription.Table.create(rock!: [node()])
                  :success
        end,
        rollback: fn() ->
                    JetzySchema.Database.User.Subscription.Table.destroy()
                    JetzySchema.Database.Subscription.Table.destroy()
                    JetzySchema.Database.Subscription.Group.Table.destroy()
                    :removed
        end
      },


      %ChangeSet{
        changeset: "Jetzy - Email Templates",
        author: "Keith Brings",
        update: fn() ->

                  %Noizu.EmailService.V3.Email.Template.Entity{
                    external_template_identifier: {:sendgrid, "d-56e9bb15e0f440cfbe30ef082421e2ea"},
                    identifier: {:jetzy, :confirm_delete},
                    name: "Delete Confirmation",
                  } |> Noizu.EmailService.V3.Email.Template.Repo.update!(Noizu.ElixirCore.CallingContext.admin())



                %Noizu.EmailService.V3.Email.Template.Entity{
                  external_template_identifier: {:sendgrid, "d-eabe54b78a884c12a7be75311cf5107d"},
                  identifier: {:jetzy, :reservation},
                  name: "Select Reservation",
                } |> Noizu.EmailService.V3.Email.Template.Repo.update!(Noizu.ElixirCore.CallingContext.admin())


                  :success
        end,
        rollback: fn() ->
                    :success
        end
      },


      %ChangeSet{
        changeset: "Jetzy - Email Templates 2",
        author: "Keith Brings",
        update: fn() ->

                  %Noizu.EmailService.V3.Email.Template.Entity{
                    external_template_identifier: {:sendgrid, "d-6017abddf53e4c9ba11320f79b089126"},
                    identifier: {:jetzy, :select_signup},
                    name: "Select SignUp",
                  } |> Noizu.EmailService.V3.Email.Template.Repo.update!(Noizu.ElixirCore.CallingContext.admin())


                  %Noizu.EmailService.V3.Email.Template.Entity{
                    external_template_identifier: {:sendgrid, "d-4fc7ac07b4c4494eb0a8aa01d9331912"},
                    identifier: {:jetzy, :select_approved},
                    name: "Select Approved",
                  } |> Noizu.EmailService.V3.Email.Template.Repo.update!(Noizu.ElixirCore.CallingContext.admin())


                  :success
        end,
        rollback: fn() ->
                    :success
        end
      },


      %ChangeSet{
        changeset: "Jetzy - User index update.",
        author: "Keith Brings",
        update: fn() ->
                  Amnesia.start
                  JetzySchema.Database.User.Table.destroy!()
                  Process.sleep(1000)
                  JetzySchema.Database.User.Table.create!(rock!:  [node()])
                  :success
        end,
        rollback: fn() ->
                    :success
        end
      },


      %ChangeSet{
        changeset: "Jetzy - Select.SignUp",
        author: "Keith Brings",
        update: fn() ->
                  Amnesia.start
                  Process.sleep(1000)
                  JetzySchema.Database.Select.SignUp.Table.create!(rock!:  [node()])
                  :success
        end,
        rollback: fn() ->
                    :success
        end
      },

      %ChangeSet{
        changeset: "Jetzy - Select.Reservation.Tracking",
        author: "Keith Brings",
        update: fn() ->
                  Amnesia.start
                  Process.sleep(1000)
                  JetzySchema.Database.Select.Reservation.Tracking.Table.create!(rock!:  [node()])
                  :success
        end,
        rollback: fn() ->
                     JetzySchema.Database.Select.Reservation.Tracking.Table.destroy()
                    :success
        end
      },

      %ChangeSet{
        changeset: "Jetzy - Subscription and Subscription Group. (v2)",
        author: "Keith Brings",
        update: fn() ->
                  context = Noizu.ElixirCore.CallingContext.system()
                  Amnesia.start()
                  Process.sleep(1000)
                  JetzySchema.Database.Feature.Table.create!(rock!: [node()])
                  JetzySchema.Database.Feature.Set.Table.create!(rock!: [node()])


                  sf = %Jetzy.Feature.Entity{
                    identifier: :select,
                    description: %{title: "Select Access", description: "Control access to Select"}
                  } |> Jetzy.Feature.Repo.create!(context)  |> Noizu.ERP.ref()
                  pf = %Jetzy.Feature.Entity{
                    identifier: :post,
                    description: %{title: "Post", description: "Grant post permission"}
                  } |> Jetzy.Feature.Repo.create!(context) |> Noizu.ERP.ref()
                  mf = %Jetzy.Feature.Entity{
                    identifier: :message,
                    description: %{title: "Message", description: "Grant Message permission"}
                  } |> Jetzy.Feature.Repo.create!(context)  |> Noizu.ERP.ref()

                  uvfs = %Jetzy.Feature.Set.Entity{
                    identifier: UUID.string_to_binary!("b70896e4-3d82-470b-ad69-593714f01506"),
                    handle: "unverified-user",
                    description: %{title: "Unverified User Features", description: "Feature Set for Unverified users."},
                    features: %{
                      pf => {:limit, {:day, 3}},
                      mf => :denied
                    }
                  } |> Jetzy.Feature.Set.Repo.create!(context, %{override_identifier: true})

                  vfs = %Jetzy.Feature.Set.Entity{
                           identifier: UUID.string_to_binary!("f949875a-67b0-43fd-8bd6-ca438a42603b"),
                           handle: "verified-user",
                           description: %{title: "Verified User Features", description: "Feature Set for Verified users."},
                           features: %{
                             pf => :unlimited,
                             mf => :unlimited,
                           }
                         } |> Jetzy.Feature.Set.Repo.create!(context, %{override_identifier: true})



                  g = %Jetzy.Subscription.Group.Entity{
                        identifier: UUID.string_to_binary!("436571bb-85ba-46e9-8bbb-717c42342e16"),
                        handle: "select",
                        description: %{title: "Jetzy Select Subscription Details", body: "Group of subscriptions related to Select access"}
                      } |> Jetzy.Subscription.Group.Repo.create!(context, %{override_identifier: true})

                  %Jetzy.Subscription.Entity{
                    identifier: UUID.string_to_binary!("f3a2a426-3695-41f6-a49a-dee58df43538"),
                    handle: "select-standard",
                    subscription_group: Noizu.ERP.ref(g),
                    description: %{title: "Jetzy Select Subscription Details", body: "Group of subscriptions related to Select access"},
                    details: %{
                      stripe: %{plan: "price_1LqTtbB7XccR5GE0Xq8tf6CC"},
                    },
                    features: %{
                      sf => :unlimited
                    }
                  } |> Jetzy.Subscription.Repo.create!(context, %{override_identifier: true})

                  :success
        end,
        rollback: fn() ->
                    :success
        end
      },

    ]
  end

end
