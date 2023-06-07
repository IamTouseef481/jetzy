
Amnesia.info(:tables) |> Amnesia.Table.wait
context = Noizu.ElixirCore.CallingContext.admin()

# 0. Remaining
import Ecto.Query, only: [from: 2]
query = from u in Data.Schema.User, where: 1 == 1, select: [u.id], limit: 50000000
tanbits_users = Data.Repo.all(query) |> List.flatten()
query = from u in JetzySchema.MSSQL.User.Table, where: 1 == 1, select: [u.id], limit: 50000000
legacy_users = JetzySchema.MSSQL.Repo.all(query) |> List.flatten()
remaining = legacy_users -- tanbits_users
Logger.info "Remaining| #{inspect length remaining}"

# 1. Iterate over users and replace deactivated flag, and location details.
import Ecto.Query, only: [from: 2]
query = from u in Data.Schema.User, where: 1 == 1, select: [u.id], limit: 50000000
tanbits_users = Data.Repo.all(query) |> List.flatten()
Enum.map(tanbits_users, fn(user) ->
  user_entity = Data.Context.get(Data.Schema.User, user) |> Data.Context.Users.preload_all()
  if legacy = JetzySchema.MSSQL.Repo.get(JetzySchema.MSSQL.User.Table, user) do
    update = %{
      home_town_country: legacy.home_town_country || "",
      home_town_city: legacy.home_town_city  || "",
      current_country: legacy.current_country  || "",
      current_city: legacy.current_city  || "",
      employer: legacy.employer  || "",
      school: legacy.school  || "",
      is_deactivated: legacy.is_deactivated,
      referral_code: legacy.referral_code
    }
    changeset = Data.Schema.User.changeset(user_entity, update)
    Data.Repo.update(changeset)
    Logger.info "Updated: #{inspect user}"
  end
end)

# 2. Import missing users.
context = Noizu.ElixirCore.CallingContext.admin()
import Ecto.Query, only: [from: 2]
query = from u in Data.Schema.User, where: 1 == 1, select: [u.id], limit: 50000000
tanbits_users = Data.Repo.all(query) |> List.flatten()
query = from u in JetzySchema.MSSQL.User.Table, where: 1 == 1, select: [u.id], limit: 50000000
legacy_users = JetzySchema.MSSQL.Repo.all(query) |> List.flatten()
remaining = legacy_users -- tanbits_users
r = Enum.map(remaining, fn(legacy_guid) ->
     try do
       legacy = JetzySchema.MSSQL.Repo.get(JetzySchema.MSSQL.User.Table, legacy_guid)
       query = from u in Data.Schema.User, where: u.email == ^legacy.email, select: u
       case Data.Repo.all(query) do
        [%{email: email} = record] ->
          record = Data.Context.Users.preload_all(record)
          case String.split(email, "@") do
            [u,d] ->
              cs =  Data.Schema.User.changeset(record, %{email: "#{u}+duplicate@#{d}"})
              Data.Repo.update!(cs)
              other -> {:email_error, other}
          end
          other -> {:no_match, other}
       end

       case Jetzy.User.Repo.import!(legacy_guid, context, [auto: true]) do
         {:imported, _} ->
           Logger.info("imported #{legacy_guid}")
         error = {:error, _} ->
           Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{inspect error, pretty: true}")
           error
         error ->
           Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{inspect error, pretty: true}")
           error
       end
     rescue
       error ->
         Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{Exception.format(:error, error, __STACKTRACE__)}")
         error
     catch
       error ->
         Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{Exception.format(:error, error, __STACKTRACE__)}")
         error
       _,error ->
         Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{Exception.format(:error, error, __STACKTRACE__)}")
         error
     end
end)

# 3. Update Friend List
import Ecto.Query, only: [from: 2]
context = Noizu.ElixirCore.CallingContext.admin()
options = []
query = from u in JetzySchema.MSSQL.User.Table, where: 1 == 1, select: [u.id], limit: 50000000
legacy_users = JetzySchema.MSSQL.Repo.all(query) |> List.flatten()
Enum.map(legacy_users, fn(guid) ->
  user_ref = Jetzy.User.Guid.Lookup.Repo.by_guid!(guid, context, options)
  cond do
    user = Noizu.ERP.entity!(user_ref) ->
      Logger.info "Importing #{guid} relations"
      Jetzy.User.Repo.import_user_relations(user, context, options)
    :else -> :nop
  end
end)


# 4. Repair blocks.
context = Noizu.ElixirCore.CallingContext.admin()
r = Enum.map(JetzySchema.Database.User.Block.Table.keys!, fn(key) ->
  block = Jetzy.User.Block.Entity.entity!(key)
  case Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.UserBlock, Noizu.ERP.ref(block), context, []) do
    {:ref, _, id} ->
      record = Data.Repo.get(Data.Schema.UserBlock, id)
      record && Data.Repo.delete(record)
      try do
        Jetzy.TanbitsResolution.Repo.remove_by_ref_and_id!(Noizu.ERP.ref(block), Data.Schema.UserBlock, id, context, [])
        catch _ -> :ok
      end

      {:patched, key}
    _ -> {:no_match, key}
  end
