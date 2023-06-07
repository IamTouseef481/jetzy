#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Referral.Code do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "referral-code"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 127
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      public_field :user
      public_field :weight
      public_field :code
      public_field :status

      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end

    def enable(%__MODULE__{} = code, context, options \\ nil) do
      now = options[:current_time] || DateTime.utc_now()
      %Jetzy.User.Referral.Code.Entity{code| status: :active, time_stamp: %Noizu.DomainObject.TimeStamp.Second{code.time_stamp| modified_on: now}}
      |> Jetzy.User.Referral.Code.Repo.update!(context)
    end

    def disable(%__MODULE__{} = code, context, options \\ nil) do
      now = options[:current_time] || DateTime.utc_now()
      %Jetzy.User.Referral.Code.Entity{code| status: :inactive, time_stamp: %Noizu.DomainObject.TimeStamp.Second{code.time_stamp| modified_on: now}}
      |> Jetzy.User.Referral.Code.Repo.update!(context)
    end

    def referrals(%__MODULE__{} = code, context, options \\ nil) do
       # todo pagination logic.
       Jetzy.User.Referral.Redemption.Repo.by_code(code, context, options)
    end

  end

  defmodule Repo do
    #@digits String.codepoints("0123456789")
    @alphabet String.codepoints("abcdefghijklmnopqrstuvwxyz")
    @reduced_alpha String.codepoints("23456789abcdefghkmnpqrstuvwxyz")
    @max_reservation_period [hours: 24]

    # import Ecto.Query, only: [from: 2]
    Noizu.DomainObject.noizu_repo do
    end

    def by_code(code, _context, options \\ nil) when is_bitstring(code) do
      case Amnesia.Selection.values(JetzySchema.Database.User.Referral.Code.Table.match!(code: code)) do
        v = [h|_] ->
          cond do
            options[:all] -> v
            :else -> h
          end
        _ -> nil
      end
    end

    def by_user(user, _context, options \\ nil) do
      if ref = Jetzy.User.Entity.ref(user) do
        case Amnesia.Selection.values(JetzySchema.Database.User.Referral.Code.Table.match!(user: ref)) do
          v = [h|_] ->
            cond do
              options[:all] -> v
              :else -> h
            end
          _ -> nil
        end
      end
    end

    #---------------------------------------------------
    # code_available?
    #---------------------------------------------------
    def code_available?(_user, nil, _context, _options), do: false
    def code_available?(user, code, context, options) do
      cond do
        String.length(code) < 3 -> false
        :else ->
          now = options[:current_time] || DateTime.utc_now()
          existing = by_code(code, context, options)
          user_ref = Noizu.ERP.ref(user)
          cond do
            existing && existing.user == user_ref && existing.status == :pending -> true
            existing && existing.status == :pending && DateTime.compare(Timex.shift(existing.time_stamp.modified_on, @max_reservation_period), now) == :lt ->
              cond do
                options[:reserve] ->
                  %Jetzy.User.Referral.Code.Entity{existing|
                    user: Noizu.ERP.ref(user),
                    time_stamp: %Noizu.DomainObject.TimeStamp.Second{existing.time_stamp| modified_on: now}
                  } |> Jetzy.User.Referral.Code.Repo.update!(context)
                  true
                :else -> true
              end
            existing -> false
            options[:reserve] ->
              %Jetzy.User.Referral.Code.Entity{
                user: Noizu.ERP.ref(user),
                weight: 0,
                code: code,
                status: :pending,
                time_stamp: Noizu.DomainObject.TimeStamp.Second.new(now)
              } |> Jetzy.User.Referral.Code.Repo.create!(context)
              true
            :else -> true
          end
      end
    end

    #---------------------------------------------------
    # claim
    #---------------------------------------------------
    def claim(user, code, context, options \\ nil) do
      existing = by_code(code, context, options)
      cond do
        !existing -> false
        user_entity = Jetzy.User.Entity.entity!(user) ->
          now = options[:current_time] || DateTime.utc_now()
          %Jetzy.User.Referral.Redemption.Entity{
            user: existing.user,
            referred_user: Jetzy.User.Entity.ref(user_entity),
            user_referral_code: Jetzy.User.Referral.Code.Entity.ref(existing),
            entered_referral_on: now,
            joined_select_on: nil,
            time_stamp: Noizu.DomainObject.TimeStamp.Second.new(now)
          } |> Jetzy.User.Referral.Redemption.Repo.create!(Noizu.ElixirCore.CallingContext.system(context))
        :else ->
          # Not a existing user but valid code
          true
      end
    end

    #---------------------------------------------------
    # register
    #---------------------------------------------------
    def register(user, code, context, options \\ nil) do
      cond do
        String.length(code) < 3 -> false
        :else ->
          now = options[:current_time] || DateTime.utc_now()
          existing = by_code(code, context, options)
          user_ref = Noizu.ERP.ref(user)
          cond do
            existing && existing.user == user_ref && existing.status == :pending ->
              %Jetzy.User.Referral.Code.Entity{existing|
                status: :active,
                weight: options[:weight] || 0,
                time_stamp: %Noizu.DomainObject.TimeStamp.Second{existing.time_stamp| modified_on: now}
              } |> Jetzy.User.Referral.Code.Repo.update!(context)
            existing && existing.status == :pending && DateTime.compare(Timex.shift(existing.time_stamp.modified_on, @max_reservation_period), now) == :lt ->
              %Jetzy.User.Referral.Code.Entity{existing|
                user: user_ref,
                status: :active,
                weight: options[:weight] || 0,
                time_stamp: %Noizu.DomainObject.TimeStamp.Second{existing.time_stamp| modified_on: now}
              } |> Jetzy.User.Referral.Code.Repo.update!(context)
            existing -> false
            :else ->
              %Jetzy.User.Referral.Code.Entity{
                user: user_ref,
                weight: options[:weight] || 0,
                code: code,
                status: :active,
                time_stamp: Noizu.DomainObject.TimeStamp.Second.new(now)
              } |> Jetzy.User.Referral.Code.Repo.create!(context)
          end
      end
    end

    #---------------------------------------------------
    # suggest
    #---------------------------------------------------
    def suggest(user, context, options) do
      options = put_in(options || [], [:reserve], true)
      count = (options[:count] || 5) - 1
      user = Jetzy.User.Entity.entity!(user)
      user_name = user && Jetzy.VersionedName.Entity.entity!(user.name)
      initials = cond do
                   user_name.first && user_name.middle && user_name.last -> String.first(user_name.first) <> String.first(user_name.middle) <> String.first(user_name.last)
                   user_name.first && user_name.last -> String.first(user_name.first) <> String.first(user_name.last)
                   user_name.first -> String.slice(user_name.first, 0..2)
                   user_name.last -> String.slice(user_name.last, 0..2)
                   login_name = Jetzy.User.Entity.login_name(user, context, options) -> String.slice(login_name, 0..2)
                   :else -> Enum.take_random(@alphabet, 2)
                 end |> String.upcase()
      default_suggestion = unique_code_suffix(user, initials, :numeric, 4, 1, context, options)

      cond do
        count == 0 -> [default_suggestion]
        :else ->
          # Primary Aspects
          primary_aspects = user_name && [user_name.first, user_name.middle, user_name.last] || []
          primary_aspects = primary_aspects ++ [initials]
          primary_aspects = primary_aspects ++ [] # pending
          primary_aspects = case Enum.filter(primary_aspects, &(&1)) do
                              [] -> ["Invite"]
                              v -> v
                            end

          # Interests, etc.
          secondary_aspects = (Jetzy.User.Entity.interests(user, context, []) || [])
                              |> Enum.map(fn(interest) -> interest.slug end)
                              |> Enum.filter(&(&1))
          secondary_aspects = case secondary_aspects do
                                [] -> ["Adventure"]
                                v -> v
                              end

          # date of birth, age, etc.
          digits = user.date_of_birth && [
            "#{user.date_of_birth.year}",
            String.pad_leading("#{user.date_of_birth.month}", 2, "0"),
            String.pad_leading("#{user.date_of_birth.day}", 2, "0")
          ]
          digits = digits ++  [
            "#{user.time_stamps.created_on.year}",
            String.pad_leading("#{user.time_stamps.created_on.month}", 2, "0"),
            String.pad_leading("#{user.time_stamps.created_on.day}", 2, "0")
          ]
          digits = Enum.filter(digits, &(&1))
          digits = case digits do
                     [] -> ["#{DateTime.utc_now().year}"]
                     v -> v
                   end

          permutations = for x <- primary_aspects, y <- secondary_aspects, z <- secondary_aspects, t <- digits, y != z, do: [x, y, z, t]
          permutations = permutations |> Enum.map(fn(p) -> Enum.filter(p, &(&1)) |> Enum.join("-") end)
          permutations = Enum.take_random(permutations, length(permutations))
          [default_suggestion] ++ Enum.map_reduce(0..(count-1), permutations,
            fn(_, acc) ->
              prepare_suggestions(user, acc, context, options)
            end
          )
      end
    end

    #---------------------------------------------------
    # unique_code_suffix
    #---------------------------------------------------
    def unique_code_suffix(_user, _prefix, _type, _padding, digits, _context, _options) when digits > 8, do: nil
    def unique_code_suffix(user, prefix, :numeric, padding, digits, context, options) do
      c = :math.pow(10, digits) - 1
      effective_padding = Enum.max([padding, digits])
      search_space = 0 .. c |> Enum.take_random(c)
      available = Enum.find(search_space, &(code_available?(user, prefix <> String.pad_leading("#{&1}", effective_padding, "0"), context, options)))
      available || unique_code_suffix(user, prefix, :numeric, padding, digits + 1, context, options)
    end

    def unique_code_suffix(user, prefix, :alpha_numerica, padding, digits, context, options) do
      search_space = Enum.reduce(0..digits - 1, @reduced_alpha,
        fn(_, acc) ->
          for x <- acc, y <- @reduced_alpha, do: x <> y
        end
      )
      search_space = Enum.take_random(search_space, length(search_space))
      effective_padding = Enum.max([padding, digits])
      available = Enum.find(search_space, &(code_available?(user, prefix <> String.pad_leading(&1, effective_padding, "0"), context, options)))
      available || unique_code_suffix(user, prefix, :alpha_numerica, padding, digits + 1, context, options)
    end

    #---------------------------------------------------
    # prepare_suggestions
    #---------------------------------------------------
    def prepare_suggestions(user, [h|t] = _permutations, context, options) do
      case h do
        v when is_bitstring(v) ->
          cond do
            code_available?(user, v, context, options) -> {v, t ++ [{0,v}]}
            :else -> prepare_suggestions(user, t ++ [{0,v}], context, options)
          end
        {n, v} when is_bitstring(v) ->
          modifier = Enum.map(0..(n+1), fn(_) -> Enum.random(@reduced_alpha) end)  |> Enum.join("")
          vm = v <> ":" <> String.pad_leading(modifier, 3, "0")
          cond do
            code_available?(user, vm, context, options) -> {vm, t ++ [{n + 1,v}]}
            :else -> prepare_suggestions(user, t ++ [{n + 1,v}], context, options)
          end
      end
    end
  end
end
