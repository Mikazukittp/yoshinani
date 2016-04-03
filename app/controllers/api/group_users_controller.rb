class Api::GroupUsersController < ApplicationController
  include PushNotification

  before_action :authenticate!
  before_action :set_group
  before_action :set_group_user, only: %i(accept destroy)

  def index
    render json: @group.users.includes(:totals).as_json(group_id: @group.id), status: :ok
  end

  def create
    @group_users = @group.group_users.new(group_user_params)

    ActiveRecord::Base.transaction do
      @group_users.each do |group_user|
        @group_user = group_user

        @group_user.save!
      end
    end
    send_invited_notification!(@group)

    render json: @group, status: :ok

    rescue ActiveRecord::RecordInvalid => invalid
      render json: {message: "メンバーの追加に失敗しました", errors: @group_user.errors.messages}, status: :internal_server_error
  end

  def destroy
    if @group_user.destroy
      render json: @group_user, status: :no_content
    else
      render json: {message: "グループの退会に失敗しました", errors: @group_user.errors.messages}, status: :internal_server_error
    end
  end

  def accept
    if @group_user.update(status: 'active')
      render json: @group_user, status: :ok
    else
      render json: {message: "グループの参加に失敗しました", errors: @group_user.errors.messages}, status: :internal_server_error
    end
  end

  private

  def set_group
    @group = @user.groups.find_by(id: params[:group_id])
    unless @group.present?
      render json: {message: "指定されたIDのグループが見つかりません"}, status: :bad_request
      return
    end
  end

  def set_group_user
    user_id = params[:id] ? params[:id] : @user.id

    @group_user = @group.group_users.find_by(user_id: user_id)
    unless @group_user.present?
      render json: {message: "グループユーザが見つかりません"}, status: :bad_request
      return
    end
  end

  def group_user_params
    params.require(:group_user).map do |group_user|
      group_user.permit(:user_id)
    end
  end

  def send_invited_notification!(group)
    invited_user_ids = params[:group_user].map{ |group_user| group_user['user_id'] }

    message = '新規グループに招待されました'
    type = 'invitation'
    custom_data = {group: {id: group.id, name: group.name}}

    invited_user_ids.each do |id|
      invited_user = User.includes(:notification_tokens).find_by(id: id)
      send_notification(invited_user, message, type, custom_data)
    end
  end
end