end)


# 5. Import City Long Latitude.
import Ecto.Query, only: [from: 2]
context = Noizu.ElixirCore.CallingContext.admin()
query = from l in JetzySchema.MSSQL.CityLatLong.Table, where: 1 == 1, select: [l.id], limit: 5000000
keys = JetzySchema.MSSQL.Repo.all(query) |> List.flatten()
Enum.map(keys,  fn(key) ->
  Jetzy.Location.City.Repo.by_legacy_city!(key, context, [])
end)

# 6. Import Geo Locations
context = Noizu.ElixirCore.CallingContext.admin()
JetzyModule.LegacyModule.import_all!(Jetzy.User.Location.History, context, [refresh: true])

# 7. Import Points Tables
context = Noizu.ElixirCore.CallingContext.admin()
JetzyModule.LegacyModule.import_all!(Jetzy.User.Reward.Transaction.Event, context)

# 8. Import Notifications
context = Noizu.ElixirCore.CallingContext.admin()
JetzyModule.LegacyModule.import_all!(Jetzy.User.Notification.Type, context)

# 9. Notification Settings.
context = Noizu.ElixirCore.CallingContext.admin()
JetzyModule.LegacyModule.import_all!(Jetzy.User.Notification.Setting, context)


# 10. Notification Event
context = Noizu.ElixirCore.CallingContext.admin()
JetzyModule.LegacyModule.import_all!(Jetzy.User.Notification.Event, context)
#import_for_user!(guid, Jetzy.User.Notification.Event, page, context, options)

# 11. Import Users
context = Noizu.ElixirCore.CallingContext.admin()
JetzyModule.LegacyModule.import_all!(Jetzy.User, context, [auto: true])

# 12. Import Reward Events
context = Noizu.ElixirCore.CallingContext.admin()
JetzyModule.LegacyModule.import_all!(Jetzy.Reward.Event, context, [auto: true])

# 13. Transactions
context = Noizu.ElixirCore.CallingContext.admin()
JetzyModule.LegacyModule.import_all!(Jetzy.User.Reward.Transaction.Event, context, [auto: true])
JetzyModule.LegacyModule.import_all!(Jetzy.User.Reward.Transaction.Offer, context, [auto: true])

# 14. Set point tallies.
query = from u in Data.Schema.User, where: 1 == 1, select: [u.id], limit: 50000000
tanbits_users = Data.Repo.all(query) |> List.flatten()
Enum.map(tanbits_users, fn(user) ->
  query = from u in Data.Schema.UserRewardTransaction,
           where: u.user_id == ^user,
           where: u.is_canceled == false,
           select: sum(u.point)
  p = Data.Repo.one(query) || 0
  query = from u in Data.Schema.UserOfferTransaction,
               where: u.user_id == ^user,
               where: u.is_canceled == false,
               select: sum(u.point)
  p2 = Data.Repo.one(query) || 0
  points = round(p - p2)
end)

# 14.b Legacy
import Ecto.Query
user = "e9ac1480-6f4d-42b8-8bbd-29fc8cd0f178"
query = from u in Data.Schema.UserRewardTransaction,
             where: u.user_id == ^user,
             where: u.is_canceled == false,
             select: sum(u.point)
p = Data.Repo.one(query) || 0
query = from u in Data.Schema.UserOfferTransaction,
             where: u.user_id == ^user,
             where: u.is_canceled == false,
             select: sum(u.point)
p2 = Data.Repo.one(query) || 0
mvp_points = round(p - p2)


query = from u in JetzySchema.MSSQL.User.Reward.Transaction.Table,
             where: u.user_id == ^user,
             where: u.is_canceled == false,
             select: sum(u.point)
p = JetzySchema.MSSQL.Repo.one(query) || 0

query = from u in JetzySchema.MSSQL.User.Offer.Transaction.Table,
             where: u.user_id == ^user,
             where: u.is_canceled == false,
             select: sum(u.point)
p2 = JetzySchema.MSSQL.Repo.one(query) || 0

legacy_points = round(p - p2)

%{
legacy: legacy_points,
mvp: mvp_points
}


# 15. Populate User Referrals for legacy.

