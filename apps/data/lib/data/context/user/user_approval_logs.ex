defmodule Data.Context.UserApprovalLogs do
  
  def record(user, set_to, source, admin, remark) do
    %Data.Schema.UserApprovalLog{
      user_id: user.id,
      approval_source: :admin,
      approval_status: set_to,
      updated_by_user_id: admin.id,
      remark: remark,
    } |> Data.Repo.insert()
  end
  
end