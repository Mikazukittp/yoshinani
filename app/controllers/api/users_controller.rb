class Api::UsersController < ApplicationController
  before_action :authenticate!, except: [:sign_in, :create]
  before_action :set_user, only: [:show, :update]

  def index
    # バリデーション
    if params['group_id'].blank?
      render json: {message: "グループidが入力されていません"}, status: :internal_server_error
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
      render json: {message: 'ユーザーの作成に失敗しました', errors: @user.errors.messages }, status: :internal_server_error
    end
  end

  def update
    # OAuth登録直後のCSはpasswordがnilなのでupdateでハッシュ化する必要がある
    if @user.oauth_registration_and_no_attribute?
      @user.attributes = user_params
      @user.hash_password
    else
      @user.attributes = user_params
    end

    if @user.save
      render json: @user, status: :ok
    else
      render json: {message: 'ユーザーの更新に失敗しました', errors: @user.errors.messages}, status: :internal_server_error
    end
  end

  def destroy
    #今回未実装？
  end

  def sign_in
    #usernameとpasswordを受け取って、正しければ、tokenを再生成して、DBに上書く&返す
    @user = User.find_by(account: params[:account].strip)
    if @user.blank?
      render json: {message: "アカウント名かパスワードが正しくありません"}, status: :unauthorized
      return
    end

    if @user.authoricate(params[:password].strip)
      @user.new_token
      @user.save!
      render json: @user, status: :ok
    else
      render json: {message: "アカウント名かパスワードが正しくありません"}, status: :unauthorized
    end
  end

  def sign_out
    if @user.update(token: nil)
      render json: @user, status: :ok
    else
      render json: {message: "サインアウトに失敗しました", errors: @user.errors.messages}, status: :internal_server_error
    end
  end

  def search
    user = User.find_by(account: params[:account])
    user = {} if user.nil?

    render json: user
  end

  private

  def user_params
    params.require(:user).permit(:account, :password, :email, :username)
  end

  def set_user
    @user = User.find_by(id: params[:id])
    unless @user.present?
      render json: {message: "指定されたIDのユーザーが見つかりません"}, status: :not_found
      return
    end
  end
end
