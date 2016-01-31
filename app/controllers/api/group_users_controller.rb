class Api::GroupUsersController < ApplicationController
  before_action :authenticate!
  before_action :set_group
  before_action :set_group_user, only: %i(accept destroy)

  def index
    render json: @group.users.as_json(group_id: @group.id), status: :ok
  end

  def create
    if @group.group_users.create(group_user_params)
      render json: @group, status: :ok
    else
      render json: {error: "メンバーの追加に失敗しました"}, status: :internal_server_error
    end
  end

  def destroy
    if @group_user.destroy
      render json: @group_user, status: :no_content
    else
      render json: {error: "グループの退会に失敗しました"}, status: :internal_server_error
    end
  end

  def accept
    if @group_user.update(status: 'active')
      render json: @group_user, status: :ok
    else
      render json: {error: "グループの参加に失敗しました"}, status: :internal_server_error
    end
  end

  private

  def set_group_user
    @group_user = @user.group_users.find_by(id: params[:id])
    unless @group_user.present?
      render json: {error: "指定されたIDのグループユーザが見つかりません"}, status: :bad_request
      return
    end
  end

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
