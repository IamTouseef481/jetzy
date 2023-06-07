defmodule Jetzy.Email.Helper do
  
  @sendgrid_forward Application.get_env(:data, :sendgrid)[:select_forward]
  @sendgrid_website Application.get_env(:data, :sendgrid)[:website] || "https://jetzy.com"
  @sendgrid_select_website Application.get_env(:data, :sendgrid)[:select_website] || "https://select.jetzy.com"
  @sendgrid_cdn Application.get_env(:data, :sendgrid)[:cdn] || "https://jetzy.com"
  
  def select_website(), do: @sendgrid_select_website
  def website(), do: @sendgrid_website
  
  def select_forward(), do: Application.get_env(:data, :sendgrid)[:select_forward]

  def email_environment(user) do
    %{
      locale: "en", # <- determine by user
      website: @sendgrid_website,
      select: @sendgrid_select_website,
      cdn: @sendgrid_cdn,
      contact: %{
        email: "contact@jetzy.com",
        name: %{
          first: "Contact",
          last: "Jetzy"
        }
      }
    }
  end

  def default_sender(), do: %{name: "Jetzy", email: "support@account.jetzy.com", ref: {:ref, Jetzy.User.Entity, :system}}
  def default_reply(), do: default_sender()

  def variable_extractor(selector, state, context, options) do
    {blob, state} = Noizu.RuleEngine.StateProtocol.get!(state, :bind_space, context)
    case selector.selector do
      [{:select, "user"}|_] -> variable_extractor__user(selector, {blob, state}, context, options)
      [{:select, "subscription"}|_] -> variable_extractor__subscription(selector, {blob, state}, context, options)
      _ ->
        # standard logic fallback for not alert inspection calls.
        {bound?,val, state} = Noizu.EmailService.Email.Binding.Substitution.Dynamic.Selector.bound_inner(selector, blob, state, context, options)
        {bound? && {:value, val}, state}
    end
  end
  
  defp variable_extractor__user(selector, {blob, state}, context, options) do
    context = Noizu.ElixirCore.CallingContext.system(context) # temp - to open up restricted_view
    {bound?,val,state} = Noizu.EmailService.Email.Binding.Substitution.Dynamic.Selector.bound_inner(selector, blob, state, context, options)
    {bound? && {:value, val}, state}
  end

  defp variable_extractor__subscription(selector, {blob, state}, context, options) do
    context = Noizu.ElixirCore.CallingContext.system(context) # temp - to open up restricted_view
    {bound?,val,state} = Noizu.EmailService.Email.Binding.Substitution.Dynamic.Selector.bound_inner(selector, blob, state, context, options)
    {bound? && {:value, val}, state}
  end
  
end