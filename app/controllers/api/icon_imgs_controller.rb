class Api::IconImgsController < ApplicationController
  before_action :authenticate!
  before_action :deny_action_to_another_user

  def create
    @user.icon_img = params['icon_img']

    if @user.save
      render json: @user, status: :ok
    else
      render json: {message: "プロフィール画像のアップロードに失敗しました", errors: @user.errors.messages}, status: :internal_server_error
    end
  end

  def update
  end

  def destroy
    @user.icon_img = nil

    if @user.save
      render json: @user, status: :ok
    else
      render json: {message: "プロフィール画像の削除に失敗しました", errors: @user.errors.messages}, status: :internal_server_error
    end
  end

  private

  def deny_action_to_another_user
    p @user.id
    p params['user_id']
    unless @user.id == params['user_id'].to_i
      render json: {message: "許可されていない操作です"}, status: :bad_request
      return
    end
  end
end
