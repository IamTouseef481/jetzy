#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 TravellersConnect, Inc.
#-------------------------------------------------------------------------------
if Application.get_env(:api, :tanbits_shim)[:include_vnext] do

defmodule Jetzy.QueryResponse do

  @vsn 1.0

  @type t :: %__MODULE__{
               records: List.t,
               vsn: float
             }

  defstruct [
    records: [],
    vsn: @vsn
  ]

  # TODO - implement poison encoder that processes list in parallel

end

defmodule JetzyApi.V2_0.Query.Controller do
  import JetzyWeb.Helpers
  use JetzyApi, :controller
  #  alias Giza.SphinxQL
  #  # https://github.com/Tyler-pierce/giza_sphinxsearch
  #
  #
  #  #===========================================================
  #  # queries
  #  #===========================================================
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_crisis_posts(conn, params) do
  #    clauses = [
  #      &__MODULE__.crisis_topic_constraint/2,
  #      &__MODULE__.interaction_constraint/2,
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #    generic_query(Jetzy.CrisisPostRepo, true, clauses, matches, conn, params)
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def advanced_query_crisis_posts(conn, params) do
  #    query_crisis_posts(conn, params)
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_crisis_topics(conn, params) do
  #    clauses = [
  #      &__MODULE__.interaction_constraint/2,
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #    generic_query(Jetzy.CrisisTopicRepo, true, clauses, matches, conn, params)
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def advanced_query_crisis_topics(conn, params) do
  #    query_crisis_topics(conn, params)
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_users(conn, params) do
  #    clauses = [
  #      &__MODULE__.gender_constraint/2,
  #      &__MODULE__.origin_constraint/2,
  #      &__MODULE__.school_constraint/2,
  #      &__MODULE__.major_constraint/2,
  #      &__MODULE__.employer_constraint/2,
  #      &__MODULE__.vocation_constraint/2,
  #      &__MODULE__.age_constraint/2,
  #      &__MODULE__.interaction_constraint/2,
  #      &__MODULE__.city_constraint/2,
  #      &__MODULE__.state_constraint/2,
  #      &__MODULE__.country_constraint/2,
  #      &__MODULE__.user_constraint/2,
  #      &__MODULE__.friend_constraint/2,
  #
  #    ]
  #    matches = [
  #      &__MODULE__.user_name_match/2,
  #      &__MODULE__.content_match/2,
  #    ]
  #    generic_query(Jetzy.UserRepo, true, clauses, matches, conn, params)
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def advanced_query_users(conn, params) do
  #    query_users(conn, params)
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_comments(conn, params) do
  #    clauses = [
  #      &__MODULE__.subject_constraint/2,
  #      &__MODULE__.interaction_constraint/2,
  #      &__MODULE__.city_constraint/2,
  #      &__MODULE__.state_constraint/2,
  #      &__MODULE__.country_constraint/2,
  #      &__MODULE__.gender_constraint/2,
  #      &__MODULE__.origin_constraint/2,
  #      &__MODULE__.school_constraint/2,
  #      &__MODULE__.major_constraint/2,
  #      &__MODULE__.employer_constraint/2,
  #      &__MODULE__.vocation_constraint/2,
  #      &__MODULE__.age_constraint/2,
  #      &__MODULE__.user_constraint/2,
  #      &__MODULE__.friend_constraint/2,
  #    ]
  #    matches = [
  #      &__MODULE__.user_name_match/2,
  #      &__MODULE__.content_match/2,
  #    ]
  #    generic_query(Jetzy.CommentRepo, true, clauses, matches, conn, params)
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def advanced_query_comments(conn, params) do
  #    query_comments(conn, params)
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_posts(conn, params) do
  #    clauses = [
  #      &__MODULE__.interests_constraint/2,
  #      &__MODULE__.private_interests_constraint/2,
  #      &__MODULE__.interaction_constraint/2,
  #      &__MODULE__.city_constraint/2,
  #      &__MODULE__.state_constraint/2,
  #      &__MODULE__.country_constraint/2,
  #      &__MODULE__.gender_constraint/2,
  #      &__MODULE__.origin_constraint/2,
  #      &__MODULE__.school_constraint/2,
  #      &__MODULE__.major_constraint/2,
  #      &__MODULE__.employer_constraint/2,
  #      &__MODULE__.vocation_constraint/2,
  #      &__MODULE__.age_constraint/2,
  #      &__MODULE__.user_constraint/2,
  #      &__MODULE__.friend_constraint/2,
  #      &__MODULE__.traveller_constraint/2,
  #    ]
  #    matches = [
  #      &__MODULE__.user_name_match/2,
  #      &__MODULE__.content_match/2,
  #    ]
  #    generic_query(Jetzy.PostRepo, true, clauses, matches, conn, params)
  #  end
  #  def advanced_query_posts(conn, params) do
  #    query_posts(conn,params)
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_cms(conn, params) do
  #    clauses = [
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #
  #    generic_query(Jetzy.Cms.ArticleRepo, false, clauses, matches, conn, params)
  #  end
  #  def advanced_query_cms(conn, params) do
  #    query_cms(conn,params)
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_locations(conn, params) do
  #    clauses = [
  #      &__MODULE__.city_constraint/2,
  #      &__MODULE__.state_constraint/2,
  #      &__MODULE__.country_constraint/2,
  #    ]
  #
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #
  #    generic_query(Jetzy.LocationRepo, true, clauses, matches, conn, params)
  #  end
  #  def advanced_query_locations(conn, params) do
  #    query_locations(conn,params)
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_countries(conn, params) do
  #    clauses = [
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #
  #    generic_query(Jetzy.Location.CountryRepo, true, clauses, matches, conn, params)
  #  end
  #  def advanced_query_countries(conn, params) do
  #    query_countries(conn,params)
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_states(conn, params) do
  #    clauses = [
  #      &__MODULE__.country_constraint/2,
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #
  #    generic_query(Jetzy.Location.StateRepo, true, clauses, matches, conn, params)
  #  end
  #  def advanced_query_states(conn, params) do
  #    query_states(conn,params)
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_cities(conn, params) do
  #    clauses = [
  #      &__MODULE__.state_constraint/2,
  #      &__MODULE__.country_constraint/2,
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #
  #    generic_query(Jetzy.Location.CityRepo, true, clauses, matches, conn, params)
  #  end
  #  def advanced_query_cities(conn, params) do
  #    query_cities(conn,params)
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_college_majors(conn, params) do
  #    clauses = [
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #
  #    generic_query(Jetzy.CollegeMajorRepo, false, clauses, matches, conn, params)
  #  end
  #  def advanced_query_college_majors(conn, params) do
  #    query_college_majors(conn,params)
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_documents(conn, params) do
  #    clauses = [
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #
  #    generic_query(Jetzy.DocumentRepo, false, clauses, matches, conn, params)
  #  end
  #  def advanced_query_documents(conn, params) do
  #    query_documents(conn,params)
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_employers(conn, params) do
  #    clauses = [
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #
  #    generic_query(Jetzy.EmployerRepo, false, clauses, matches, conn, params)
  #  end
  #  def advanced_query_employers(conn, params) do
  #    query_employers(conn,params)
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_images(conn, params) do
  #    clauses = [
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #    generic_query(Jetzy.ImageRepo, false, clauses, matches, conn, params)
  #  end
  #  def advanced_query_images(conn, params) do
  #    query_images(conn,params)
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_interests(conn, params) do
  #    clauses = [
  #      &__MODULE__.private_constraint/2,
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #    generic_query(Jetzy.InterestRepo, false, clauses, matches, conn, params)
  #  end
  #  def advanced_query_interests(conn, params) do
  #    query_interests(conn,params)
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_organizations(conn, params) do
  #    clauses = [
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #
  #    generic_query(Jetzy.OrganizationRepo, false, clauses, matches, conn, params)
  #  end
  #  def advanced_query_organizations(conn, params) do
  #    query_organizations(conn,params)
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_schools(conn, params) do
  #    clauses = [
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #
  #    generic_query(Jetzy.SchoolRepo, false, clauses, matches, conn, params)
  #  end
  #  def advanced_query_schools(conn, params) do
  #    query_schools(conn,params)
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def query_vocations(conn, params) do
  #    clauses = [
  #    ]
  #    matches = [
  #      &__MODULE__.content_match/2,
  #    ]
  #
  #    generic_query(Jetzy.VocationRepo, false, clauses, matches, conn, params)
  #  end
  #  def advanced_query_vocations(conn, params) do
  #    query_vocations(conn,params)
  #  end
  #
  #
  #  #===========================================================
  #  #
  #  #===========================================================
  #
  #  #------------------------------
  #  # generic_query
  #  #------------------------------
  #  @doc """
  #    Generic Query Implementation
  #  """
  #  def generic_query(repo, support_geo, supported_clauses, matches, conn, params) do
  #    context = default_get_context(conn, params)
  #    options = %{}
  #    limit = limit(conn, params, 0, repo.default_pagination_size())
  #    max_results = max_results(conn, params, 1000)
  #    geo = case support_geo && from_location(conn, params, context) do
  #      {lng, lat} -> ", SQRT(69.1*69.1*(latitude - #{lat})*(latitude - #{lat}) + 53*53*(longitude - #{lng})*(longitude - #{lng})) as distance "
  #      _ -> ""
  #    end
  #
  #    clauses = Enum.map(supported_clauses, &(&1.(conn, params)))
  #              |> Enum.filter(&(&1))
  #
  #    matches = Enum.map(matches, &(&1.(conn, params)))
  #              |> Enum.filter(&(&1))
  #
  #
  #    where_clause = cond do
  #      length(matches) > 0 && length(clauses) > 0 -> "WHERE " <> Enum.join(clauses, " AND ") <> "AND MATCH(" <> Poison.encode!(Enum.join(matches, "|")) <> ")"
  #      length(matches) > 0 -> "WHERE MATCH(" <> Poison.encode!(Enum.join(matches, "|")) <> ")"
  #      length(clauses) > 0 -> "WHERE " <> Enum.join(clauses, " AND ")
  #      :else -> ""
  #    end
  #
  #    # TODO - disable geo sort if not geo search term.
  #    {include_distance, order_by} = case order_by(conn, params) do
  #      {:geo, :asc} -> {true, "ORDER BY distance ASC, weight DESC"}
  #      {:geo, :desc} -> {true, "ORDER BY distance DESC, weight DESC"}
  #      {:time, :asc} -> {false, "ORDER BY created_on ASC, weight DESC"}
  #      {:time, :desc} -> {false, "ORDER BY created_on DESC, weight DESC"}
  #      {:age, :asc} -> {false, "ORDER BY date_of_birth DESC, weight DESC"}
  #      {:age, :desc} -> {false, "ORDER BY date_of_birth ASC, weight DESC"}
  #      _ -> {false, "ORDER BY weight DESC"}
  #    end
  #
  #    if include_distance && geo == nil do
  #      throw "Must Include Current Location or lng/lat for distance sort"
  #    end
  #
  #    # TODO - cache query result set to redis, and query ahead next page.
  #    query = "SELECT id, WEIGHT() as weight #{geo} FROM #{repo.sphinx_index__primary()}, #{repo.sphinx_index__delta()}, #{repo.sphinx_index__rt()} #{where_clause} #{order_by} #{limit} #{max_results}"
  #    results = case SphinxQL.new() |> SphinxQL.raw(query) |> SphinxQL.send() do
  #      {:ok, response} ->
  #        response.matches
  #        |> Task.async_stream(
  #             fn(record) ->
  #               entity = repo.entity().entity!(Jetzy.Repo.by_ref_resolution(List.first(record), context, options))
  #               cond do
  #                 entity == nil -> nil
  #                 geo -> %{record: entity, weight: Enum.at(record,1), distance: Enum.at(record, 2)}
  #                 true -> %{record: entity, weight: Enum.at(record,1)}
  #               end
  #             end, max_concurrency: 32, limit: 60_000
  #           )
  #        |> Enum.map(fn({:ok, v}) -> v end)
  #        |> Enum.filter(&(&1))
  #      _ ->
  #        []
  #    end
  #
  #    api_response(conn, %Jetzy.QueryResponse{records: results}, context)
  #  end
  #
  #
  #  #===========================================================
  #  # constraint
  #  #===========================================================
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def friend_constraint(conn, _params) do
  #    is_friend = case conn.query_params["active_user_friend"] || conn.body_params["active_user_friend"] do
  #      "true" -> true
  #      "false" -> false
  #      true -> true
  #      false -> false
  #      _ -> false
  #    end
  #    cond do
  #      is_friend ->
  #        # TODO get user->friends.  "user in (friend_ids)"
  #        nil
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def traveller_constraint(conn, _params) do
  #    traveller = case conn.query_params["is_traveller"] || conn.body_params["is_traveller"] do
  #      "true" -> true
  #      "false" -> false
  #      true -> true
  #      false -> false
  #      _ -> nil
  #    end
  #    cond do
  #      traveller != nil -> "traveller = #{traveller}"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def private_constraint(conn, _params) do
  #    private = case conn.query_params["is_private"] || conn.body_params["is_private"] do
  #      "true" -> true
  #      "false" -> false
  #      true -> true
  #      false -> false
  #      _ -> nil
  #    end
  #    cond do
  #      private != nil -> "private = #{private}"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def user_constraint(conn, _params) do
  #    users = cond do
  #      users = conn.query_params["user"] ->
  #        users
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.User.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      users = conn.body_params["user"] ->
  #        users
  #        |> Enum.map(&(Jetzy.User.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      true -> nil
  #    end
  #    cond do
  #      users && length(users) > 0 -> "user in (" <> Enum.join(users, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def subject_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["subject"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Noizu.ERP.ref(&1)))
  #        |> Jetzy.MySQL.Entity.universal_identifier()
  #        |> Enum.filter(&(&1))
  #      v = conn.body_params["subject"] ->
  #        v
  #        |> Enum.map(&(Noizu.ERP.ref(&1)))
  #        |> Jetzy.MySQL.Entity.universal_identifier()
  #        |> Enum.filter(&(&1))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "subject in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def interests_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["interest"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.Interest.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      v = conn.body_params["interest"] ->
  #        v
  #        |> Enum.map(&(Noizu.ERP.ref(&1)))
  #        |> Enum.map(&(Jetzy.Interest.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "interest in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def private_interests_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["private_interest"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.Interest.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      v = conn.body_params["private_interest"] ->
  #        v
  #        |> Enum.map(&(Noizu.ERP.ref(&1)))
  #        |> Enum.map(&(Jetzy.Interest.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "private_interest in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def city_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["city"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.Location.City.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      v = conn.body_params["city"] ->
  #        v
  #        |> Enum.map(&(Noizu.ERP.ref(&1)))
  #        |> Enum.map(&(Jetzy.Location.City.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "city in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def state_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["state"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.Location.State.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      v = conn.body_params["state"] ->
  #        v
  #        |> Enum.map(&(Noizu.ERP.ref(&1)))
  #        |> Enum.map(&(Jetzy.Location.State.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "state in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def country_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["country"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.Location.Country.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      v = conn.body_params["country"] ->
  #        v
  #        |> Enum.map(&(Noizu.ERP.ref(&1)))
  #        |> Enum.map(&(Jetzy.Location.Country.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "country in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def gender_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["gender"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.Repo.json_to_atom(:gender, &1)))
  #        |> Enum.filter(&(&1))
  #        |> Enum.map(&(Jetzy.Repo.mysql_enum(:gender, &1)))
  #      v = conn.body_params["gender"] ->
  #        v
  #        |> Enum.map(&(Jetzy.Repo.json_to_atom(:gender, &1)))
  #        |> Enum.filter(&(&1))
  #        |> Enum.map(&(Jetzy.Repo.mysql_enum(:gender, &1)))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "gender in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def post_type_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["post_type"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.Repo.json_to_atom(:post_type, &1)))
  #        |> Enum.filter(&(&1))
  #        |> Enum.map(&(Jetzy.Repo.mysql_enum(:post_type, &1)))
  #      v = conn.body_params["gender"] ->
  #        v
  #        |> Enum.map(&(Jetzy.Repo.json_to_atom(:post_type, &1)))
  #        |> Enum.filter(&(&1))
  #        |> Enum.map(&(Jetzy.Repo.mysql_enum(:post_type, &1)))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "post_type in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def topic_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["topic"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.Repo.json_to_atom(:topic, &1)))
  #        |> Enum.filter(&(&1))
  #        |> Enum.map(&(Jetzy.Repo.mysql_enum(:topic, &1)))
  #      v = conn.body_params["topic"] ->
  #        v
  #        |> Enum.map(&(Jetzy.Repo.json_to_atom(:topic, &1)))
  #        |> Enum.filter(&(&1))
  #        |> Enum.map(&(Jetzy.Repo.mysql_enum(:topic, &1)))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "topic in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def origin_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["origin"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.Repo.json_to_atom(:origin, &1)))
  #        |> Enum.filter(&(&1))
  #        |> Enum.map(&(Jetzy.Repo.mysql_enum(:origin, &1)))
  #      v = conn.body_params["origin"] ->
  #        v
  #        |> Enum.map(&(Jetzy.Repo.json_to_atom(:origin, &1)))
  #        |> Enum.filter(&(&1))
  #        |> Enum.map(&(Jetzy.Repo.mysql_enum(:origin, &1)))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "origin in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def school_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["school"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.School.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      v = conn.body_params["school"] ->
  #        v
  #        |> Enum.map(&(Jetzy.School.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "school in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def major_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["major"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.CollegeMajor.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      v = conn.body_params["major"] ->
  #        v
  #        |> Enum.map(&(Jetzy.CollegeMajor.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "major in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def employer_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["employer"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.Employer.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      v = conn.body_params["employer"] ->
  #        v
  #        |> Enum.map(&(Jetzy.Employer.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "employer in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def vocation_constraint(conn, _params) do
  #    v = cond do
  #      v = conn.query_params["vocation"] ->
  #        v
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.Vocation.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      v = conn.body_params["vocation"] ->
  #        v
  #        |> Enum.map(&(Jetzy.Vocation.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      true -> nil
  #    end
  #    cond do
  #      v && length(v) > 0 -> "vocation in (" <> Enum.join(v, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def age_constraint(conn, _params, options \\ %{}) do
  #    now = options[:current_time] || DateTime.utc_now()
  #    minimum_age = cond do
  #      v = conn.query_params["age-min"] ->
  #        case Integer.parse(v) do
  #          {v, ""} -> v
  #          _ -> nil
  #        end
  #      v = (is_integer(conn.body_params["age"]["min"]) || is_float(conn.body_params["age"]["min"]) && conn.body_params["age"]["min"]) -> round(v)
  #      true -> nil
  #    end
  #    minimum_age_cut_off = minimum_age && Timex.shift(now, years: -minimum_age)
  #    minimum_age_cut_off = minimum_age_cut_off && DateTime.to_unix(minimum_age_cut_off)
  #
  #    maximum_age = cond do
  #      v = conn.query_params["age-max"] ->
  #        case Integer.parse(v) do
  #          {v, ""} -> v
  #          _ -> nil
  #        end
  #      v = (is_integer(conn.body_params["age"]["max"]) || is_float(conn.body_params["age"]["max"]) && conn.body_params["age"]["max"]) -> round(v)
  #      true -> nil
  #    end
  #    maximum_age_cut_off = maximum_age && Timex.shift(now, years: -maximum_age)
  #    maximum_age_cut_off = maximum_age_cut_off && DateTime.to_unix(maximum_age_cut_off)
  #
  #    cond do
  #      minimum_age && maximum_age -> "date_of_birth >= #{minimum_age_cut_off} and date_of_birth <= #{maximum_age_cut_off}"
  #      minimum_age -> "date_of_birth >= #{minimum_age_cut_off}"
  #      maximum_age -> "date_of_birth <= #{maximum_age_cut_off}"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def crisis_topic_constraint(conn, _params) do
  #    topics = cond do
  #      topics = conn.query_params["topics"] ->
  #        topics
  #        |> String.split(",")
  #        |> Enum.map(&(Jetzy.CrisisTopic.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      topics = conn.body_params["topics"] ->
  #        topics
  #        |> Enum.map(&(Jetzy.CrisisTopic.Entity.id(&1)))
  #        |> Enum.filter(&(&1))
  #      true -> nil
  #    end
  #    cond do
  #      topics && length(topics) > 0 -> "topics in (" <> Enum.join(topics, ",") <> ")"
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def interaction_constraint__inner(interaction, criteria) do
  #    c = case criteria do
  #      "=" <> v ->  {"=", v}
  #      "<=" <> v -> {"<=", v}
  #      "<" <> v -> {"<", v}
  #      ">=" <> v -> {">=", v}
  #      ">" <> v -> {">", v}
  #      _ -> nil
  #    end
  #    case c do
  #      nil -> nil
  #      {comparison, v} ->
  #        case Integer.parse(v) do
  #          {v, ""} -> "#{interaction} #{comparison} #{v}"
  #          _ -> nil
  #        end
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def interaction_constraint__inner(constraint) do
  #    case constraint do
  #      "likes" <> criteria -> interaction_constraint__inner("reaction_01", criteria)
  #      "dislikes" <> criteria -> interaction_constraint__inner("reaction_02", criteria)
  #      "comments" <> criteria -> interaction_constraint__inner("comments", criteria)
  #      "hearts" <> criteria -> interaction_constraint__inner("reaction_03", criteria)
  #      _ -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def interaction_constraint(conn, _params) do
  #    interactions = cond do
  #      interactions = conn.query_params["interactions"] ->
  #        interactions
  #        |> String.split(",")
  #        |> Enum.map(&(interaction_constraint__inner(&1)))
  #        |> Enum.filter(&(&1))
  #      interactions = conn.body_params["interactions"] ->
  #        interactions
  #        |> Enum.map(fn({k,v}) ->
  #          case k do
  #            "likes" -> interaction_constraint__inner("reaction_like", v)
  #            "dislikes" -> interaction_constraint__inner("reaction_dislikes", v)
  #            "hearts" -> interaction_constraint__inner("reaction_hearts", v)
  #            "comments" -> interaction_constraint__inner("comments", v)
  #            _ -> nil
  #          end
  #        end)
  #        |> Enum.filter(&(&1))
  #      true -> nil
  #    end
  #    cond do
  #      interactions && length(interactions) > 0 -> Enum.join(interactions, " AND ")
  #      true -> nil
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def order_by(conn, _params) do
  #    order_by = conn.query_params["order_by"] || conn.body_params["order_by"]
  #    case order_by do
  #      "GEO" -> {:geo, :asc}
  #      "GEO DESC" -> {:geo, :desc}
  #      "GEO ASC" -> {:geo, :asc}
  #      "AGE" -> {:age, :asc}
  #      "AGE DESC" -> {:age, :desc}
  #      "AGE ASC" -> {:age, :asc}
  #      "TIME" -> {:time, :desc}
  #      "TIME DESC" -> {:time, :desc}
  #      "TIME ASC" -> {:time, :asc}
  #      "WEIGHT" -> {:weight, :desc}
  #      _ -> :default
  #    end
  #  end
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def from_location(conn, _params, context) do
  #    lng = cond do
  #      v = conn.query_params["lng"] ->
  #        case Float.parse(v) do
  #          {v, ""} -> v
  #          _ -> nil
  #        end
  #      v = conn.body_params["lng"] ->
  #        cond do
  #          is_float(v) -> v
  #          is_integer(v) -> 0.0 + v
  #          true -> nil
  #        end
  #      true -> nil
  #    end
  #
  #    lat = cond do
  #      v = conn.query_params["lat"] ->
  #        case Float.parse(v) do
  #          {v, ""} -> v
  #          _ -> nil
  #        end
  #      v = conn.body_params["lat"] ->
  #        cond do
  #          is_float(v) -> v
  #          is_integer(v) -> 0.0 + v
  #          true -> nil
  #        end
  #      true -> nil
  #    end
  #
  #    location = cond do
  #      lng && lat -> nil
  #      location = conn.query_params["location"] -> Jetzy.Location.Entity.entity!(location)
  #      location = conn.body_params["location"] -> Jetzy.Location.Entity.entity!(location)
  #      google = conn.body_params["google_address"] -> Jetzy.LocationRepo.from_google(google, context, %{})
  #      true -> nil
  #    end
  #
  #    cond do
  #      location -> location.geo && location.geo.coordinates
  #      lng && lat -> {lng, lat}
  #      true -> nil
  #    end
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def user_name_match(conn, _params) do
  #    cond do
  #      user_name = conn.query_params["user_name"] ->
  #        String.trim(user_name)
  #      user_name = conn.body_params["user_name"] ->
  #        String.trim(user_name)
  #      true -> nil
  #    end
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def content_match(conn, _params) do
  #    cond do
  #      query = conn.query_params["query"] ->
  #        String.trim(query)
  #      query = conn.body_params["query"] ->
  #        String.trim(query)
  #      true -> nil
  #    end
  #  end
  #
  #  #===========================================================
  #  #
  #  #===========================================================
  #
  #  def max_results(conn, _params, default) do
  #    max_results = cond do
  #      max_results = conn.query_params["max_results"] ->
  #        case Integer.parse(max_results) do
  #          {max_results, ""} -> max_results
  #          _ -> default
  #        end
  #      true -> default
  #    end
  #    "option max_matches=#{max_results}"
  #  end
  #
  #
  #  #------------------------------
  #  #
  #  #------------------------------
  #  def limit(conn, _params, default_page, default_rpp) do
  #    page = cond do
  #      page = conn.query_params["page"] ->
  #        case Integer.parse(page) do
  #          {page, ""} -> page
  #          _ -> default_page
  #        end
  #      true -> default_page
  #    end
  #
  #    rpp = cond do
  #      rpp = conn.query_params["rpp"] ->
  #        case Integer.parse(rpp) do
  #          {rpp, ""} -> rpp
  #          _ -> default_rpp
  #        end
  #      true -> default_rpp
  #    end
  #
  #    cond do
  #      page == 0 -> "LIMIT #{rpp}"
  #      true ->
  #        offset = page * rpp
  #        "LIMIT #{offset}, #{rpp}"
  #    end
  #  end

end

end