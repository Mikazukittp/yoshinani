class Api::GroupMembersController < ApplicationController
  before_action :authenticate!
  before_action :set_group

  def index
    render json: @group.users, status: :ok
  end

  def create
    if @group.group_users.create(group_user_params)
      render json: @group, status: :ok
    else
      render json: {error: "メンバーの追加に失敗しました"}, status: :internal_server_error
    end
  end

  private

  def set_group
    @group = @user.groups.find_by(id: params[:id])
    unless @group.present?
      render json: {error: "指定されたIDのグループが見つかりません"}, status: :not_found
      return
    end
  end

  def group_user_params
    params.require(:group).permit(:user_id)
  end
end
