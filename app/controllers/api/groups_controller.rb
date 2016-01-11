class Api::GroupsController < ApplicationController
  before_action :authenticate!

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
end
