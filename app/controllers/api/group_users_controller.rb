class Api::GroupUsersController < ApplicationController
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
    @group = @user.groups.find_by(id: params[:group_id])
    unless @group.present?
      render json: {error: "指定されたIDのグループが見つかりません"}, status: :bad_request
      return
    end
  end

  def group_user_params
    params.require(:group_user).map do |group_user|
      group_user.permit(:user_id)
    end
  end
end
