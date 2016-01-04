class Api::UsersController < ApplicationController
  before_action :authenticate!, except: [:sign_in, :create]
  before_action :set_user, only: [:show, :update]

  def index
    # バリデーション
    if params['group_id'].blank?
      render json: {error: "グループidが入力されていません"}, status: :internal_server_error
      return
    end
    render json: Group.find(params['group_id']).users, status: :ok
  end

  def show
    render json: @user, status: :ok
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :ok
    else
      render json: {error: "ユーザの作成に失敗しました"}, status: :internal_server_error
    end
  end

  def update
    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: {error: "ユーザの更新に失敗しました"}, status: :internal_server_error
    end
  end

  def destroy
    #今回未実装？
  end

  def sign_in
    #usernameとpasswordを受け取って、正しければ、tokenを再生成して、DBに上書く&返す
    @user = User.find_by(account: params[:account])
    if @user.blank?
      render json: {error: "アカウント名かパスワードが正しくありません"}, status: :unauthorized
      return
    end

    if @user.authoricate(params[:password])
      @user.new_token
      @user.save!
      render json: @user, status: :ok
    else
      render json: {error: "アカウント名かパスワードが正しくありません"}, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:account, :password, :email, :username)
  end

  def set_user
    @user = User.find_by(id: params[:id])
    unless @user.present?
      render json: {error: "指定されたIDのユーザが見つかりません"}, status: :not_found
      return
    end
  end
end
