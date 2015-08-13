class Api::GroupController < ApplicationController

  def index
    render json: Group.all, status: :ok
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
