class Api::GroupsController < ApplicationController
  before_action :set_user, only: %i(index)

  def index
    render json: @user.groups, status: :ok
  end

  def show
    render json: Group.first, status: :ok
  end

  def create
    render json: {}, status: :internal_server_error
  end

  def update
    render json: {}, status: :internal_server_error
  end

  def destroy
    render json: {}, status: :internal_server_error
  end

  private

  def set_user
    if params['user_id'].blank?
      render json: {error: "ユーザーidが入力されていません"}, status: :bad_request
      return
    end

    @user = User.find_by(id: params['user_id'])
    unless @user.present?
      render json: {error: "指定されたIDのユーザが見つかりません"}, status: :not_found
      return
    end
  end
end
