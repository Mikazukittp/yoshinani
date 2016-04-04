class Api::NotificationTokensController < ApplicationController
  before_action :authenticate!
  before_action :valid_uniqueness_token, only: %i(create)
  before_action :set_notification_token, only: %i(update destroy)

  def create
    @notification_token = @user.notification_tokens.new(notification_token_params)
    if @notification_token.save
      render json: @user, status: :ok
    else
      render json: {message: "PUSHキーの作成に失敗しました", errors: @notification_token.errors.messages}, status: :internal_server_error
    end
  end

  def update
    if @notification_token.update(notification_token_params)
      render json: @user, status: :ok
    else
      render json: {message: "PUSHキーの更新に失敗しました", errors: @notification_token.errors.messages}, status: :internal_server_error
    end
  end

  def destroy
    if @notification_token.destroy
      render json: @user, status: :ok
    else
      render json: {message: "PUSHキーの削除に失敗しました", errors: @notification_token.errors.messages}, status: :internal_server_error
    end
  end

  private

  def notification_token_params
    params.require(:notification_token).permit(:device_token, :device_type)
  end

  def set_notification_token
    @notification_token = @user.notification_tokens.find_by(device_token: params[:notification_token][:auth_device_token])
    unless @notification_token.present?
      render json: {message: "指定されたPUSHキーは見つかりません"}, status: :bad_request
      return
    end
  end

  def valid_uniqueness_token
    if NotificationToken.exists?(device_token: params[:notification_token][:device_token])
      render json: {message: "指定されたPUSHキーはすでに存在しています"}, status: :ok
    end
  end
end
