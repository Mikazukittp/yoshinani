class Api::PasswordsController < ApplicationController
  before_action :authenticate!
  before_action :verify_old_password
  before_action :verify_password_confirmation

  def update
    @user.password = params[:new_password]
    @user.hash_password

    if @user.save
      render json: @user, status: :ok
    else
      render json: {error: "パスワードの更新に失敗しました"}, status: :internal_server_error
    end
  end

  private

  def verify_old_password
    unless @user.authoricate(params[:password].strip)
      render json: {error: "パスワードが正しくありません"}, status: :bad_request
    end
  end

  def verify_password_confirmation
    unless params[:new_password] == params[:new_password_confirmation]
      render json: {error: "新しいパスワードと確認用パスワードが一致していません"}, status: :bad_request
    end
  end
end
