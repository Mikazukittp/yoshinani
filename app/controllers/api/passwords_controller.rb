class Api::PasswordsController < ApplicationController
  before_action :authenticate!, only: %i(update)
  before_action :verify_old_password, only: %i(update)
  before_action :verify_password_confirmation, only: %i(update)

  def reset
    @user = User.find_by(account: params[:user][:account], email: params[:user][:email])

    if @user.nil?
      render json: {message: "一致する情報はみつかりませんでした。"}, status: :bad_request
      return
    end

    PasswordMailer.send_rest_password(@user)

    render json: {message: "パスワード再設定用のメールを送信いたしました"}, status: :ok
  end

  def update
    @user.password = params[:new_password]
    unless @user.valid?(:reset_password)
      render json: {message: "パスワードの更新に失敗しました", errors: @user.errors.messages}, status: :bad_request
      return
    end

    @user.hash_password

    if @user.save
      render json: @user, status: :ok
    else
      render json: {message: "パスワードの更新に失敗しました", errors: @user.errors.messages}, status: :internal_server_error
    end
  end

  private

  def verify_old_password
    unless @user.authoricate(params[:password].strip)
      render json: {message: "パスワードが正しくありません"}, status: :bad_request
    end
  end

  def verify_password_confirmation
    unless params[:new_password] == params[:new_password_confirmation]
      render json: {message: "新しいパスワードと確認用パスワードが一致していません"}, status: :bad_request
    end
  end
end
