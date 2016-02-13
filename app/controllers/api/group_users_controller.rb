class Api::GroupUsersController < ApplicationController
  before_action :authenticate!
  before_action :set_group
  before_action :set_group_user, only: %i(accept destroy)

  def index
    render json: @group.users.as_json(group_id: @group.id), status: :ok
  end

  def create
    # FIXME: paramを既存仕様に合わせているので、一旦こんなにイケてない形にしています...
    # 思い切ってI/Fを変えてもいいかも？
    @group_user = GroupUser.new(group_user_params.first.merge({group_id: @group.id}))

    if @group_user.save
      render json: @group, status: :ok
    else
      render json: {message: "メンバーの追加に失敗しました", errors: @group_user.errors.full_messages}, status: :internal_server_error
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

  def set_group
    @group = @user.groups.find_by(id: params[:group_id])
    unless @group.present?
      render json: {error: "指定されたIDのグループが見つかりません"}, status: :bad_request
      return
    end
  end

  def set_group_user
    user_id = params[:id] ? params[:id] : @user.id

    @group_user = @group.group_users.find_by(user_id: user_id)
    unless @group_user.present?
      render json: {error: "グループユーザが見つかりません"}, status: :bad_request
      return
    end
  end

  def group_user_params
    params.require(:group_user).map do |group_user|
      group_user.permit(:user_id)
    end
  end
end
