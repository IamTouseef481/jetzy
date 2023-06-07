defmodule JetzyModule.AuthenticationModule do

#  #------------------------------------
#  # caller_device!
#  #------------------------------------
#  def caller_device(_conn) do
#    # TODO - catch all / unknown device.
#    0
#  end
#
#  #------------------------------------
#  # authenticate!
#  #------------------------------------
#  def authenticate!(conn, type, params \\ [], options \\ [])
#  def authenticate!(conn, :login_or_legacy, params, options) do
#    case auth_credential!(conn, :login, params, options)  do
#      {:ok, credential} -> load_credential_session(conn, credential, options)
#      _ ->
#        case auth_credential!(conn, :api_legacy, params, options)  do
#          {:ok, credential} -> load_credential_session(conn, credential, options)
#          _ ->
#            case auth_credential!(conn, :api_legacy_session, params, options)  do
#              {:ok, credential} -> load_credential_session(conn, credential, options)
#              _ -> {:denied, conn}
#            end
#        end
#    end
#  end
#  def authenticate!(conn, :legacy, params, options) do
#    case auth_credential!(conn, :api_legacy, params, options)  do
#      {:ok, credential} -> load_credential_session(conn, credential, options)
#      _ ->
#        case auth_credential!(conn, :api_legacy_session, params, options)  do
#          {:ok, credential} -> load_credential_session(conn, credential, options)
#          _ -> {:denied, conn}
#        end
#    end
#  end
#  def authenticate!(conn, type, params, options) do
#    case auth_credential!(conn, type, params, options)  do
#      {:ok, credential} -> load_credential_session(conn, credential, options)
#      _ -> {:denied, conn}
#    end
#  end
#
#  #------------------------------------
#  # load_credential_session
#  #------------------------------------
#  def load_credential_session(conn, nil, _options), do: conn
#  def load_credential_session(conn, cred, options) do
#    context = Noizu.ElixirCore.CallingContext.system()
#    credential = Noizu.ERP.entity!(cred)
#    # todo deal with active, etc. check device.
#    case Jetzy.User.Session.Repo.by_credential!(credential, context, options) do
#      session = %{__struct__: Jetzy.User.Session.Entity} ->
#        conn = Guardian.Plug.put_current_claims(
#          conn,
#          %{"aud" => "jetzy", "src" => "legacy", "sref" => Jetzy.User.Entity.sref(session.user), "session" => Jetzy.User.Session.Entity.sref(session)}
#        )
#        {:authorized, session, conn}
#      session = {:ref, Jetzy.User.Session.Entity, _} ->
#        if session = Noizu.ERP.entity!(session) do
#          conn = Guardian.Plug.put_current_claims(
#            conn,
#            %{"aud" => "jetzy", "src" => "legacy", "sref" => Jetzy.User.Entity.sref(credential.user), "session" => Jetzy.User.Session.Entity.sref(session)}
#          )
#          {:authorized, session, conn}
#        else
#          {:denied, conn}
#        end
#
#      _else ->
#        now = options[:current_time] || DateTime.utc_now()
#        session = credential && %Jetzy.User.Session.Entity{
#                                  user: credential.user,
#                                  device: caller_device(conn),
#                                  credential: Noizu.ERP.ref(credential),
#                                  status: :active,
#                                  generation: :os.system_time(:millisecond),
#                                  session_start: now,
#                                  session_end: nil,
#                                  expire_after: Timex.shift(now, hours: 1)
#                                }
#                                |> Jetzy.User.Session.Repo.create!(context)
#
#        cond do
#          !credential -> {:denied, conn}
#          !session -> {:denied, conn}
#          # unexpected persistence error
#          :else ->
#            conn = Guardian.Plug.put_current_claims(
#              conn,
#              %{"aud" => "jetzy", "src" => "legacy", "sref" => Jetzy.User.Entity.sref(session.user), "session" => Jetzy.User.Session.Entity.sref(session)}
#            )
#            {:authorized, session, conn}
#        end
#    end
#  end
#
#  #------------------------------------
#  # auth_credential!
#  #------------------------------------
#  def auth_credential!(conn, type, params, options \\ nil)
#  def auth_credential!(_conn, :api_legacy, params, options) do
#    guid = params[:guid]
#    login = params[:login]
#    auth = params[:auth]
#    context = Noizu.ElixirCore.CallingContext.system()
#    cond do
#      (login || guid) && auth ->
#        setting = %Jetzy.User.Credential.JetzyLegacy{
#          login_name: login || :_,
#          guid: guid || :_,
#          password_hash: auth
#        }
#        cond do
#          cred = Jetzy.User.Credential.Repo.by_setting!(setting, Noizu.ElixirCore.CallingContext.admin) ->
#            user = Jetzy.User.Repo.by_guid!(guid || cred.settings.guid, context, options)
#            cond do
#              cred.user == user -> {:ok, cred}
#              :else -> {:error, :cred_error}
#            end
#          record = guid && JetzySchema.MSSQL.User.Table.by_guid!(guid, context, options) ->
#            credential = JetzySchema.MSSQL.User.Table.legacy_credentials(record, context, options)
#            user = Jetzy.User.Repo.by_guid!(guid, context, options)
#            cond do
#              !credential -> {:error, :denied}
#              credential.settings.guid != guid -> {:error, :critical}
#              credential.settings.auth != auth -> {:error, :denied}
#              new_credential = Jetzy.User.Credential.Repo.create!(put_in(credential, [Access.key(:user)], user), context) -> {:ok, new_credential}
#              :else -> {:error, :critical}
#            end
#          record = login && JetzySchema.MSSQL.User.Table.by_login_name!(login, context, options) ->
#            credential = JetzySchema.MSSQL.User.Table.legacy_credentials(record, context, options)
#            user = Jetzy.User.Repo.by_guid!(record.id, context, options)
#
#            cond do
#              !user -> {:error, :denied}
#              !credential -> {:error, :denied}
#              credential.settings.login_name != login -> {:error, :critical}
#              credential.settings.guid != guid -> {:error, :critical}
#              credential.settings.auth != auth -> {:error, :denied}
#              new_credential = Jetzy.User.Credential.Repo.create!(put_in(credential, [Access.key(:user)], user), context) -> {:ok, new_credential}
#              :else -> {:error, :critical}
#            end
#          :else -> nil
#        end
#    end
#  end
#  def auth_credential!(_conn, :api_legacy_session, params, options) do
#    guid = params[:guid]
#    session = params[:auth]
#    context = Noizu.ElixirCore.CallingContext.system()
#    user = guid && Jetzy.User.Repo.by_guid!(guid, context, options)
#    cond do
#      !user -> {:error, :denied}
#      guid && session ->
#        setting = %Jetzy.User.Credential.JetzyLegacySession{
#          session: session,
#          guid: guid,
#        }
#        cond do
#          cred = Jetzy.User.Credential.Repo.by_setting!(setting, context) ->
#            credential = Noizu.ERP.entity!(cred)
#            user = Jetzy.User.Repo.by_guid!(guid, context, options)
#            cond do
#              !user -> {:error, :denied}
#              !credential -> {:error, :critical}
#              credential.user != user -> {:error, :critical}
#              !credential.settings.session_active ->
#                check = JetzySchema.MSSQL.User.Table.legacy_session({guid, session}, context, options)
#                cond do
#                  check && check.settings.session_active ->
#                    c = %Jetzy.User.Credential.Entity{
#                          credential |
#                          status: check.status,
#                          settings: %Jetzy.User.Credential.JetzyLegacySession{
#                            credential.settings |
#                            recheck_after: check.settings.recheck_after,
#                            session_active: check.settings.session_active
#                          }
#                        }
#                        |> Jetzy.User.Credential.Repo.update!(context)
#                    {:ok, c}
#                  :else -> {:error, :expired}
#                end
#              :else -> credential
#            end
#          credential = JetzySchema.MSSQL.User.Table.legacy_session({guid, session}, context, options) ->
#            cond do
#              !credential -> {:error, :denied}
#              !credential.settings.settings.session_active -> {:error, :expired}
#              credential.settings.guid != guid -> {:error, :critical}
#              credential.settings.session != session -> {:error, :critical}
#              new_credential = Jetzy.User.Credential.Repo.create!(put_in(credential, [Access.key(:user)], user), context) -> {:ok, new_credential}
#              :else -> {:error, :critical}
#            end
#          :else -> nil
#        end
#    end
#  end
#  def auth_credential!(_conn, _type, _params, _options) do
#    nil
#  end

end
