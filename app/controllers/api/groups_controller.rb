class Api::GroupsController < ApplicationController
  before_action :authenticate!
  before_action :set_group, only: %i(show update destroy)

  def index
    render json: @user.groups, status: :ok
  end

  def show
    render json: @group, status: :ok
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

  def set_group
    @group = @user.groups.find_by(id: params[:id])
    unless @group.present?
      render json: {error: "指定されたIDのグループが見つかりません"}, status: :not_found
      return
    end
  end
end
