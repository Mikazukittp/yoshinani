class Api::UserController < ApplicationController

  def index
    render :json => User.all, status: :ok
  end

  def show
    render :json => User.first, status: :ok
  end

  def create
    render :json => {}, status: :internal_server_error
  end

  def update
    render :json => {}, status: :internal_server_error
  end

  def destroy
    render :json => {}, status: :internal_server_error
  end

end