import Ecto.Query, only: [from: 2, union_all: 2]
#query = from u in Data.Schema.User, where: u.is_referral == true and not is_nil(u.friend_code), select: %{user: u.id, email: u.email,  code: u.friend_code}, limit: 50000000
#friend_codes = Data.Repo.all(query)
query = from u in JetzySchema.MSSQL.User.Table, where: u.is_referral == true and not is_nil(u.friend_code), select: %{user: u.id, email: u.email,  code: u.friend_code}, limit: 50000000
friend_codes = JetzySchema.MSSQL.Repo.all(query)
now = DateTime.utc_now()
r2 = Enum.map(friend_codes, fn(referral) ->
   q1 = from u in Data.Schema.User, where: u.referral_code == ^referral.code, select: %{user: u.id}, limit: 1
   m = case Data.Repo.all(q1) do
      [referrer] -> {:match, referrer}
      _ ->
        q2 = from u in Data.Schema.UserReferralCodeLog, where: u.referral_code == ^referral.code, select: %{user: u.user_id}, limit: 1
        case Data.Repo.all(q2) do
          [referrer] -> {:match2, referrer}
          _ -> {:skip, referral}
        end
   end
   
   case m do
     {match_type, referrer} when match_type in [:match, :match2]->
       email = String.downcase(referral.email)
       q3 = from u in Data.Schema.UserReferral, where: fragment("lower(?) = ?", u.referred_to, ^email) and u.referred_from_id == ^referrer.user, limit: 1
       case Data.Repo.all(q3) do
          [e] -> {:existing, {referral, e}}
          _ ->
            insert = %{
              deleted_at: nil,
              inserted_at: now,
              is_accept: true,
              referral_code: referral.code,
              referred_from_id: referrer.user,
              referred_to: referral.email,
              updated_at: now
            }
            o = Data.Context.create(Data.Schema.UserReferral, insert)
            Data.Context.UserReferrals.check_is_refferal_by_email__clear_cache(referral.email)
            {:insert, {m, referral, o}}
       end
     v -> v
   end
end)

f2 = Enum.filter(r2, fn({a,b}) -> a == :insert end)



# hack
require Logger
context = Noizu.ElixirCore.CallingContext.admin()
options = [auto: true]
import Ecto.Query, only: [from: 2]
query = from l in JetzySchema.MSSQL.User.Offer.Transaction.Table, where: 1 == 1, select: [l.id], order_by: [desc: l.id]
keys = JetzySchema.MSSQL.Repo.all(query) |> List.flatten
t = Task.async_stream(keys, fn(key) ->
  try do
    post = JetzySchema.MSSQL.Repo.get(JetzySchema.MSSQL.User.Offer.Transaction.Table, key)

    
    
    Jetzy.User.Reward.Transaction.Repo.import!(post, context, options)
  rescue e ->
    Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
  catch
    :exit, e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
    e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
  end
end, max_concurrency: 32, timeout: :infinity)
r = Enum.map(t, &(&1))
e = Enum.filter(r, fn(x) ->
  case x do
    {:ok, {:error, {:exists, _}}} -> true
    _ -> false
  end
end)


# - Patch due to incorrect initial import. *PURGE RECORD*
context = Noizu.ElixirCore.CallingContext.admin()
import Ecto.Query, only: [from: 2]

query = from l in JetzySchema.MSSQL.User.Reward.Transaction.Table, where: 1 == 1, select: [l.id]
keys = JetzySchema.MSSQL.Repo.all(query) |> List.flatten

query = from l in JetzySchema.PG.User.Reward.Transaction.Table, where: 1 == 1, select: [l.identifier]
k2 = JetzySchema.PG.Repo.all(query) |> List.flatten
JetzySchema.PG.Repo.delete_all(query)

query = from l in JetzySchema.PG.LegacyResolution.Table, where: l.source == JetzySchema.PG.User.Reward.Transaction.Table, select: [l.identifier]
JetzySchema.PG.Repo.delete_all(query)


JetzySchema.Database.LegacyResolution.Table.match!(ref: {:ref, Jetzy.User.Reward.Transaction.Entity, :_})
|> Amnesia.Selection.values
|> Enum.map(&(JetzySchema.Database.LegacyResolution.Table.delete!(&1.identifier)))




# 13.b Todo for each user calculate their point balance by summing






#
#
#query = from r in JetzySchema.PG.TanbitsResolution.Table,
#             where: r.tanbits_source == Data.Schema.UserBlock,
#             select: r
#JetzySchema.PG.Repo.delete_all(query)
#


persistence_layer = Jetzy.User.Block.Entity.__persistence__()[:schemas][Data.Repo]
Enum.map(JetzySchema.Database.User.Block.Table.keys!, fn(key) ->
  block = Jetzy.User.Block.Entity.entity!(key)
  Jetzy.User.Block.Repo.layer_create!(persistence_layer, block, context, [])
end)


persistence_layer = Jetzy.User.Follow.Entity.__persistence__()[:schemas][Data.Repo]
Enum.map(JetzySchema.Database.User.Follow.Table.keys!, fn(key) ->
  block = Jetzy.User.Follow.Entity.entity!(key)
  Jetzy.User.Follow.Repo.layer_create!(persistence_layer, block, context, [])
end)


Jetzy.TanbitsResolution.Repo.remove_by_ref_and_id!(Noizu.ERP.ref(block), Data.Schema.UserBlock, id, context, [])




