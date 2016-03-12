class Api::PasswordsController < ApplicationController
  EXPIRATION_MINUTES_FOR_RESET_PASSWORD = 30

  before_action :authenticate!, only: %i(update)
  before_action :verify_params
  before_action :verify_old_password, only: %i(update)
  before_action :verify_password_confirmation, only: %i(update reset)
  before_action :set_user_by_email, only: %i(init)
  before_action :set_user_by_reset_password_token, only: %i(reset)
  before_action :set_new_password_and_valid, only: %i(update reset)

  def update
    if @user.save
      render json: @user, status: :ok
    else
      render json: {message: "パスワードの更新に失敗しました", errors: @user.errors.messages}, status: :internal_server_error
    end
  end

  def init
    if @user.set_reset_password_token
      PasswordMailer.send_rest_password(@user).deliver
      render json: {message: "パスワード再設定用のメールを送信いたしました"}, status: :ok
    else
      render json: {message: "パスワードのリセットに失敗しました", errors: @user.errors.messages}, status: :bad_request
    end
  end

  def reset
    @user.reset_password_token = nil

    if @user.save
      render json: @user, status: :ok
    else
      render json: {message: "パスワードの更新に失敗しました", errors: @user.errors.messages}, status: :internal_server_error
    end
  end

  private

  def verify_params
    if params[:user].blank?
      render json: {message: "パラメータの形式が不正です"}, status: :bad_request
    end
  end

  def verify_old_password
    unless @user.authoricate(params[:user][:password].strip)
      render json: {message: "パスワードが正しくありません"}, status: :bad_request
    end
  end

  def verify_password_confirmation
    unless params[:user][:new_password] == params[:user][:new_password_confirmation]
      render json: {message: "新しいパスワードと確認用パスワードが一致していません"}, status: :bad_request
    end
  end

  def set_new_password_and_valid
    @user.password = params[:user][:new_password]
    unless @user.valid?(:reset_password)
      render json: {message: "パスワードの更新に失敗しました", errors: @user.errors.messages}, status: :bad_request
      return
    end

    @user.hash_password
  end

  def set_encrypted_password(user)
    user.password = params[:user][:new_password]
    unless user.valid?(:reset_password)
      render json: {message: "パスワードの更新に失敗しました", errors: @user.errors.messages}, status: :bad_request
      return
    end

    user.hash_password
  end

  def set_user_by_email
    @user = User.find_by(email: params[:user][:email])

    if @user.nil?
      render json: {message: "一致する情報はみつかりませんでした。"}, status: :bad_request
      return
    end
  end

  def set_user_by_reset_password_token
    @user = User.find_by(reset_password_token: params[:user][:reset_password_token])

    if @user.nil?
      render json: {message: "再設定用の認証キーが正しくありません"}, status: :bad_request
      return
    end

    if @user.reset_password_at < EXPIRATION_MINUTES_FOR_RESET_PASSWORD.minutes.ago
      render json: {message: "再設定用の認証キーの有効期限が切れています"}, status: :bad_request
      return
    end
  end
end
